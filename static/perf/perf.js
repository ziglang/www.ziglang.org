
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
/*
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
        y5: csv_row.branch_misses_median,
        title1: makeLabel(csv_row, "wall_time_median"),
        title2: makeLabel(csv_row, "instructions_median"),
        title3: makeLabel(csv_row, "cache_misses_median"),
        title4: makeLabel(csv_row, "maxrss"),
        title5: makeLabel(csv_row, "Branch Misses"),
      });
    }

    const chart = LineChart(rows, {
      x: d => d.x,
      y1: d => d.y1,
      y2: d => d.y2,
      y3: d => d.y3,
      y4: d => d.y4,
      y5: d => d.y5,
      z: d => d.z,
      title1: d => d.title1,
      title2: d => d.title2,
      title3: d => d.title3,
      title4: d => d.title4,
      title5: d => d.title5,
      y1Label: "ms",
      y2Label: "CPU instructions",
      y3Label: "cache misses",
      y4Label: "KB",
      y5Label: "Branch Misses",
      width: document.body.clientWidth,
      height: 500,
      marginLeft: 60,
    })
    const div = document.createElement("div");
    div.classList.add("benchmark");
    div.classList.add(key);
    div.classList.add(benchmarks_json[key].kind);

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
    descriptionEm.innerText = benchmarks_json[key].description;

    // Add the descriptionEm to the span
    descriptionSpan.appendChild(descriptionEm);

    const sourceLinkParagraph = document.createElement("p")
    const sourceLinkAnchor = document.createElement("a")
    sourceLinkAnchor.classList.add("external-link");
    sourceLinkAnchor.classList.add("external-link-light");
    const src_url = "https://github.com/ziglang/gotta-go-fast/tree/master/benchmarks/" +
      benchmarks_json[key].dir + "/" + benchmarks_json[key].mainPath;
    const desc = benchmarks_json[key].description;
    sourceLinkAnchor.href = src_url;
    sourceLinkAnchor.innerText = "Source";

    sourceLinkParagraph.appendChild(sourceLinkAnchor);

    div.appendChild(titleSpan);
    div.appendChild(descriptionSpan);
    div.appendChild(chart);
    div.appendChild(sourceLinkParagraph);

    // Put the HTML we've built into the existing div#content element in layouts/perf/baseof.html
    // document.getElementById("content").querySelector("div.container").appendChild(div);
  }
})();
*/

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
const tooltipDiv = document.createElement("div");
tooltipDiv.id = "tooltip";
tooltipDiv.classList.add("tooltip");
document.body.append(tooltipDiv);
// const tooltip = document.body.append(tooltipDiv);
  var tooltip = d3.select("div#tooltip")
    // .append("div")
    .style("position", "absolute")
    .style("opacity", 0)
    // .attr("class", "tooltip")
    .style("background-color", "darkgray")
    .style("border", "solid")
    .style("border-width", "2px")
    .style("border-radius", "5px")
    .style("border-color", "orange")
    .style("padding", "5px")

    var mouseOver = function(event, data) {
      tooltip
      .style("opacity", 1)
      .style("stroke", "black")
      .style("opacity", 1)
    }
  var mouseMove = function(event, data) {
      const [x, y] = d3.pointer(event);
    tooltip
      .html("The exact value of<br>this cell is: " + new Intl.DateTimeFormat('en-US', { dateStyle: 'full', timeStyle: 'medium' }).format(new Date(data[0].commit_timestamp)))
      // .style("left", "100px")
      // .style("top", "100px")
      // .style("left", event.pageX + "px")
      // .style("top", event.pageY + "px")
      .style("left", d3.pointer(event)[0] + "px")
      .style("top", d3.pointer(event)[1] + "px")
      // .attr('transform', `translate(${d3.pointer(event)[0]}, ${y})`);
  }
  var mouseLeave = function(event, data) {
    tooltip
      .style("opacity", 0)
    d3.select(this)
      .style("stroke", "none")
      .style("opacity", 0.8)
  }

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

const margin = {top: 10, right: 10, bottom: 20, left: 100};
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


  // min
  svg.append("path")
  .data([data])
  .attr("transform", "translate(0,0)")
  .attr("class", `line min`)
  .attr("d", minLine)

  // // max
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

      svg//.selectAll()
      .data([data])
      // .enter()
          .on("mouseover", mouseOver)
    .on("mousemove", mouseMove)
    .on("mouseleave", mouseLeave)
  // svg.append("g")
  //     .call(d3.axisLeft(yAxisMax));

  // containerDiv.appendChild(svg.node());
  toNode.appendChild(svg.node());
  // toNode.children[0].replaceWith(svg.node());
// toNode.appendChild(svg.node());
  // document.body.replaceChild(svg.node(), toNode);
};

// function BenchmarkChart(data, {
// });
  // document.getElementById("content").querySelector("div.container").appendChild(svg);
// Object.assign(svg.node(), {value: null});
// svg.selectAll(null).enter();
// d3.select("body").append(svg.node());
// containerDiv.appendChild(svg.node());
// document.getElementById("content").querySelector("div.container").appendChild(svg.node());

/*
var margin = {top: 20, right: 20, bottom: 30, left: 50}, width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;
// set the ranges
var x = d3.scaleTime().range([0, width]); var y = d3.scaleLinear().range([height, 0])
// define the line
var valueline = d3.line()
    .x(function(d) { return x(d.date); }) .y(function(d) { return y(d.close); });
var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform",
        "translate(" + margin.left + "," + margin.top + ")");

// Get the data
d3.csv("records.csv").then(function(data) {
  // format the data
  data.forEach(function(d) {
    // Need to multiply the unix time by 1000 so the Date initializer works.
    d.timestamp = new Date(d.timestamp * 1000); d.wall_time_median = +d.wall_time_median;
    // console.log(data);
  });
  // Scale the range of the data
  // x.domain(d3.extent(data, function(d) { return d.timestamp; })); y.domain([0, d3.max(data, function(d) { return d.wall_time_median; })]);
  // Add the valueline path.
  svg.append("path")

      .data([data])
      .attr("class", "line")
      .attr("d", valueline);
  // Add the X Axis
  svg.append("g")
      .attr("transform", "translate(0," + height + ")")
      .call(d3.axisBottom(x));
  // Add the Y Axis
  svg.append("g")
      .call(d3.axisLeft(y));
});
*/


// Copyright 2021 Observable, Inc.
// Released under the ISC license.
// https://observablehq.com/@d3/multi-line-chart
function LineChart(data, {
  x = ([x]) => x, // given d in data, returns the (temporal) x-value
  y1 = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  y2 = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  y3 = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  y4 = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  y5 = ([, y]) => y, // given d in data, returns the (quantitative) y-value
  z = () => 1, // given d in data, returns the (categorical) z-value
  title1, // given d in data, returns the title text
  title2, // given d in data, returns the title text
  title3, // given d in data, returns the title text
  title4, // given d in data, returns the title text
  title5, // given d in data, returns the title text
  defined, // for gaps in data
  curve = d3.curveLinear, // method of interpolation between points
  marginTop = 20, // top margin, in pixels
  marginRight = 60, // right margin, in pixels
  marginBottom = 30, // bottom margin, in pixels
  marginLeft = 180, // left margin, in pixels
  width = 640, // outer width, in pixels
  height = 400, // outer height, in pixels
  xRange = [marginLeft+60, width - marginRight], // [left, right]
  yRange = [height - marginBottom, marginTop], // [bottom, top]
  yFormat, // a format specifier string for the y-axis
  y1Label, // a label for the y-axis
  y2Label, // a label for the y-axis
  y3Label, // a label for the y-axis
  y4Label, // a label for the y-axis
  y5Label, // a label for the y-axis
  strokeLinecap, // stroke line cap of line
  strokeLinejoin, // stroke line join of line
  strokeWidth = 1.5, // stroke width of line
  strokeOpacity // stroke opacity of line
} = {}) {
  // Compute values.
  const X = d3.map(data, x);
  const Y1 = d3.map(data, y1);
  const Y2 = d3.map(data, y2);
  const Y3 = d3.map(data, y3);
  const Y4 = d3.map(data, y4);
  const Y5 = d3.map(data, y5);
  const Z = d3.map(data, z);
  const O = d3.map(data, d => d);
  if (defined === undefined) {
    defined = function (d, i) {
      return !isNaN(X[i]) &&
             !isNaN(Y1[i]) &&
             !isNaN(Y2[i]) &&
             !isNaN(Y3[i]) &&
             !isNaN(Y4[i]) &&
             !isNaN(Y5[i]);
    };
  }
  const D = d3.map(data, defined);

  // Compute default domains, and unique the z-domain.
  const xDomain = d3.extent(X);
  const y1Domain = [d3.min(Y1), d3.max(Y1)];
  const y2Domain = [d3.min(Y2), d3.max(Y2)];
  const y3Domain = [d3.min(Y3), d3.max(Y3)];
  const y4Domain = [d3.min(Y4), d3.max(Y4)];
  const y5Domain = [d3.min(Y5), d3.max(Y5)];
  const zDomain = new d3.InternSet(Z);

  // Omit any data not present in the z-domain.
  const I = d3.range(X.length).filter(i => zDomain.has(Z[i]));

  // Construct scales and axes.
  const xScale = d3.scaleUtc(xDomain, xRange);
  // const y1Scale = d3.scaleLog().domain(y1Domain).range([marginTop+450, height-marginBottom-150]);
  // const y2Scale = d3.scaleLog().domain(y2Domain).range([marginTop+300, height-marginBottom-250]);
  // const y3Scale = d3.scaleLog().domain(y3Domain).range([marginTop+200, height-marginBottom-350]);
  // const y4Scale = d3.scaleLog().domain(y4Domain).range([marginTop+100, height-marginBottom-450]);
  const y1Scale = d3.scaleLinear(y1Domain, [marginTop+450, height-marginBottom-150]);
  const y2Scale = d3.scaleLinear(y2Domain, [marginTop+300, height-marginBottom-250]);
  const y3Scale = d3.scaleLinear(y3Domain, [marginTop+200, height-marginBottom-350]);
  const y4Scale = d3.scaleLinear(y4Domain, [marginTop+100, height-marginBottom-450]);
  const y5Scale = d3.scaleLinear(y5Domain, [marginTop+0, height-marginBottom-550]);
  const xAxis = d3.axisBottom(xScale).ticks(10).tickSizeOuter(0);
  const y1Axis = d3.axisLeft(y1Scale).ticks(4, d3.format(".2s"));
  const y2Axis = d3.axisLeft(y2Scale).ticks(4, d3.format(",.4s"));
  const y3Axis = d3.axisLeft(y3Scale).ticks(4, yFormat);
  const y4Axis = d3.axisLeft(y4Scale).ticks(4, d3.format(".2s"));
  const y5Axis = d3.axisLeft(y5Scale).ticks(4, d3.format(".2s"));

  // Compute titles.
  const T1 = title1 === undefined ? Z : title1 === null ? null : d3.map(data, title1);
  const T2 = title2 === undefined ? Z : title2 === null ? null : d3.map(data, title2);
  const T3 = title3 === undefined ? Z : title3 === null ? null : d3.map(data, title3);
  const T4 = title4 === undefined ? Z : title4 === null ? null : d3.map(data, title4);
  const T5 = title4 === undefined ? Z : title5 === null ? null : d3.map(data, title5);

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

  const line5 = d3.line()
      .defined(i => D[i])
      .curve(curve)
      .x(i => xScale(X[i]))
      .y(i => y4Scale(Y5[i]));

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

      // https://www.youtube.com/watch?v=xAoljeRJ3lU
      // From viridis https://github.com/BIDS/colormap/blob/master/colormaps.py
      // const color1 = "rgb(68.08602, 1.24287, 84.000825)";
      // const color4 = "rgb(253.27824, 231.070035, 36.70368)";

  const color1 = "steelblue";
  const color2 = "brown";
  const color3 = "goldenrod";
  const color4 = "darkolivegreen";
  const color5 = "rebeccapurple";

  svg.append("g")
      .attr("transform", `translate(0,${height - marginBottom})`)
      .call(xAxis);

  svg.append("g")
      .attr("transform", `translate(${marginLeft + 50},0)`)
      .call(y1Axis)
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke", color1)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", -marginLeft * 1.5)
          .attr("y", 400)
          .attr("fill", color1)
          .attr("text-anchor", "start")
          .text(y1Label));

  svg.append("g")
      .attr("transform", `translate(${marginLeft + 50},0)`)
      // .attr("transform", `translate(${marginLeft},0)`)
      .call(y2Axis)
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke", color2)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          // .style("text-anchor", "end")
          .attr("transform", "rotate(-90)")
          // .attr("dx", "-.8em")
          // .attr("dy", ".15em")
          .attr("x", -250)
          .attr("y", -75)
          // .attr("y", 350)
          .attr("fill", color2)
          // .attr("text-anchor", "start")
          .text(y2Label));

  svg.append("g")
      .attr("transform", `translate(${marginLeft + 50},0)`)
      // .attr("transform", `translate(${marginLeft},0)`)
      .call(y3Axis)
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke", color3)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", -marginLeft * 1.5)
          .attr("y", 200)
          .attr("fill", color3)
          .attr("text-anchor", "start")
          .text(y3Label));

  svg.append("g")
      .attr("transform", `translate(${marginLeft + 50},0)`)
      // .attr("transform", `translate(${marginLeft},0)`)
      .call(y4Axis)
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke", color4)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", -marginLeft * 1.5)
          .attr("y", 100)
          .attr("fill", color4)
          .attr("text-anchor", "start")
          .text(y4Label));

  svg.append("g")
      .attr("transform", `translate(${marginLeft + 50},0)`)
      // .attr("transform", `translate(${marginLeft},0)`)
      .call(y5Axis)
      .call(g => g.select(".domain").remove())
      .call(g => g.selectAll(".tick line").clone()
          .attr("x2", width - marginLeft - marginRight)
          .attr("stroke", color4)
          .attr("stroke-opacity", 0.1))
      .call(g => g.append("text")
          .attr("x", -marginLeft * 1.5)
          .attr("y", 0)
          .attr("fill", color5)
          .attr("text-anchor", "start")
          .text(y5Label));

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
      .attr("d", ([, I]) => line4(I));

  const path5 = svg.append("g")
      .attr("fill", "none")
      .attr("stroke", color5)
      .attr("stroke-linecap", strokeLinecap)
      .attr("stroke-linejoin", strokeLinejoin)
      .attr("stroke-width", strokeWidth)
      .attr("stroke-opacity", strokeOpacity)
      .selectAll("path")
      .data(d3.group(I, i => Z[i]))
      .join("path")
      .attr("d", ([, I]) => line5(I));

  const dot1 = svg.append("g")
      .attr("display", "none");
  dot1.append("circle")
    .style("fill", color1)
      .attr("r", 2.5);
  dot1.append("text")
    .style("fill", "currentColor")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "middle")
      .attr("y", -8);

  const dot2 = svg.append("g")
      .attr("display", "none");
  dot2.append("circle")
    .style("fill", color2)
      .attr("r", 2.5);
  dot2.append("text")
    .style("fill", "currentColor")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "middle")
      .attr("y", -8);

  const dot3 = svg.append("g")
      .attr("display", "none");
  dot3.append("circle")
    .style("fill", color3)
      .attr("r", 2.5);
  dot3.append("text")
    .style("fill", "currentColor")
      .attr("font-family", "sans-serif")
      .attr("font-size", 10)
      .attr("text-anchor", "middle")
      .attr("y", -8);

  const dot4 = svg.append("g")
      .attr("display", "none");
  dot4.append("circle")
    .style("fill", color4)
      .attr("r", 2.5);
  dot4.append("text")
    .style("fill", "currentColor")
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

    clearLineStrokes();
    dot1.attr("display", "none");
    dot2.attr("display", "none");
    dot3.attr("display", "none");
    dot4.attr("display", "none");

    if (i1_score < i2_score && i1_score < i3_score && i1_score < i4_score) {
      dot1.attr("display", null);
      // Since path1 is selected/hovered, go full opacity and display it on top
      path1.attr("stroke-opacity", 1.0).raise();
      dot1.attr("transform", `translate(${xScale(X[i1])},${y1Scale(Y1[i1])})`);
      if (T1) dot1.select("text").text(T1[i1]);
      dot1.select("circle").attr("r", 4.0);
    } else if (i2_score < i3_score && i2_score < i4_score) {
      dot2.attr("display", null);
      // Since path2 is selected/hovered, go full opacity and display it on top
      path2.attr("stroke-opacity", 1.0).raise();
      dot2.attr("transform", `translate(${xScale(X[i2])},${y2Scale(Y2[i2])})`);
      if (T2) dot2.select("text").text(T2[i2]);
      dot2.select("circle").attr("r", 4.0);
    } else if (i3_score < i4_score) {
      dot3.attr("display", null);
      // Since path3 is selected/hovered, go full opacity and display it on top
      path3.attr("stroke-opacity", 1.0).raise();
      dot3.attr("transform", `translate(${xScale(X[i3])},${y3Scale(Y3[i3])})`);
      if (T3) dot3.select("text").text(T3[i3]);
      dot3.select("circle").attr("r", 4.0);
    } else {
      dot4.attr("display", null);
      // Since path4 is selected/hovered, go full opacity and display it on top
      path4.attr("stroke-opacity", 1.0).raise();
      dot4.attr("transform", `translate(${xScale(X[i4])},${y4Scale(Y4[i4])})`);
      if (T4) dot4.select("text").text(T4[i4]);
      dot4.select("circle").attr("r", 4.0);
    }
  }

  function clearLineStrokes() {
    path1.attr("stroke-opacity", 0.15);
    path2.attr("stroke-opacity", 0.15);
    path3.attr("stroke-opacity", 0.15);
    path4.attr("stroke-opacity", 0.15);
  }

  function pointerentered() {
    path1.attr("stroke-opacity", 0.15);
    path2.attr("stroke-opacity", 0.15);
    path3.attr("stroke-opacity", 0.15);
    path4.attr("stroke-opacity", 0.15);
    dot1.attr("display", null);
    dot2.attr("display", null);
    dot3.attr("display", null);
    dot4.attr("display", null);
  }

  function pointerleft() {
    path1.attr("stroke-opacity", 1.0);
    path2.attr("stroke-opacity", 1.0);
    path3.attr("stroke-opacity", 1.0);
    path4.attr("stroke-opacity", 1.0);
    dot1.attr("display", "none");
    dot2.attr("display", "none");
    dot3.attr("display", "none");
    dot4.attr("display", "none");
    svg.node().value = null;
    svg.dispatch("input", {bubbles: true});
  }

  return Object.assign(svg.node(), {value: null});
}
