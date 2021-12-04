---
title: Performance Tracking
type: "perf"
mobile_menu_title: "Performance Tracking"
---

<div id="perf-settings" class="perf-settings">
	<div class="content">
		<div>
			<div class="title"></div>
			<span class="primary-measurement">
				<label for="primary-measurement">Primary Measurement:</label>
				<select name="primary-measurement" id="primary-measurement">
					<option value="median" selected>Median</option>
					<option value="mean">Mean</option>
					<option value="minimum">Min</option>
					<option value="maximum">Max</option>
				</select>
			</span>
			<span class="range-area">
				<input type="checkbox" id="range-area" name="range-area"
				checked>
				<label for="ranged-area">Show Range Area</label>
			</span>
			<span class="y-start">
				<label for="y-start">Y Start:</label>
				<select name="y-start" id="y-start">
					<option value="zero">0</option>
					<option value="minimum" selected>Min. Value</option>
				</select>
			</span>
			<span class="chart-height">
				<label for="chart-height">Chart Height:</label>
				<input type="range" min="100" max="1000" value="175" id="chart-height">
			</span>
		</div>
		<div>
			<div class="title"></div>
			<span class="start-date">
				<label for="start">Start:</label>
				<input type="date" id="start-date" name="start"
				min="2021-08-01">
			</span>
			<span class="end-date">
				<label for="end">End:</label>
				<input type="date" id="end-date" name="end" min="2021-08-01">
			</span>
		</div>
	</div>
</div>

This project exists to track various benchmarks related to the Zig project regarding execution speed, memory usage, throughput, and other resource utilization statistics. 

The goal is to prevent performance regressions, and provide understanding and exposure to how various code changes affect key measurements.
<div id="tooltip" class="tooltip">
	<div class="title">
	<span class="benchmark-title"></span> > <span class="measurement-title"></span>
</div>
	<div class="contents">
		<table class="benchmarks">
		<thead>
			<tr>
				<th></th>
				<th><a href="">Hovered commit</a><br /><span class="commit"><a id="current-commit-link" href=""></a></span></th>
				<th><a href="">vs. previous</a><br /><span class="commit"><a id="prior-commit-link" href=""></a></span></th>
				<th><a href="">vs. first</a><br /><span class="commit"><a id="first-commit-link" href=""></a></span></th>
			</tr>
		</thead>
		<tbody id="tooltip-measurements-table-body">
			<tr>
				<td>CPU Cycles</td>
				<td class="cpu_cycles this"></td>
				<span class="cpu_cycles previous change"></span>
				<td class="cpu_cycles first change"></td>
			</tr>
			<tr>
				<td>CPU Instructions</td>
				<td class="cpu_cycles this"></td>
				<td class="cpu_cycles previous change"></td>
				<td class="cpu_cycles first change"></td>
			</tr>
			<tr>
				<td>Cache References</td>
				<td class="cache_references this"></td>
				<td class="cache_references previous change"></td>
				<td class="cache_references first change"></td>
			</tr>
			<tr>
				<td>Cache Misses</td>
				<td class="cache_misses this"></td>
				<td class="cache_misses previous change"></td>
				<td class="cache_misses first change"></td>
			</tr>
			<tr>
				<td>Wall Time</td>
				<td class="wall_time this"></td>
				<td class="wall_time previous change"></td>
				<td class="wall_time first change"></td>
			</tr>
			<tr>
				<td>User-Space Time</td>
				<td class="utime this"></td>
				<td class="utime previous change"></td>
				<td class="utime first change"></td>
			</tr>
			<tr>
				<td>Kernel Time</td>
				<td class="stime this"></td>
				<td class="stime previous change"></td>
				<td class="stime first change"></td>
			</tr>
			<tr>
				<td>Max RSS</td>
				<td class="maxrss this"></td>
				<td class="maxrss previous change"></td>
				<td class="maxrss first change"></td>
			</tr>
			<tr>
				<td>Branch Misses</td>
				<td class="branch_misses this"></td>
				<td class="branch_misses previous change"></td>
				<td class="branch_misses first change"></td>
			</tr>
			<tr>
				<td>Samples</td>
				<td class="samples_count this"></td>
				<td class="samples_count previous change"></td>
				<td class="samples_count first change"></td>
			</tr>
		</tbody>
		</table>
	</div>
</div>
<script type="text/javascript" src="d3-7.1.1.min.js"></script>
<script type="text/javascript" src="perf.js"></script>