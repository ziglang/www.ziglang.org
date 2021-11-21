
const MEASUREMENT_TITLES = {
  cpu_cycles: "CPU Cycles",
  instructions:"CPU Instructions", 
  cache_references: "Cache References",
  cache_misses: "Cache Misses",
  wall_time: "Wall Time",
  utime: "User-Space Time", 
  stime: "Kernel Time",
  branch_misses: "Branch Misses",
  maxrss: "Max RSS",
};

function getTitle(measurement) {
  return MEASUREMENT_TITLES[measurement];
}

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

function createStructureForBenchmark(key, benchmark) {
    const div = document.createElement("div");
    div.classList.add("benchmark");
    div.classList.add(key);
    div.classList.add(benchmark.kind);

    // Build the title <span>
    const titleSpan = document.createElement("span");
    titleSpan.id = key;
    titleSpan.classList.add("benchmark-title");

    const titleAnchor = document.createElement("a");
    titleAnchor.innerText = key;
    titleAnchor.href = "#" + key;

    // Add the titleAnchor to the titleSpan
    titleSpan.appendChild(titleAnchor);

    // Build the description
    const descriptionSpan = document.createElement("span");
    descriptionSpan.classList.add("benchmark-description");

    const descriptionEm = document.createElement("em");
    descriptionEm.innerText = benchmark.description;

    // Add the descriptionEm to the span
    descriptionSpan.appendChild(descriptionEm);


    const chartDiv = document.createElement("div");
    chartDiv.id = "chart-" + key;
    chartDiv.classList.add("chart");

    const sourceLinkParagraph = document.createElement("p")
    const sourceLinkAnchor = document.createElement("a")
    sourceLinkAnchor.classList.add("external-link");
    sourceLinkAnchor.classList.add("external-link-light");
    const src_url = "https://github.com/ziglang/gotta-go-fast/tree/master/benchmarks/" +
      benchmark.dir + "/" + benchmark.mainPath;
    const desc = benchmark.description;
    sourceLinkAnchor.href = src_url;
    sourceLinkAnchor.innerText = "Source";

    sourceLinkParagraph.appendChild(sourceLinkAnchor);

    div.appendChild(titleSpan);
    div.appendChild(descriptionSpan);
    div.appendChild(chartDiv);
    div.appendChild(sourceLinkParagraph);

    // Put the HTML we've built into the existing div#content element in layouts/perf/baseof.html
    document.getElementById("content").querySelector("div.container").appendChild(div);

}

async function loadBenchmarksJSON() {
    const response = await fetch('benchmarks.json');
    const data = await response.json();
    return data;
}

async function loadRecords() {
// https://stackoverflow.com/questions/57204863/loading-csv-data-and-save-results-to-a-variable
// Massage the data
return await d3.csv("records.csv").then(function (data) {
  data.forEach(function (d) {
    // Need to multiply the unix time by 1000 so the Date initializer works.
    d.timestamp = new Date(d.timestamp * 1000);
    d.commit_timestamp = new Date(d.commit_timestamp * 1000);
    d.benchmark_name = d.benchmark_name;
    d.zig_version = d.zig_version;
    d.samples_taken = d.samples_taken;

    // stime
    d.stime_median = +d.stime_median;
    d.stime_mean = +d.stime_mean;
    d.stime_min = +d.stime_min;
    d.stime_max = +d.stime_max;

    // utime
    d.utime_median = +d.utime_median;
    d.utime_mean = +d.utime_mean;
    d.utime_min = +d.utime_min;
    d.utime_max = +d.utime_max;

    // Instructions
    d.instructions_median = +d.instructions_median;
    d.instructions_mean = +d.instructions_mean;
    d.instructions_min = +d.instructions_min;
    d.instructions_max = +d.instructions_max;

    // CPU Cycles
    d.cpu_cycles_median = +d.cpu_cycles_median;
    d.cpu_cycles_mean = +d.cpu_cycles_mean;
    d.cpu_cyces_min = +d.cpu_cycles_min;
    d.cpu_cycles_max = +d.cpu_cycles_max;

    // Cache Misses
    d.cache_misses_median = +d.cache_misses_median;
    d.cache_misses_mean = +d.cache_misses_mean;
    d.cache_misses_min = +d.cache_misses_min;
    d.cache_misses_max = +d.cache_misses_max;

    // Branch Misses
    d.branch_misses_median = +d.branch_misses_median;
    d.branch_misses_mean = +d.branch_misses_mean;
    d.branch_misses_min = +d.branch_misses_min;
    d.branch_misses_max = +d.branch_misses_max;

    // TODO: Make sure this is necessary. The lines are messed up without doing this, but I don't understand why.
    // Cache References
    d.cache_references_median = +d.cache_references_median;
    d.cache_references_mean = +d.cache_references_mean;
    d.cache_references_min = +d.cache_references_min;
    d.cache_references_max = +d.cache_references_max;

    // Wall Time
    d.wall_time_median = +d.wall_time_median;
    d.wall_time_mean = +d.wall_time_mean;
    d.wall_time_min = +d.wall_time_min;
    d.wall_time_max = +d.wall_time_max;

    // MaxRSS
    d.maxrss = +d.maxrss;
  });
  // data = data.filter(data => data.benchmark_name == "self-hosted-parser");
  // data = data.filter(data => data.benchmark_name == "self-hosted-parser");
  // The order of the sort and timestamp adjustment must be like this, need to understand why.
  data.sort(function(a, b) {
    return orderZigVersions(a.zig_version, b.zig_version);
  });

  for (let i = 1; i < data.length; i += 1) {
    if (data[i].commit_timestamp < data[i-1].commit_timestamp) {
      // Pretend it was done 30 minutes after the previous timestamp.
      data[i].commit_timestamp = new Date((+data[i-1].commit_timestamp) + (1000 * 60 * 30));
    }
  }
  return data;
});
}

// https://github.com/cocopon/tweakpane
const pane = new Tweakpane.Pane();

const options = {
  type: "stacked",
  line: "median",
  rangeArea: true,
  xInterval: "date",
  yStart: "min",
  height: 175,
  primaryLineStrokeColor: '#8df',
};

const f1 = pane.addFolder({
  title: 'Charts',
});

f1.addInput(options, 'type', {
options: [
    {text: 'Stacked', value: 'stacked'},
    {text: 'Overlay', value: 'overlay'},
  ],
});

f1.addInput(options, 'line', {
options: [
    {text: 'Median', value: 'median'},
    {text: 'Mean', value: 'mean'},
    {text: 'Minimum', value: 'minimum'},
    {text: 'Maximum', value: 'maximum'},
  ],
});

f1.addInput(options, 'rangeArea');

f1.addSeparator();

f1.addInput(options, 'xInterval', {
options: [
    {text: 'Date', value: 'date'},
    {text: 'Commits', value: 'commit'},
  ],
});

f1.addInput(options, 'yStart', {
options: [
    {text: '0', value: 'zero'},
    {text: 'Min. Value', value: 'min'},
  ],
});

f1.addSeparator();

f1.addInput(options, 'height', {
  step: 1.0,
  min: 50,
  max: 800,
});

const f2 = pane.addFolder({
  title: 'Data',
});

const addMonthDummyDataButton = f2.addButton({
  title: '+1 Month',
});

f2.addSeparator();

const resetDataButton = f2.addButton({
  title: 'Reset',
});

pane.on('change', (event) => {
  console.log(options.height);
  makeCharts();
});

// window.addEventListener('resize', makeCharts);

// pane.addInput(options, 'primaryLineStrokeColor');

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



var benchmark_json;
var records;

const loadEverything = async () => {
  console.info("Loading CSV/JSON data.");
  const benchmark_json = await loadBenchmarksJSON();
  const records = await loadRecords();
  return {benchmark_json, records};
}

loadEverything().then(data => {
  records = data.records;
  benchmark_json = data.benchmark_json;
  console.info("Data loaded.");
  console.info(`records.csv loaded. It contains ${records.length} records.`);
  console.info(`benchmarks.json file contains ${Object.keys(benchmark_json).length} benchmark metadata objects.`);
  // debugger;
  makeCharts();
});


function makeCharts() {
  Object.keys(benchmark_json).forEach(benchmarkName => {
    createStructureForBenchmark(benchmarkName, benchmark_json[benchmarkName]);

    // Remove the old charts
    const targetChartDiv = document.getElementById("chart-" + benchmarkName);
    while (targetChartDiv.firstChild) {
      targetChartDiv.removeChild(targetChartDiv.firstChild);
    }
    // const targetChartDiv = document.getElementById("chart-" + key);
// const containerDiv = document.getElementById("content").querySelector("div.container");

    const benchmark_data = records.filter(data => data.benchmark_name == benchmarkName);

    Object.keys(MEASUREMENT_TITLES).forEach(measurement => {
      // debugger;
    drawRangeAreaChart(benchmarkName, measurement, benchmark_data, options, targetChartDiv);
    });
  })
  ;
}

// loadEverything().then(data=> {console.log(data.1);});
// loadBenchmarksJSON().then(json=> {
//   return json;

//   // for (let key in json) {
//   //   drawRangeAreaChart("Cache References", "cache_references", data.filter(data => data.benchmark_name == key), options, containerDiv);
//   //   drawRangeAreaChart("Cache Misses", "cache_misses", data.filter(data => data.benchmark_name == key), options, containerDiv);
//   //   drawRangeAreaChart("Wall Time", "wall_time", data.filter(data => data.benchmark_name == key), options, containerDiv);
//   // };

// }).catch(error => { console.error(error); });

// const fetchAsyncA = async () => 
//   await (await fetch('https://api.github.com')).json()

function drawRangeAreaChart(benchmark, measurement, data, options, toNode) {

const margin = {top: 10, right: 10, bottom: 20, left: 130};
const width = toNode.clientWidth
const height =  options.height;

let maxKey = measurement + "_max";
let minKey = measurement + "_min";

if (measurement == "maxrss") {
  minKey = measurement;
  maxKey = measurement;
}

let primaryMeasurementKey;
if (measurement == "maxrss") {
  primaryMeasurementKey = measurement;
} else if (options.line == "median") {
  primaryMeasurementKey = measurement + "_median"
} else if (options.line == "mean") {
  primaryMeasurementKey = measurement + "_mean"
} else if (options.line == "minimum") {
  primaryMeasurementKey = measurement + "_min"
} else if (options.line == "maximum") {
  primaryMeasurementKey = measurement + "_max"
}

if (options.rangeArea == false) {
  // If we aren't displaying the area chart with min/max values, we want our min/max to be calculated using the
  // primary measurement, since we're only drawing that line. Otherwise we waste a lot of vertical space showing a larger, but unused range.
  minKey = primaryMeasurementKey
  maxKey = primaryMeasurementKey
}

const x = d3.scaleTime().range([margin.left, width - margin.right]);
const yAxisArea = d3.scaleLinear().range([height - margin.bottom, margin.top]);
const yAxisMin = d3.scaleLinear().range([height - margin.bottom,  margin.top]);
const yAxisMax = d3.scaleLinear().range([height - margin.bottom, margin.top]);
const yAxisPrimaryMeasurement = d3.scaleLinear().range([height - margin.bottom, margin.top]);
if (options.yStart == "zero") {
  const DOMAIN = [0, d3.max(data, d => d[maxKey])];
  yAxisPrimaryMeasurement.domain(DOMAIN);
  yAxisArea.domain(DOMAIN);
  yAxisMin.domain(DOMAIN);
  yAxisMax.domain(DOMAIN);
} else if (options.yStart == "min") {
  const DOMAIN = [d3.min(data, d => d[minKey]), d3.max(data, d => d[maxKey])];
  yAxisPrimaryMeasurement.domain(DOMAIN);
  yAxisArea.domain(DOMAIN);
  yAxisMin.domain(DOMAIN);
  yAxisMax.domain(DOMAIN);
}

const minLine = d3.line()
    .curve(d3.curveLinear)
    .x(function (data) {
      return x(data.commit_timestamp);
    })
    .y(function (data) {
      return yAxisMin(data[minKey]);
    });
const maxLine = d3.line()
    // .curve(d3.curveCatmullRom)
    .curve(d3.curveLinear)
    .x(function (data) {
      return x(data.commit_timestamp);
    })
    .y(function (data) {
      return yAxisMax(data[maxKey]);
    });

const primaryMeasurementLine = d3.line()
    // .curve(d3.curveCatmullRom)
    .curve(d3.curveLinear)
    .x(function (data) {
      return x(data.commit_timestamp);
    })
    .y(function (data) {
      return yAxisPrimaryMeasurement(data[primaryMeasurementKey]);
    });

const area = d3.area()
    .curve(d3.curveLinear)
    // .curve(d3.curveCatmullRom)
    .x(function (data) {
      return x(data.commit_timestamp);
    })
    .y0(function (data) {
      return yAxisArea(data[minKey]);
    })
    .y1(function (data) {
      return yAxisArea(data[maxKey]);
    })
;

const svg = d3.create("svg");
  svg
    .attr("width", width)
    .attr("height", height)
    .attr("viewBox", [0, 0, width, height])
    .attr("class", `${benchmark} ${measurement}`)
    .attr("style", "max-width: 100%; height: auto; height: intrinsic;")
    .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.right + ")")



  x.domain(d3.extent(data, function (d) { return d.commit_timestamp; }));

  if (options.rangeArea) {
  // Min/Max Range Area
  svg.append("path")
  .data([data])
  .attr("class", `area range`)
  .attr("d", area)


  // Min
  svg.append("path")
  .data([data])
  .attr("transform", "translate(0,0)")
  .attr("class", `line min`)
  .attr("d", minLine)

  // Max
  svg.append("path")
  .data([data])
  .attr("transform", "translate(0,0)")
  .attr("class", `line max`)
      .attr("d", maxLine)
    }


  // Median Line Chart
  svg.append("path")
      .data([data])
      .attr("class", `line primary ${measurement}`)
      // .attr("transform", "translate(" + margin.bottom + "," + margin.left + ")")
      .attr("d", primaryMeasurementLine)

      // Hover circles
      svg.append("g").selectAll('circle').data(data).enter().append('circle')
      .attr('cx', function(d) {  return x(d.commit_timestamp); })
      .attr('cy', function(d) { return yAxisArea(d[primaryMeasurementKey]); })
      .attr('r', 0)
      .attr('fill', 'orange')
      .attr('stroke', 'orange')
      .attr('stroke-width', '1px')
      .attr('class', 'circle');

      // X-Axis
  svg.append("g")
      .attr("transform", `translate(0,${height - margin.bottom})`)
      .attr("class", "axis x")
      .call(d3.axisBottom(x));

  // Y-Axis
  svg.append("g")
      .attr("transform", `translate(${margin.left}, 0)`)
      .attr("class", "axis y")
      .call(d3.axisLeft(yAxisArea).ticks(height / 80));

      // Y-Axis title
      svg.append("g")
      .call(g => g.append("text")
          .attr("transform", "rotate(-90)")
          .attr("class", `axis y title`)
          .attr("x", -(height / 2)) // with the -90 degree rotation this becomes the y
          .attr("y", 20) // new x
          .text(getTitle(measurement)));


      // Focus indicator group
      const focus = svg.append("g");
      focus.style("display", "none");
      focus.attr("id", "focus");

      // Focus circle
      focus
      .append("circle")
      .attr("class", "focus circle")
      .attr("id", "focusCircle");

      // Focus vertical line
      focus
      .append("line")
      .attr("class", "focus line y")
      .attr("id", "focusLine");

      svg.on("pointerenter", (event, data) => {
        event.preventDefault();
        // Unhide the focus rectangle when the mouse enters the chart
        focus.style("display", null);
      });

      svg
      .on("pointermove", (event, data) => {
        event.preventDefault();
        // Find the commit/data point closest to the mouse
        const bisectDate = d3.bisector((d) => { return d.commit_timestamp; }).left;
        const commitTimestampAtPointerX = x.invert(d3.pointer(event)[0]);
        const commitIndex = bisectDate(data, commitTimestampAtPointerX);

        // Position the focus y line
        const focusLine = focus.select("#focusLine");
        focusLine
        .transition()
        .duration(75)
        .attr("x1", x(data[commitIndex].commit_timestamp))
        .attr("y1", 0)
        .attr("x2", x(data[commitIndex].commit_timestamp))
        .attr("y2", height - margin.bottom)

        // Position the focus circle
        const focusCircle = focus.select("#focusCircle");
        focusCircle
        .transition()
        .duration(75)
        .attr("cx", x(data[commitIndex].commit_timestamp))
        .attr("cy", yAxisPrimaryMeasurement(data[commitIndex][primaryMeasurementKey]))
        .attr("r", 2);
      });

      svg.on("pointerleave", (event, data) => {
        event.preventDefault();
        // Hide the focus node
        focus.style("display", "none");
      });


      svg
      .data([data])
      .on("mouseover", (event, data) => {
        // Show a circle for each data point
        svg.selectAll('circle')
        .transition()
        .duration(75)
        .attr("r", 1);
        event.preventDefault();
        const bisectDate = d3.bisector((d) => { return d.commit_timestamp; }).left;
      const commitTimestampAtPointerX = x.invert(d3.pointer(event)[0]);
      const i = bisectDate(data, commitTimestampAtPointerX);

      const commitDate = new Date(data[i].commit_timestamp);

      const titleSpanNode = document.querySelector("div#tooltip>p.title>span.benchmark-title");
      titleSpanNode.innerText = benchmark;
      const measurementTitleSpanNode = document.querySelector("div#tooltip>p.title>span.measurement-title");
      measurementTitleSpanNode.innerText = getTitle(measurement);
      const dateNode = document.querySelector("div#tooltip>p.date");
      dateNode.innerText = commitDate.toLocaleString('en-US');
      const samplesNode = document.querySelector("div#tooltip>p.samples>span.samples_count");
      samplesNode.innerText = data[i].samples_taken;
      const measurementTitleNode = document.querySelector("div#tooltip>p.measurement>span.measurement-title");
      measurementTitleNode.innerText = getTitle(measurement);
      const measurementValueNode = document.querySelector("div#tooltip>p.measurement>span.measurement-value");
      measurementValueNode.innerText = d3.format(",")(data[i][primaryMeasurementKey]);
      const measurementDifferenceNode = document.querySelector("div#tooltip>p.measurement>span.measurement-difference");
      measurementDifferenceNode.innerText = d3.format(",")(data[i-1][primaryMeasurementKey] - data[i][primaryMeasurementKey]);
      const zigVersionNode = document.querySelector("div#tooltip>p.zig-version>span.zig-version");
      zigVersionNode.innerText = data[i].zig_version;
      const commitNode = document.querySelector("div#tooltip>p.commit>a");
      commitNode.href = `https://github.com/ziglang/zig/commit/${data[i].commit_hash}`;
      commitNode.innerText = data[i].commit_hash.substring(0, 7);
      const tooltip = d3.select("div#tooltip");
      tooltip
      .style("opacity", 1)
      .style("stroke", "black")
      .style("pointer-events", "all")
      .style("left", (event.clientX + 30) + "px")
      .style("top", (event.clientY + 50) + "px");
    })
      .on("mousedown", (event) => {
        // event.preventDefault();
        const bisectDate = d3.bisector((d) => { return d.commit_timestamp; }).left;
        const commitTimestampAtPointerX = x.invert(d3.pointer(event)[0]);
        const i = bisectDate(data, commitTimestampAtPointerX);
        window.open(`https://github.com/ziglang/zig/commit/${data[i].commit_hash}`, "_blank");
      })
      .on("mousemove", (event) => {
      event.preventDefault();
      const tooltip = d3.select("div#tooltip");
      tooltip
        .transition()
        .duration(75)
      .style("left", (event.clientX + 30) + "px")
      .style("top", (event.clientY + 50) + "px");
      })
    .on("mouseleave", (event) => {
        event.preventDefault();

        // Hide circles for each data point
        svg.selectAll('circle')
        .transition()
        .duration(75)
        .attr("r", 0);

      const tooltip = d3.select("div#tooltip");
    tooltip
      .style("opacity", 0.0)
      .style("stroke", "none")
      .style("pointer-events", "none");
    })

  // containerDiv.appendChild(svg.node());
  toNode.appendChild(svg.node());
  // toNode.children[0].replaceWith(svg.node());
// toNode.appendChild(svg.node());
  // document.body.replaceChild(svg.node(), toNode);
};
