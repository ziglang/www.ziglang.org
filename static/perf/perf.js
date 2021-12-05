// Load the data, and make the charts
let { benchmark_json, records } = loadData();

const MEASUREMENT_TITLES = {
    cpu_cycles: "CPU Cycles",
    instructions: "CPU Instructions",
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

// Settings
const options = {
    line: "median",
    rangeArea: true,
    yStart: "zero",
    height: 175,
};

// Settings Pane Events
const primaryMeasurementSelect = document.getElementById("primary-measurement");
primaryMeasurementSelect.addEventListener('change', async (event) => {
    options.line = primaryMeasurementSelect.value;
    console.log(options);
    makeCharts(benchmark_json, records);
});

const rangeAreaCheckbox = document.getElementById("range-area");
rangeAreaCheckbox.addEventListener('change', async (event) => {
    options.rangeArea = rangeAreaCheckbox.checked;
    console.log(options);
    makeCharts(benchmark_json, records);
});

const yStartSelect = document.getElementById("y-start");
yStartSelect.addEventListener('change', async (event) => {
    options.yStart = yStartSelect.value;
    console.log(options);
    makeCharts(benchmark_json, records);
});

const chartHeightSlider = document.getElementById("chart-height");
chartHeightSlider.addEventListener('change', async (event) => {
    options.height = chartHeightSlider.value;
    console.log(options);
    makeCharts(benchmark_json, records);
});

// This is called when the data is loaded, to avoid useless reloading of the data/charts
function addDateEventListeners() {
    const startDateInput = document.getElementById('start-date');

    if (startDateInput.getAttribute('hasDateInputListener')) {
        // We've already added the event listeners for the date inputs.
        // Don't add them again, it'll cause duplicates.
        return;
    }

    startDateInput.addEventListener('change', async (event) => {
        console.log("Start date changed to: " + startDateInput.value);
        records = await loadRecords();
        makeCharts(benchmark_json, records);
    });

    const endDateInput = document.getElementById('end-date');

    endDateInput.addEventListener('change', async (event) => {
        console.log("End date changed to: " + endDateInput.value);
        records = await loadRecords();
        makeCharts(benchmark_json, records);
    });

    // Add the flag specifying we've added both event listeners
    startDateInput.setAttribute('hasDateInputListener', 'true');
}

// TODO: Should use this for displaying units
const column_types = {
    timestamp: "date",
    commit_timestamp: "date",
    benchmark_name: "string",
    commit_hash: "string",
    zig_version: "string",
    error_message: "string",
    maxrss: "kb",
    wall_time_median: "ns",
    wall_time_mean: "ns",
    wall_time_min: "ns",
    wall_time_max: "ns",
    utime_median: "ns",
    utime_mean: "ns",
    utime_min: "ns",
    utime_max: "ns",
    stime_median: "ns",
    stime_mean: "ns",
    stime_min: "ns",
    stime_max: "ns",
};

async function loadBenchmarksJSON() {
    const response = await fetch("benchmarks.json");
    const data = await response.json();
    return data;
}

async function loadRecords() {
    // Massage the data
    return await d3.csv("records.csv").then((data) => {
        data.forEach((d) => {
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

        // The order of the sort and timestamp adjustment must be like this, need to understand why.
        data.sort((a, b) => {
            return orderZigVersions(a.zig_version, b.zig_version);
        });

        for (let i = 1; i < data.length; i += 1) {
            if (data[i].commit_timestamp < data[i - 1].commit_timestamp) {
                // Pretend it was done 30 minutes after the previous timestamp.
                data[i].commit_timestamp = new Date((+data[i - 1].commit_timestamp) + (60 * 30));
            }
        }
        const startDateInput = document.getElementById("start-date");
        const endDateInput = document.getElementById("end-date");

        // Set the start and end dates to match the first/last commit dates
        const minDate = data[0].commit_timestamp.toISOString().substring(0, 10);
        const maxDate = data[data.length - 1].commit_timestamp.toISOString().substring(0, 10);
        startDateInput.min = minDate;
        endDateInput.min = minDate;

        // Configure the date inputs now that we know the min/max dates available
        if (!startDateInput.value) {
            startDateInput.value = minDate;
        }
        if (!endDateInput.value) {
            endDateInput.value = maxDate;
        }

        startDateInput.max = maxDate;
        endDateInput.max = maxDate;

        // Add the 'change' event listener AFTER setting the min/max/current dates to avoid reloading everything
        addDateEventListeners();

        data = data.filter(row => {

            // TODO: This needs looked at again. Need to simplify and better understand the issue here
            // Changes may need to be made where we set the date input values instead.
            const startDate = startDateInput.valueAsDate;
            const startDateOffset = startDate.getTimezoneOffset();
            const startDateOffsetMS = startDateOffset * 60_000;
            const localStartDate = new Date(startDate.valueOf() + startDateOffsetMS);
            startDate.setHours(0, 0, 0, 0);

            const endDate = endDateInput.valueAsDate;
            const endDateOffset = endDate.getTimezoneOffset();
            const endDateOffsetMS = endDateOffset * 60_000;
            const localEndDate = new Date(endDate.valueOf() + endDateOffsetMS);
            localEndDate.setHours(23, 59, 59, 999);

            if ( (row.commit_timestamp >= localStartDate) && (row.commit_timestamp <= localEndDate)) {
                return true;
            } else {
                return false;
            }
        });
        return data;
    });
}

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

    const sourceLinkParagraph = document.createElement("p");
    const sourceLinkAnchor = document.createElement("a");
    sourceLinkAnchor.classList.add("external-link");
    sourceLinkAnchor.classList.add("external-link-light");
    const src_url = "https://github.com/ziglang/gotta-go-fast/tree/master/benchmarks/"
        + benchmark.dir + "/" + benchmark.mainPath;
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

async function loadData() {
    console.info("Loading CSV/JSON data.");
    benchmark_json = await loadBenchmarksJSON();
    records = await loadRecords();
    console.info("Data loaded.");
    console.info(`records.csv loaded. It contains ${records.length} records.`);
    console.info(`benchmarks.json file contains ${Object.keys(benchmark_json).length} benchmark metadata objects.`);
    // debugger;
    makeCharts(benchmark_json, records);
}

function makeCharts(benchmark_json, records) {
    Object.keys(benchmark_json).forEach(benchmarkName => {
        createStructureForBenchmark(benchmarkName, benchmark_json[benchmarkName]);

        // Remove the old charts
        const targetChartDiv = document.getElementById("chart-" + benchmarkName);
        while (targetChartDiv.firstChild) {
            targetChartDiv.removeChild(targetChartDiv.firstChild);
        }
        const benchmark_data = records.filter(data => data.benchmark_name == benchmarkName);

        Object.keys(MEASUREMENT_TITLES).forEach(measurement => {
            // debugger;
            drawRangeAreaChart(benchmarkName, measurement, benchmark_data, options, targetChartDiv);
        });
    });
}

function measurementKeyForSelectedOptions(measurement, options) {
    if (measurement == "maxrss") {
        return measurement;
    } else if (options.line == "median") {
        return measurement + "_median";
    } else if (options.line == "mean") {
        return measurement + "_mean";
    } else if (options.line == "minimum") {
        return measurement + "_min";
    } else if (options.line == "maximum") {
        return measurement + "_max";
    }
}

function drawRangeAreaChart(benchmark, measurement, data, options, toNode) {
    const margin = { top: 10, right: 10, bottom: 20, left: 130 };
    const width = toNode.clientWidth;
    const height = options.height;

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
        primaryMeasurementKey = measurement + "_median";
    } else if (options.line == "mean") {
        primaryMeasurementKey = measurement + "_mean";
    } else if (options.line == "minimum") {
        primaryMeasurementKey = measurement + "_min";
    } else if (options.line == "maximum") {
        primaryMeasurementKey = measurement + "_max";
    }

    if (options.rangeArea == false) {
        // If we aren't displaying the area chart with min/max values, we want our min/max to be calculated using the
        // primary measurement, since we're only drawing that line. Otherwise we waste a lot of vertical space showing a larger, but unused range.
        minKey = primaryMeasurementKey;
        maxKey = primaryMeasurementKey;
    }

    const x = d3.scaleTime().range([margin.left, width - margin.right]);
    const yAxisArea = d3.scaleLinear().range([height - margin.bottom, margin.top]);
    const yAxisMin = d3.scaleLinear().range([height - margin.bottom, margin.top]);
    const yAxisMax = d3.scaleLinear().range([height - margin.bottom, margin.top]);
    const yAxisPrimaryMeasurement = d3.scaleLinear().range([height - margin.bottom, margin.top]);
    if (options.yStart == "zero") {
        const DOMAIN = [0, d3.max(data, d => d[maxKey])];
        yAxisPrimaryMeasurement.domain(DOMAIN);
        yAxisArea.domain(DOMAIN);
        yAxisMin.domain(DOMAIN);
        yAxisMax.domain(DOMAIN);
    } else if (options.yStart == "minimum") {
        const DOMAIN = [d3.min(data, d => d[minKey]), d3.max(data, d => d[maxKey])];
        yAxisPrimaryMeasurement.domain(DOMAIN);
        yAxisArea.domain(DOMAIN);
        yAxisMin.domain(DOMAIN);
        yAxisMax.domain(DOMAIN);
    }

    const minLine = d3.line()
        .curve(d3.curveStepAfter)
        .x((data) => {
            return x(data.commit_timestamp);
        })
        .y((data) => {
            return yAxisMin(data[minKey]);
        });
    const maxLine = d3.line()
        // .curve(d3.curveCatmullRom)
        .curve(d3.curveStepAfter)
        .x((data) => {
            return x(data.commit_timestamp);
        })
        .y((data) => {
            return yAxisMax(data[maxKey]);
        });

    const primaryMeasurementLine = d3.line()
        // .curve(d3.curveCatmullRom)
        .curve(d3.curveStepAfter)
        .x((data) => {
            return x(data.commit_timestamp);
        })
        .y((data) => {
            return yAxisPrimaryMeasurement(data[primaryMeasurementKey]);
        });

    const area = d3.area()
        .curve(d3.curveStepAfter)
        // .curve(d3.curveCatmullRom)
        .x((data) => {
            return x(data.commit_timestamp);
        })
        .y0((data) => {
            return yAxisArea(data[minKey]);
        })
        .y1((data) => {
            return yAxisArea(data[maxKey]);
        });

    const svg = d3.create("svg");
    svg
        .attr("width", width)
        .attr("height", height)
        .attr("viewBox", [0, 0, width, height])
        .attr("class", `${benchmark} ${measurement}`)
        .attr("style", "max-width: 100%; height: auto; height: intrinsic;")
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.right + ")");

    x.domain(d3.extent(data, (d) => {
        return d.commit_timestamp;
    }));

    if (options.rangeArea) {
        // Min/Max Range Area
        svg.append("path")
            .data([data])
            .attr("class", `area range`)
            .attr("d", area);

        // Min
        svg.append("path")
            .data([data])
            .attr("transform", "translate(0,0)")
            .attr("class", `line min`)
            .attr("d", minLine);

        // Max
        svg.append("path")
            .data([data])
            .attr("transform", "translate(0,0)")
            .attr("class", `line max`)
            .attr("d", maxLine);
    }

    // Median Line Chart
    svg.append("path")
        .data([data])
        .attr("class", `line primary ${measurement}`)
        // .attr("transform", "translate(" + margin.bottom + "," + margin.left + ")")
        .attr("d", primaryMeasurementLine);

    // Hover circles
    svg.append("g").selectAll("circle").data(data).enter().append("circle")
        .attr("cx", (d) => {
            return x(d.commit_timestamp);
        })
        .attr("cy", (d) => {
            return yAxisArea(d[primaryMeasurementKey]);
        })
        .attr("r", 0)
        .attr("fill", "orange")
        .attr("stroke", "orange")
        .attr("stroke-width", "1px")
        .attr("class", "circle");

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
        .call(g =>
            g.append("text")
                .attr("transform", "rotate(-90)")
                .attr("class", `axis y title`)
                .attr("x", -(height / 2)) // with the -90 degree rotation this becomes the y
                .attr("y", 20) // new x
                .text(getTitle(measurement))
        );

    // Focus indicator group
    const focus = svg.append("g");
    focus.style("display", "none");
    focus.attr("id", "focus");

    // Focus vertical line
    focus
        .append("line")
        .attr("class", "focus line y")
        .attr("id", "focusLine");

    // Focus circle
    focus
        .append("circle")
        .attr("class", "focus circle")
        .attr("id", "focusCircle");

    svg.on("pointerenter", (event, data) => {
        event.preventDefault();
        // Unhide the focus rectangle when the mouse enters the chart
        focus.style("display", null);
    });

    svg
        .on("pointermove", (event, data) => {
            event.preventDefault();
            // Find the commit/data point closest to the mouse
            const commitIndex = commitIndexNearest(d3.pointer(event)[0], d3.pointer(event)[1], x, yAxisPrimaryMeasurement, primaryMeasurementKey, data);

            // Position the focus y line
            const focusLine = focus.select("#focusLine");
            focusLine
                .transition()
                .duration(50)
                .attr("x1", x(data[commitIndex].commit_timestamp))
                .attr("y1", 0)
                .attr("x2", x(data[commitIndex].commit_timestamp))
                .attr("y2", height - margin.bottom);

            // Position the focus circle
            const focusCircle = focus.select("#focusCircle");
            focusCircle
                .transition()
                .duration(50)
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
            event.preventDefault();

            // Show a circle for each data point
            svg.selectAll("circle")
                .transition()
                .duration(50)
                .attr("r", 1);

            // Make sure the tooltip doesn't go off the screen horizontally
            const tooltipNode = document.getElementById("tooltip");
            let tooltipLeft = event.clientX + 30;
            let tooltipTop = event.clientY + 50;

            if (tooltipNode.offsetWidth + tooltipLeft >= document.body.clientWidth) {
                tooltipLeft = document.body.clientWidth - tooltipNode.offsetWidth;
            }

            const tooltip = d3.select("div#tooltip");
            tooltip
                .style("opacity", 1)
                .style("stroke", "black")
                .style("pointer-events", "all")
                .style("left", tooltipLeft.toString() + "px")
                .style("top", tooltipTop.toString() + "px");
        })
        .on("mousedown", (event) => {
            event.preventDefault();
            const i = commitIndexNearest(d3.pointer(event)[0], d3.pointer(event)[1], x, yAxisPrimaryMeasurement, primaryMeasurementKey, data);
            window.open(`https://github.com/ziglang/zig/commit/${data[i].commit_hash}`, "_blank");
        })
        .on("mousemove", (event) => {
            event.preventDefault();

            // Find the commit/data point closest to the mouse
            const i = commitIndexNearest(d3.pointer(event)[0], d3.pointer(event)[1], x, yAxisPrimaryMeasurement, primaryMeasurementKey, data);
            // Get the data for the first, prior, and hovered commit
            const commit = data[i];
            const firstCommit = data[0];
            const priorCommit = data[i - 1];
            // Some bools to check which columns we should show in the tooltips
            const hoveringFirstCommit = (commit === firstCommit);
            const priorCommitAvailable = (priorCommit !== undefined);

            const titleSpanNode = document.querySelector("div#tooltip>div.title>span.benchmark-title");
            titleSpanNode.innerText = benchmark;
            const measurementTitleSpanNode = document.querySelector("div#tooltip>div.title>span.measurement-title");
            measurementTitleSpanNode.innerText = getTitle(measurement) +  " (" + options.line + ")";

            // Add the commit hashes to the table headers. These are hidden right now.
            const currentCommitHashLink = document.getElementById("current-commit-link");
            currentCommitHashLink.href = `https://github.com/ziglang/zig/commit/${commit.commit_hash}`;
            currentCommitHashLink.innerText = commit.commit_hash.substring(0, 7);

            const priorCommitHashLink = document.getElementById("prior-commit-link");
            if (priorCommitAvailable) {
                priorCommitHashLink.href = `https://github.com/ziglang/zig/commit/${priorCommit.commit_hash}`;
                priorCommitHashLink.innerText = priorCommit.commit_hash.substring(0, 7);
            } else {
                priorCommitHashLink.href = ``;
                priorCommitHashLink.innerText = "";

            }

            const firstCommitHashLink = document.getElementById("first-commit-link");
            firstCommitHashLink.href = `https://github.com/ziglang/zig/commit/${firstCommit.commit_hash}`;
            firstCommitHashLink.innerText = firstCommit.commit_hash.substring(0, 7);

            const tbodyNode = document.querySelector("div#tooltip>div>table>tbody#tooltip-measurements-table-body");

            // Remove old benchmark rows
            while (tbodyNode.firstChild) {
                tbodyNode.removeChild(tbodyNode.firstChild);
            }

            // Iterate over the measurements and dump them out as rows
            Object.keys(MEASUREMENT_TITLES).forEach(measurement => {
                // Add row with the measurement title
                const tr = document.createElement("tr");
                const tdMeasurementName = document.createElement("td");
                tdMeasurementName.classList.add("measurement-title");
                tdMeasurementName.innerText = MEASUREMENT_TITLES[measurement];
                tr.appendChild(tdMeasurementName);

                const measurementKey = measurementKeyForSelectedOptions(measurement, options);

                // Add row with the current measurement value
                const tdCurrentMeasurementValue = document.createElement("td");
                tdCurrentMeasurementValue.classList.add("measurement-value");
                tdCurrentMeasurementValue.innerText = d3.format(",")(commit[measurementKey]);
                tr.appendChild(tdCurrentMeasurementValue);

                if (priorCommitAvailable) {
                // Add row with the previous measurement value
                const vsPriorChange = commit[measurementKey] - priorCommit[measurementKey];
                const vsPriorChangePercentage = vsPriorChange / priorCommit[measurementKey];
                const tdPriorMeasurementValue = document.createElement("td");
                tdPriorMeasurementValue.classList.add("measurement-value");
                tdPriorMeasurementValue.innerText += ` ${d3.format(".2%")(vsPriorChangePercentage)}`;
                tdPriorMeasurementValue.classList.add(Math.sign(vsPriorChangePercentage) == 1 ? "bad" : "good");
                // tdPriorMeasurementValue.style = `background-color: ${d3.interpolateInferno(vsPriorChangePercentage)}`
                tr.appendChild(tdPriorMeasurementValue);
            } else {
                const td = document.createElement("td");
                tr.appendChild(td);
            }

            if (hoveringFirstCommit === false) {
                // Add row with the first measurement value
                const vsFirstChange = commit[measurementKey] - firstCommit[measurementKey];
                const vsFirstChangePercentage = vsFirstChange / firstCommit[measurementKey];
                const tdFirstMeasurementValue = document.createElement("td");
                tdFirstMeasurementValue.classList.add("measurement-value");
                tdFirstMeasurementValue.innerText += ` ${d3.format(".2%")(vsFirstChangePercentage)}`;

                // Add a CSS class so we can put nice +/- arrow indicators on the measurement
                if (Math.sign(vsFirstChangePercentage) === 1) {
                    // Increase is bad!
                    tdFirstMeasurementValue.classList.add("bad");
                } else if (Math.sign(vsFirstChangePercentage) === -1) {
                    // Decrease is good!
                    tdFirstMeasurementValue.classList.add("good");
                } else {
                    // Input was -0 or 0, so no change
                    tdFirstMeasurementValue.innerText = `0%`;
                }

                tr.appendChild(tdFirstMeasurementValue);
            } else {
                const td = document.createElement("td");
                tr.appendChild(td);
            }

                // Add the new row for the measurement
                tbodyNode.appendChild(tr);
            });

            // Add row with the sample counts
            const tr = document.createElement("tr");
            const tdBenchmarkSampleCountTitle = document.createElement("td");
            tdBenchmarkSampleCountTitle.classList.add("measurement-title");
            tdBenchmarkSampleCountTitle.innerText = "Samples Taken";
            tr.appendChild(tdBenchmarkSampleCountTitle);

            const tdCurrentBenchmarkSampleCount = document.createElement("td");
            tdCurrentBenchmarkSampleCount.innerText = d3.format(",")(commit.samples_taken);
            tr.appendChild(tdCurrentBenchmarkSampleCount);

            if (priorCommitAvailable) {
                const tdPriorBenchmarkSampleCount = document.createElement("td");
                tdPriorBenchmarkSampleCount.innerText = d3.format(",")(priorCommit.samples_taken);
                tr.appendChild(tdPriorBenchmarkSampleCount);
            } else {
                const td = document.createElement("td");
                tr.appendChild(td);
            }

            if (hoveringFirstCommit === false) {
                const tdFirstBenchmarkSampleCount = document.createElement("td");
                tdFirstBenchmarkSampleCount.innerText = d3.format(",")(firstCommit.samples_taken);
                tr.appendChild(tdFirstBenchmarkSampleCount);
            } else {
                const td = document.createElement("td");
                tr.appendChild(td);
            }

            tbodyNode.appendChild(tr);
            // TODO: Add a divider of some kind here

            // Add row with the commit hashes
            const trCommitHashes = document.createElement("tr");
            const tdCommitHashTitle = document.createElement("td");
            tdCommitHashTitle.classList.add("measurement-title");
            tdCommitHashTitle.innerText = "Commit Hash";
            trCommitHashes.appendChild(tdCommitHashTitle);

            const tdCurrentCommitHash = document.createElement("td");
            const currentCommitLink = document.createElement("a");
            currentCommitLink.href = `https://github.com/ziglang/zig/commit/${commit.commit_hash}`;
            currentCommitLink.innerText = commit.commit_hash.substring(0, 7);
            tdCurrentCommitHash.appendChild(currentCommitLink);
            trCommitHashes.appendChild(tdCurrentCommitHash);

            if (priorCommitAvailable) {
                const tdPriorCommitHash = document.createElement("td");
                const priorCommitLink = document.createElement("a");
                priorCommitLink.href = `https://github.com/ziglang/zig/commit/${priorCommit.commit_hash}`;
                priorCommitLink.innerText = priorCommit.commit_hash.substring(0, 7);
                tdPriorCommitHash.appendChild(priorCommitLink);
                trCommitHashes.appendChild(tdPriorCommitHash);
            } else {
                const td = document.createElement("td");
                trCommitHashes.appendChild(td);
            }

            if (hoveringFirstCommit === false) {
                const tdFirstCommitHash = document.createElement("td");
                const firstCommitLink = document.createElement("a");
                firstCommitLink.href = `https://github.com/ziglang/zig/commit/${firstCommit.commit_hash}`;
                firstCommitLink.innerText = firstCommit.commit_hash.substring(0, 7);
                tdFirstCommitHash.appendChild(firstCommitLink);
                trCommitHashes.appendChild(tdFirstCommitHash);
            } else {
                const td = document.createElement("td");
                trCommitHashes.appendChild(td);
            }

            tbodyNode.appendChild(trCommitHashes);

            // Add row with the commit date
            const trCommitDates = document.createElement("tr");
            const tdCommitDateTitle = document.createElement("td");
            tdCommitDateTitle.classList.add("measurement-title");
            tdCommitDateTitle.innerText = "Committed";
            trCommitDates.appendChild(tdCommitDateTitle);

            const currentCommitDate = new Date(commit.commit_timestamp);
            const tdCurrentCommitDate = document.createElement("td");
            const tdCurrentCommitDateDateP = document.createElement("p");
            tdCurrentCommitDateDateP.innerText = currentCommitDate.toLocaleDateString("en-US");
            tdCurrentCommitDate.appendChild(tdCurrentCommitDateDateP);
            const tdCurrentCommitDateTimeP = document.createElement("p");
            tdCurrentCommitDateTimeP.innerText = currentCommitDate.toLocaleTimeString("en-US");
            tdCurrentCommitDate.appendChild(tdCurrentCommitDateTimeP);
            trCommitDates.appendChild(tdCurrentCommitDate);

            if (priorCommitAvailable) {
                const priorCommitDate = new Date(priorCommit.commit_timestamp);
                const tdPriorCommitDate = document.createElement("td");
                const tdPriorCommitDateDateP = document.createElement("p");
                tdPriorCommitDateDateP.innerText = priorCommitDate.toLocaleDateString("en-US");
                tdPriorCommitDate.appendChild(tdPriorCommitDateDateP);
                const tdPriorCommitDateTimeP = document.createElement("p");
                tdPriorCommitDateTimeP.innerText = priorCommitDate.toLocaleTimeString("en-US");
                tdPriorCommitDate.appendChild(tdPriorCommitDateTimeP);
                trCommitDates.appendChild(tdPriorCommitDate);
            } else {
                const td = document.createElement("td");
                trCommitDates.appendChild(td);
            }

            if (hoveringFirstCommit === false) {
                const firstCommitDate = new Date(firstCommit.commit_timestamp);
                const tdFirstCommitDate = document.createElement("td");
                const tdFirstCommitDateDateP = document.createElement("p");
                tdFirstCommitDateDateP.innerText = firstCommitDate.toLocaleDateString("en-US");
                tdFirstCommitDate.appendChild(tdFirstCommitDateDateP);
                const tdFirstCommitDateTimeP = document.createElement("p");
                tdFirstCommitDateTimeP.innerText = firstCommitDate.toLocaleTimeString("en-US");
                tdFirstCommitDate.appendChild(tdFirstCommitDateTimeP);
                trCommitDates.appendChild(tdFirstCommitDate);
            } else {
                const td = document.createElement("td");
                trCommitDates.appendChild(td);
            }

            tbodyNode.appendChild(trCommitDates);

            // // Add row with the zig version
            const trZigVersions = document.createElement("tr");
            const tdZigVersionTitle = document.createElement("td");
            tdZigVersionTitle.classList.add("measurement-title");
            tdZigVersionTitle.innerText = "Zig Version";
            trZigVersions.appendChild(tdZigVersionTitle);

            const tdCurrentZigVersion = document.createElement("td");
            tdCurrentZigVersion.innerText = commit.zig_version.split("+")[0];
            trZigVersions.appendChild(tdCurrentZigVersion);

            if (priorCommitAvailable) {
                const tdPriorZigVersion = document.createElement("td");
                tdPriorZigVersion.innerText = priorCommit.zig_version.split("+")[0];
                trZigVersions.appendChild(tdPriorZigVersion);
            } else {
                const td = document.createElement("td");
                trZigVersions.appendChild(td);
            }

            if (hoveringFirstCommit === false) {
                const tdFirstZigVersion = document.createElement("td");
                tdFirstZigVersion.innerText = firstCommit.zig_version.split("+")[0];
                trZigVersions.appendChild(tdFirstZigVersion);
            } else {
                const td = document.createElement("td");
                trZigVersions.appendChild(td);
            }

            tbodyNode.appendChild(trZigVersions);

            // Make sure the tooltip doesn't go off the screen horizontally
            const tooltipNode = document.getElementById("tooltip");
            let tooltipLeft = event.clientX + 30;
            let tooltipTop = event.clientY + 50;

            if (tooltipNode.offsetWidth + tooltipLeft >= document.body.clientWidth) {
                tooltipLeft = document.body.clientWidth - tooltipNode.offsetWidth;
            }

            const tooltip = d3.select("div#tooltip");
            tooltip
                .transition()
                .duration(50)
                .style("left", tooltipLeft.toString() + "px")
                .style("top", tooltipTop.toString() + "px");
        })
        .on("mouseleave", (event) => {
            event.preventDefault();

            // Hide circles for each data point
            svg.selectAll("circle")
                .transition()
                .duration(50)
                .attr("r", 0);

            const tooltip = d3.select("div#tooltip");
            tooltip
                .style("opacity", 0.0)
                .style("pointer-events", "none");
        });

    toNode.appendChild(svg.node());

    function commitIndexNearest(mouseX, mouseY, xScaleFunction, yScaleFunction, primaryMeasurementKey, data) {
        // Calculate the closest point to the x/y coordinates provided.
        const distances = data.map((row, index) => { 
            const dataPointX = xScaleFunction(row.commit_timestamp);
            const dataPointY = yScaleFunction(row[primaryMeasurementKey]);
            return {distance: distance(mouseX, mouseY, dataPointX, dataPointY), commitIndex: index};
        });

        distances.sort((a, b) => {
            if (a.distance > b.distance) {
                return 1;
            } else if (a.distance < b.distance) {
                return -1;
            } else {
                return 0;
            }
        });

        return distances[0].commitIndex;
    }

    function distance(x1, y1, x2, y2) {
        return Math.hypot(x2 - x1, y2 - y1);
    }
}
