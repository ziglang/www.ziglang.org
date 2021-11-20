---
title: Performance Tracking
type: "perf"
mobile_menu_title: "Performance Tracking"
---

This project exists to track various benchmarks related to the Zig project regarding execution speed, memory usage, throughput, and other resource utilization statistics. 

The goal is to prevent performance regressions, and provide understanding and exposure to how various code changes affect key measurements.
<div id="tooltip" class="tooltip">
	<p class="title"><span class="benchmark-title"></span> > <span class="measurement-title"></span></p>
	<p class="date">Date here</p>
	<p class="commit"><a href="">Commit Here</a></p>
	<p class="samples">Samples: <span class="samples_count metric"></span></p>
	<p class="zig-version">Version: <span class="zig-version"></span></p>
	<p class="measurement"><span class="measurement-title"></span>: <span class="measurement-value"></span> <span class="measurement-difference"></span></p>
</div>
<script src="https://cdn.jsdelivr.net/npm/tweakpane@3.0.5/dist/tweakpane.min.js"></script>
<script type="text/javascript" src="d3-7.1.1.min.js"></script>
<script type="text/javascript" src="perf.js"></script>