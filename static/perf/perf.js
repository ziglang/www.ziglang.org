const column_types = {
  timestamp: 'date',
  commit_timestamp: 'date',
  benchmark_name: 'string',
  commit_hash: 'string',
  zig_version: 'string',
  error_message: 'string',
  maxrss: 'kb',
};

(async function(){
  const records_csv_promise = fetch("records.csv");
  const benchmarks_json_promise = fetch("benchmarks.json");
  const benchmarks_json = await (await benchmarks_json_promise) .json();
  const records_csv = await (await records_csv_promise).text();
  const record_lines = records_csv.split("\n");
  const first_row = record_lines[0].split(",");

  let charts = benchmarks_json;

  for (let key in benchmarks_json) {
    charts[key].rows = [];
  }

  for (let record_i = 1; record_i < record_lines.length; record_i += 1) {
    const row_array = record_lines[record_i].split(",");
    if (row_array.length !== first_row.length) continue;

    let row_obj = {};
    for (let column_i = 0; column_i < first_row.length; column_i += 1) {
      const column_name = first_row[column_i];
      switch (column_types[column_name]) {
        case 'date':
          row_obj[column_name] = new Date(1000*row_array[column_i]);
          break;
        case 'string':
          row_obj[column_name] = row_array[column_i];
          break;
        case 'kb':
          row_obj[column_name] = (+row_array[column_i]) * 1024;
          break;
        default:
          row_obj[column_name] = +row_array[column_i];
      }
    }
    if (row_obj.error_message.length != 0) continue;

    charts[row_obj.benchmark_name].rows.push(row_obj);
  }

  window.debug_charts = charts;

  const measurements = [
    "wall_time",
    "cpu_cycles",
    "instructions",
    "cache_references",
    "cache_misses",
    "branch_misses",
  ];
  const suffixes = [ "_median", "_mean", "_min", "_max" ];

  for (let key in benchmarks_json) {
    // Git commit timestamps can be out of order; we force them to be in
    // order if they disagree with the zig version ordering. This makes the
    // lines of the chart easier to understand.
    const csv_rows = charts[key].rows;
    csv_rows.sort(function(a, b) {
      return orderZigVersions(a.zig_version, b.zig_version);
    });
    for (let i = 1; i < csv_rows.length; i += 1) {
      if (csv_rows[i].commit_timestamp < csv_rows[i-1].commit_timestamp) {
        // Pretend it was done 30 minutes after the previous timestamp.
        csv_rows[i].commit_timestamp = new Date((+csv_rows[i-1].commit_timestamp) + 1000 * 60 * 30);
      }
    }

    let rows = [];
    for (let i = 0; i < charts[key].rows.length; i += 1) {
      const csv_row = charts[key].rows[i];
      for (const prefix of measurements) {
        for (const suffix of suffixes) {
          const measurement_name = prefix + suffix;
          rows.push({
            timestamp: csv_row.commit_timestamp,
            measurement_name: measurement_name,
            y: csv_row[measurement_name],
            label: makeLabel(csv_row, measurement_name),
          });
        }
      }

      rows.push({
        timestamp: csv_row.commit_timestamp,
        measurement_name: "maxrss",
        y: csv_row.maxrss,
        label: makeLabel(csv_row, "maxrss"),
      });
    }


    const chart = LineChart(rows, {
      x: d => d.timestamp,
      y: d => d.y,
      z: d => d.measurement_name,
      title: d => d.label,
      yLabel: key,
      width: document.body.clientWidth,
      height: 500,
      color: "steelblue",
      voronoi: false,
      marginLeft: 90,
    })
    chart.id = key;
    document.body.appendChild(chart);
  }
})();

function makeLabel(obj, measurement_name) {
  return obj[measurement_name] + " " + measurement_name + " @ " + obj.zig_version;
}

function orderZigVersions(a, b) {
  const a_array = parseZigVersion(a);
  const b_array = parseZigVersion(b);
  for (let i = 0; i < 4; i += 1) {
    if (a_array[i] != b_array[i]) return a_array[i] > b_array[i];
  }
  return 0;
}

function parseZigVersion(zig_version) {
  // It looks like "0.9.0-dev.1564+08dc84024"
  // Return something we can order by.
  const parts = zig_version.split("-");
  const semver = parts[0].split(".");
  const rev = (parts.length === 1) ? 0 : parts[1].split(".")[1].split("+")[0];
  return [+semver[0], +semver[1], +semver[2], +rev];
}

// Copyright 2021 Observable, Inc.
// Released under the ISC license.
// https://observablehq.com/@d3/multi-line-chart
function LineChart(data, {
  x = ([x]) => x, // given d in data, returns the (temporal) x-value
  y = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  z = () => 1, // given d in data, returns the (categorical) z-value
  title, // given d in data, returns the title text
  defined, // for gaps in data
  curve = d3.curveLinear, // method of interpolation between points
  marginTop = 20, // top margin, in pixels
  marginRight = 30, // right margin, in pixels
  marginBottom = 30, // bottom margin, in pixels
  marginLeft = 40, // left margin, in pixels
  width = 640, // outer width, in pixels
  height = 400, // outer height, in pixels
  xType = d3.scaleUtc, // type of x-scale
  xDomain, // [xmin, xmax]
  xRange = [marginLeft, width - marginRight], // [left, right]
  yType = d3.scaleLinear, // type of y-scale
  yDomain, // [ymin, ymax]
  yRange = [height - marginBottom, marginTop], // [bottom, top]
  yFormat, // a format specifier string for the y-axis
  yLabel, // a label for the y-axis
  zDomain, // array of z-values
  color = "currentColor", // stroke color of line
  strokeLinecap, // stroke line cap of line
  strokeLinejoin, // stroke line join of line
  strokeWidth = 1.5, // stroke width of line
  strokeOpacity, // stroke opacity of line
  mixBlendMode = "multiply", // blend mode of lines
  voronoi // show a Voronoi overlay? (for debugging)
} = {}) {
  // Compute values.
  const X = d3.map(data, x);
  const Y = d3.map(data, y);
  const Z = d3.map(data, z);
  const O = d3.map(data, d => d);
  if (defined === undefined) defined = (d, i) => !isNaN(X[i]) && !isNaN(Y[i]);
  const D = d3.map(data, defined);

  // Compute default domains, and unique the z-domain.
  if (xDomain === undefined) xDomain = d3.extent(X);
  if (yDomain === undefined) yDomain = [0, d3.max(Y)];
  if (zDomain === undefined) zDomain = Z;
  zDomain = new d3.InternSet(zDomain);

  // Omit any data not present in the z-domain.
  const I = d3.range(X.length).filter(i => zDomain.has(Z[i]));

  // Construct scales and axes.
  const xScale = xType(xDomain, xRange);
  const yScale = yType(yDomain, yRange);
  const xAxis = d3.axisBottom(xScale).ticks(width / 80).tickSizeOuter(0);
  const yAxis = d3.axisLeft(yScale).ticks(height / 60, yFormat);

  // Compute titles.
  const T = title === undefined ? Z : title === null ? null : d3.map(data, title);

  // Construct a line generator.
  const line = d3.line()
      .defined(i => D[i])
      .curve(curve)
      .x(i => xScale(X[i]))
      .y(i => yScale(Y[i]));

  const svg = d3.create("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", [0, 0, width, height])
      .attr("style", "max-width: 100%; height: auto; height: intrinsic;")
      .style("-webkit-tap-highlight-color", "transparent")
      .on("pointerenter", pointerentered)
      .on("pointermove", pointermoved)
      .on("pointerleave", pointerleft)
      .on("touchstart", event => event.preventDefault());

  // An optional Voronoi display (for fun).
  if (voronoi) svg.append("path")
      .attr("fill", "none")
      .attr("stroke", "#ccc")
      .attr("d", d3.Delaunay
        .from(I, i => xScale(X[i]), i => yScale(Y[i]))
        .voronoi([0, 0, width, height])
        .render());

  svg.append("g")
      .attr("transform", `translate(0,${height - marginBottom})`)
      .call(xAxis);

  svg.append("g")
      .attr("transform", `translate(${marginLeft},0)`)
      .call(yAxis)
      .call(g => g.select(".domain").remove())
      .call(voronoi ? () => {} : g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", -marginLeft)
          .attr("y", 10)
          .attr("fill", "currentColor")
          .attr("text-anchor", "start")
          .text(yLabel));

  const path = svg.append("g")
      .attr("fill", "none")
      .attr("stroke", color)
      .attr("stroke-linecap", strokeLinecap)
      .attr("stroke-linejoin", strokeLinejoin)
      .attr("stroke-width", strokeWidth)
      .attr("stroke-opacity", strokeOpacity)
    .selectAll("path")
    .data(d3.group(I, i => Z[i]))
    .join("path")
      .style("mix-blend-mode", mixBlendMode)
      .attr("d", ([, I]) => line(I));

  const dot = svg.append("g")
      .attr("display", "none");

  dot.append("circle")
      .attr("r", 2.5);

  dot.append("text")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "middle")
      .attr("y", -8);

  function pointermoved(event) {
    const [xm, ym] = d3.pointer(event);
    const i = d3.least(I, i => Math.hypot(xScale(X[i]) - xm, yScale(Y[i]) - ym)); // closest point
    path.attr("stroke", ([z]) => Z[i] === z ? null : "#ddd").filter(([z]) => Z[i] === z).raise();
    dot.attr("transform", `translate(${xScale(X[i])},${yScale(Y[i])})`);
    if (T) dot.select("text").text(T[i]);
    svg.property("value", O[i]).dispatch("input", {bubbles: true});
  }

  function pointerentered() {
    path.style("mix-blend-mode", null).attr("stroke", "#ddd");
    dot.attr("display", null);
  }

  function pointerleft() {
    path.style("mix-blend-mode", "multiply").attr("stroke", null);
    dot.attr("display", "none");
    svg.node().value = null;
    svg.dispatch("input", {bubbles: true});
  }

  return Object.assign(svg.node(), {value: null});
}
