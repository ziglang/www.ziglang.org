const column_types = {
  timestamp: 'date',
  commit_timestamp: 'date',
  benchmark_name: 'string',
  commit_hash: 'string',
  zig_version: 'string',
  error_message: 'string',
  maxrss: 'kb',
  wall_time_median: 'ns',
  wall_time_mean: 'ns',
  wall_time_min: 'ns',
  wall_time_max: 'ns',
  utime_median: 'ns',
  utime_mean: 'ns',
  utime_min: 'ns',
  utime_max: 'ns',
  stime_median: 'ns',
  stime_mean: 'ns',
  stime_min: 'ns',
  stime_max: 'ns',
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
          row_obj[column_name] = (+row_array[column_i]);
          break;
        case 'ns':
          row_obj[column_name] = (+row_array[column_i]) / 1000000;
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

      rows.push({
        x: csv_row.commit_timestamp,
        z: "median",
        y1: csv_row.wall_time_median,
        y2: csv_row.instructions_median,
        y3: csv_row.cache_misses_median,
        y4: csv_row.maxrss,
        title1: makeLabel(csv_row, "wall_time_median"),
        title2: makeLabel(csv_row, "instructions_median"),
        title3: makeLabel(csv_row, "cache_misses_median"),
        title4: makeLabel(csv_row, "maxrss"),
      });
    }

    const chart = LineChart(rows, {
      x: d => d.x,
      y1: d => d.y1,
      y2: d => d.y2,
      y3: d => d.y3,
      y4: d => d.y4,
      z: d => d.z,
      title1: d => d.title1,
      title2: d => d.title2,
      title3: d => d.title3,
      title4: d => d.title4,
      y1Label: "ms",
      y2Label: "CPU instructions",
      y3Label: "cache misses",
      y4Label: "KB",
      width: document.body.clientWidth,
      height: 500,
      marginLeft: 60,
    })
    const div = document.createElement("div");
    const src_url = "https://github.com/ziglang/gotta-go-fast/tree/master/benchmarks/" +
      benchmarks_json[key].dir + "/" + benchmarks_json[key].mainPath;
    const desc = benchmarks_json[key].description;
    div.innerHTML = `<h2 id="${key}">${key}</h2><p>${desc} <a href="${src_url}">source</a></p>`;
    div.appendChild(chart);
    document.body.appendChild(div);
  }
})();

function makeLabel(obj, key) {
  return obj[key] + " " + key + " @ " + obj.zig_version;
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
  y1 = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  y2 = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  y3 = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  y4 = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  z = () => 1, // given d in data, returns the (categorical) z-value
  title1, // given d in data, returns the title text
  title2, // given d in data, returns the title text
  title3, // given d in data, returns the title text
  title4, // given d in data, returns the title text
  defined, // for gaps in data
  curve = d3.curveLinear, // method of interpolation between points
  marginTop = 20, // top margin, in pixels
  marginRight = 60, // right margin, in pixels
  marginBottom = 30, // bottom margin, in pixels
  marginLeft = 40, // left margin, in pixels
  width = 640, // outer width, in pixels
  height = 400, // outer height, in pixels
  xRange = [marginLeft, width - marginRight], // [left, right]
  yRange = [height - marginBottom, marginTop], // [bottom, top]
  yFormat, // a format specifier string for the y-axis
  y1Label, // a label for the y-axis
  y2Label, // a label for the y-axis
  y3Label, // a label for the y-axis
  y4Label, // a label for the y-axis
  strokeLinecap, // stroke line cap of line
  strokeLinejoin, // stroke line join of line
  strokeWidth = 1.5, // stroke width of line
  strokeOpacity, // stroke opacity of line
  mixBlendMode = "multiply", // blend mode of lines
} = {}) {
  // Compute values.
  const X = d3.map(data, x);
  const Y1 = d3.map(data, y1);
  const Y2 = d3.map(data, y2);
  const Y3 = d3.map(data, y3);
  const Y4 = d3.map(data, y4);
  const Z = d3.map(data, z);
  const O = d3.map(data, d => d);
  if (defined === undefined) {
    defined = function (d, i) {
      return !isNaN(X[i]) &&
             !isNaN(Y1[i]) &&
             !isNaN(Y2[i]) &&
             !isNaN(Y3[i]) &&
             !isNaN(Y4[i]);
    };
  }
  const D = d3.map(data, defined);

  // Compute default domains, and unique the z-domain.
  const xDomain = d3.extent(X);
  const y1Domain = [d3.min(Y1), d3.max(Y1)];
  const y2Domain = [d3.min(Y2), d3.max(Y2)];
  const y3Domain = [d3.min(Y3), d3.max(Y3)];
  const y4Domain = [d3.min(Y4), d3.max(Y4)];
  const zDomain = new d3.InternSet(Z);

  // Omit any data not present in the z-domain.
  const I = d3.range(X.length).filter(i => zDomain.has(Z[i]));

  // Construct scales and axes.
  const xScale = d3.scaleUtc(xDomain, xRange);
  const y1Scale = d3.scaleLinear(y1Domain, yRange);
  const y2Scale = d3.scaleLinear(y2Domain, yRange);
  const y3Scale = d3.scaleLinear(y3Domain, yRange);
  const y4Scale = d3.scaleLinear(y4Domain, yRange);
  const xAxis = d3.axisBottom(xScale).ticks(width / 80).tickSizeOuter(0);
  const y1Axis = d3.axisLeft(y1Scale).ticks(height / 60, yFormat);
  const y2Axis = d3.axisRight(y2Scale).ticks(height / 60, yFormat);
  const y3Axis = d3.axisLeft(y3Scale).ticks(height / 60, yFormat);
  const y4Axis = d3.axisRight(y4Scale).ticks(height / 60, yFormat);

  // Compute titles.
  const T1 = title1 === undefined ? Z : title1 === null ? null : d3.map(data, title1);
  const T2 = title2 === undefined ? Z : title2 === null ? null : d3.map(data, title2);
  const T3 = title3 === undefined ? Z : title3 === null ? null : d3.map(data, title3);
  const T4 = title4 === undefined ? Z : title4 === null ? null : d3.map(data, title4);

  // Construct a line generator.
  const line1 = d3.line()
      .defined(i => D[i])
      .curve(curve)
      .x(i => xScale(X[i]))
      .y(i => y1Scale(Y1[i]));

  const line2 = d3.line()
      .defined(i => D[i])
      .curve(curve)
      .x(i => xScale(X[i]))
      .y(i => y2Scale(Y2[i]));

  const line3 = d3.line()
      .defined(i => D[i])
      .curve(curve)
      .x(i => xScale(X[i]))
      .y(i => y3Scale(Y3[i]));

  const line4 = d3.line()
      .defined(i => D[i])
      .curve(curve)
      .x(i => xScale(X[i]))
      .y(i => y4Scale(Y4[i]));

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

  const color1 = "steelblue";
  const color2 = "brown";
  const color3 = "goldenrod";
  const color4 = "darkolivegreen";

  svg.append("g")
      .attr("transform", `translate(0,${height - marginBottom})`)
      .call(xAxis);

  svg.append("g")
      .attr("transform", `translate(${marginLeft},0)`)
      .call(y1Axis)
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", -marginLeft)
          .attr("y", 10)
          .attr("fill", color1)
          .attr("text-anchor", "start")
          .text(y1Label));

  svg.append("g")
      .attr("transform", `translate(${marginLeft},0)`)
      .call(y2Axis)
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", 0)
          .attr("y", 10)
          .attr("fill", color2)
          .attr("text-anchor", "start")
          .text(y2Label));

  svg.append("g")
      .attr("transform", `translate(${width - marginRight},0)`)
      .call(y3Axis)
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", -marginLeft - 10)
          .attr("y", 10)
          .attr("fill", color3)
          .attr("text-anchor", "start")
          .text(y3Label));

  svg.append("g")
      .attr("transform", `translate(${width - marginRight},0)`)
      .call(y4Axis)
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", 10)
          .attr("y", 10)
          .attr("fill", color4)
          .attr("text-anchor", "start")
          .text(y4Label));


  const path1 = svg.append("g")
      .attr("fill", "none")
      .attr("stroke", color1)
      .attr("stroke-linecap", strokeLinecap)
      .attr("stroke-linejoin", strokeLinejoin)
      .attr("stroke-width", strokeWidth)
      .attr("stroke-opacity", strokeOpacity)
    .selectAll("path")
    .data(d3.group(I, i => Z[i]))
    .join("path")
      .style("mix-blend-mode", mixBlendMode)
      .attr("d", ([, I]) => line1(I));

  const path2 = svg.append("g")
      .attr("fill", "none")
      .attr("stroke", color2)
      .attr("stroke-linecap", strokeLinecap)
      .attr("stroke-linejoin", strokeLinejoin)
      .attr("stroke-width", strokeWidth)
      .attr("stroke-opacity", strokeOpacity)
    .selectAll("path")
    .data(d3.group(I, i => Z[i]))
    .join("path")
      .style("mix-blend-mode", mixBlendMode)
      .attr("d", ([, I]) => line2(I));

  const path3 = svg.append("g")
      .attr("fill", "none")
      .attr("stroke", color3)
      .attr("stroke-linecap", strokeLinecap)
      .attr("stroke-linejoin", strokeLinejoin)
      .attr("stroke-width", strokeWidth)
      .attr("stroke-opacity", strokeOpacity)
    .selectAll("path")
    .data(d3.group(I, i => Z[i]))
    .join("path")
      .style("mix-blend-mode", mixBlendMode)
      .attr("d", ([, I]) => line3(I));

  const path4 = svg.append("g")
      .attr("fill", "none")
      .attr("stroke", color4)
      .attr("stroke-linecap", strokeLinecap)
      .attr("stroke-linejoin", strokeLinejoin)
      .attr("stroke-width", strokeWidth)
      .attr("stroke-opacity", strokeOpacity)
    .selectAll("path")
    .data(d3.group(I, i => Z[i]))
    .join("path")
      .style("mix-blend-mode", mixBlendMode)
      .attr("d", ([, I]) => line4(I));

  const dot1 = svg.append("g")
      .attr("display", "none");
  dot1.append("circle")
      .attr("r", 2.5);
  dot1.append("text")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "middle")
      .attr("y", -8);

  const dot2 = svg.append("g")
      .attr("display", "none");
  dot2.append("circle")
      .attr("r", 2.5);
  dot2.append("text")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "middle")
      .attr("y", -8);

  const dot3 = svg.append("g")
      .attr("display", "none");
  dot3.append("circle")
      .attr("r", 2.5);
  dot3.append("text")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "middle")
      .attr("y", -8);

  const dot4 = svg.append("g")
      .attr("display", "none");
  dot4.append("circle")
      .attr("r", 2.5);
  dot4.append("text")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "middle")
      .attr("y", -8);

  function pointermoved(event) {
    const [xm, ym] = d3.pointer(event);
    const i1Score = i => Math.hypot(xScale(X[i]) - xm, y1Scale(Y1[i]) - ym);
    const i2Score = i => Math.hypot(xScale(X[i]) - xm, y2Scale(Y2[i]) - ym);
    const i3Score = i => Math.hypot(xScale(X[i]) - xm, y3Scale(Y3[i]) - ym);
    const i4Score = i => Math.hypot(xScale(X[i]) - xm, y4Scale(Y4[i]) - ym);
    const i1 = d3.least(I, i1Score);
    const i2 = d3.least(I, i2Score);
    const i3 = d3.least(I, i3Score);
    const i4 = d3.least(I, i4Score);
    const i1_score = i1Score(i1);
    const i2_score = i2Score(i2);
    const i3_score = i3Score(i3);
    const i4_score = i4Score(i4);

    path1.style("mix-blend-mode", null).attr("stroke", "#ddd");
    path2.style("mix-blend-mode", null).attr("stroke", "#ddd");
    path3.style("mix-blend-mode", null).attr("stroke", "#ddd");
    path4.style("mix-blend-mode", null).attr("stroke", "#ddd");
    dot1.attr("display", "none");
    dot2.attr("display", "none");
    dot3.attr("display", "none");
    dot4.attr("display", "none");

    if (i1_score < i2_score && i1_score < i3_score && i1_score < i4_score) {
      dot1.attr("display", null);
      path1.attr("stroke", ([z]) => Z[i1] === z ? null : "#ddd").filter(([z]) => Z[i1] === z).raise();
      dot1.attr("transform", `translate(${xScale(X[i1])},${y1Scale(Y1[i1])})`);
      if (T1) dot1.select("text").text(T1[i1]);
      svg.property("value", O[i1]).dispatch("input", {bubbles: true});
    } else if (i2_score < i3_score && i2_score < i4_score) {
      dot2.attr("display", null);
      path2.attr("stroke", ([z]) => Z[i2] === z ? null : "#ddd").filter(([z]) => Z[i2] === z).raise();
      dot2.attr("transform", `translate(${xScale(X[i2])},${y2Scale(Y2[i2])})`);
      if (T2) dot2.select("text").text(T2[i2]);
      svg.property("value", O[i2]).dispatch("input", {bubbles: true});
    } else if (i3_score < i4_score) {
      dot3.attr("display", null);
      path3.attr("stroke", ([z]) => Z[i3] === z ? null : "#ddd").filter(([z]) => Z[i3] === z).raise();
      dot3.attr("transform", `translate(${xScale(X[i3])},${y3Scale(Y3[i3])})`);
      if (T3) dot3.select("text").text(T3[i3]);
      svg.property("value", O[i3]).dispatch("input", {bubbles: true});
    } else {
      dot4.attr("display", null);
      path4.attr("stroke", ([z]) => Z[i4] === z ? null : "#ddd").filter(([z]) => Z[i4] === z).raise();
      dot4.attr("transform", `translate(${xScale(X[i4])},${y4Scale(Y4[i4])})`);
      if (T4) dot4.select("text").text(T4[i4]);
      svg.property("value", O[i4]).dispatch("input", {bubbles: true});
    }
  }

  function pointerentered() {
    path1.style("mix-blend-mode", null).attr("stroke", "#ddd");
    path2.style("mix-blend-mode", null).attr("stroke", "#ddd");
    path3.style("mix-blend-mode", null).attr("stroke", "#ddd");
    path4.style("mix-blend-mode", null).attr("stroke", "#ddd");
    dot1.attr("display", null);
    dot2.attr("display", null);
    dot3.attr("display", null);
    dot4.attr("display", null);
  }

  function pointerleft() {
    path1.style("mix-blend-mode", "multiply").attr("stroke", null);
    path2.style("mix-blend-mode", "multiply").attr("stroke", null);
    path3.style("mix-blend-mode", "multiply").attr("stroke", null);
    path4.style("mix-blend-mode", "multiply").attr("stroke", null);
    dot1.attr("display", "none");
    dot2.attr("display", "none");
    dot3.attr("display", "none");
    dot4.attr("display", "none");
    svg.node().value = null;
    svg.dispatch("input", {bubbles: true});
  }

  return Object.assign(svg.node(), {value: null});
}
