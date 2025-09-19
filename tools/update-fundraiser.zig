const std = @import("std");

const zero_raised = 3405;
const ziggy_raised = 6863;
const carmen_raised = 2139;
const current_day = 19;
const days = 30;
const days_left: comptime_float = days - current_day;
const max_raised: comptime_float = @max(zero_raised, ziggy_raised, carmen_raised);
const max_day_avg = max_raised / @as(comptime_float, current_day);
const denominator: comptime_float = max_day_avg * days;
const zero_percent = (@as(comptime_float, zero_raised) / denominator) * 100.0;
const ziggy_percent = (@as(comptime_float, ziggy_raised) / denominator) * 100.0;
const carmen_percent = (@as(comptime_float, carmen_raised) / denominator) * 100.0;

var stdout_buffer: [4096]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writerStreaming(&stdout_buffer);

pub fn main() !void {
    const w = &stdout_writer.interface;

    try w.writeAll(
        \\<div class="fundraiser">
        \\  <script async defer src="https://embeds.every.org/0.4/button.js?explicit=1" id="every-donate-btn-js"></script>
        \\  <div class="fundraiser-heading">
        \\    <strong>ZSF Needs Money!</strong>
        \\    <a href="/news/2025-financials/#back">2025 Financial Report and Fundraiser</a> 
        \\  </div>
        \\  <div class="container" style="flex-direction:column;">
        \\
    );

    try w.writeAll(
        \\  <div id="every-donate-btn-zero" class="mascot">
        \\    <a href="https://www.every.org/zig-software-foundation-inc?utm_campaign=2025_financials#/donate">Donate</a>
        \\    <img src="https://ziglang.org/img/Zero_3.svg" style="height:7em;aspect-ratio:1/1;">
        \\    <script>
        \\      function createWidgetNav() {
        \\        everyDotOrgDonateButton.createButton({
        \\          selector: "#every-donate-btn-zero",
        \\          nonprofitSlug: "zig-software-foundation-inc",
        \\          fundraiserSlug: "zeros-fundraiser",
        \\          fontSize: "24px",
        \\          label: "Sponsor"
        \\        });
        \\        everyDotOrgDonateButton.createWidget({
        \\          selector: "#every-donate-btn-zero",
        \\          nonprofitSlug: "zig-software-foundation-inc",
        \\          fundraiserSlug: "zeros-fundraiser",
        \\          defaultDonationAmount: 10,
        \\          defaultFrequency: 'monthly'
        \\        });
        \\      }
        \\      if (window.everyDotOrgDonateButton) {
        \\        createWidgetNav();
        \\      } else {
        \\        document.getElementById("every-donate-btn-js").addEventListener("load", createWidgetNav);
        \\      }
        \\    </script>
        \\
    );

    try w.print(
        \\    <div class="progress" data-label=" ${d} raised">
        \\      <span class="value" style="width:{d:0.2}%;"></span>
        \\    </div>
        \\  </div>
        \\
    , .{ zero_raised, zero_percent });

    try w.writeAll(
        \\  <div id="every-donate-btn-ziggy" class="mascot">
        \\    <a href="https://www.every.org/zig-software-foundation-inc?utm_campaign=2025_financials#/donate">Donate</a>
        \\    <img src="https://ziglang.org/img/Ziggy_10.svg" style="height:7em;aspect-ratio:1/1;">
        \\    <script>
        \\      function createWidgetNav() {
        \\        everyDotOrgDonateButton.createButton({
        \\          selector: "#every-donate-btn-ziggy",
        \\          nonprofitSlug: "zig-software-foundation-inc",
        \\          fundraiserSlug: "ziggys-fundraiser",
        \\          fontSize: "24px",
        \\          label: "Sponsor"
        \\        });
        \\        everyDotOrgDonateButton.createWidget({
        \\          selector: "#every-donate-btn-ziggy",
        \\          nonprofitSlug: "zig-software-foundation-inc",
        \\          fundraiserSlug: "ziggys-fundraiser",
        \\          defaultDonationAmount: 10,
        \\          defaultFrequency: 'monthly'
        \\        });
        \\      }
        \\      if (window.everyDotOrgDonateButton) {
        \\        createWidgetNav();
        \\      } else {
        \\        document.getElementById("every-donate-btn-js").addEventListener("load", createWidgetNav);
        \\      }
        \\    </script>
        \\
    );

    try w.print(
        \\    <div class="progress" data-label=" ${d} raised">
        \\      <span class="value" style="width:{d:0.2}%;"></span>
        \\    </div>
        \\  </div>
        \\
    , .{ ziggy_raised, ziggy_percent });

    try w.writeAll(
        \\  <div id="every-donate-btn-carmen" class="mascot">
        \\    <a href="https://www.every.org/zig-software-foundation-inc?utm_campaign=2025_financials#/donate">Donate</a>
        \\    <img src="https://ziglang.org/img/Carmen_2.svg" style="height:7em;aspect-ratio:1/1;">
        \\    <script>
        \\      function createWidgetNav() {
        \\        everyDotOrgDonateButton.createButton({
        \\          selector: "#every-donate-btn-carmen",
        \\          nonprofitSlug: "zig-software-foundation-inc",
        \\          fundraiserSlug: "carmens-fundraiser",
        \\          fontSize: "24px",
        \\          label: "Sponsor"
        \\        });
        \\        everyDotOrgDonateButton.createWidget({
        \\          selector: "#every-donate-btn-carmen",
        \\          nonprofitSlug: "zig-software-foundation-inc",
        \\          fundraiserSlug: "carmens-fundraiser",
        \\          defaultDonationAmount: 10,
        \\          defaultFrequency: 'monthly'
        \\        });
        \\      }
        \\      if (window.everyDotOrgDonateButton) {
        \\        createWidgetNav();
        \\      } else {
        \\        document.getElementById("every-donate-btn-js").addEventListener("load", createWidgetNav);
        \\      }
        \\    </script>
        \\
    );

    try w.print(
        \\    <div class="progress" data-label=" ${d} raised">
        \\      <span class="value" style="width:{d:0.2}%;"></span>
        \\    </div>
        \\  </div>
        \\
    , .{ carmen_raised, carmen_percent });

    try w.writeAll(
        \\  <div style="clear:both">&nbsp;</div>
        \\  </div>
        \\
        \\  <div class="fundraiser-trailer">
        \\    Which mascot will win? <strong>You decide!</strong>
        \\  </div>
        \\
    );

    try w.print(
        \\  <div class="fundraiser-trailer">
        \\    {d} days remaining.
        \\  </div>
        \\</div> 
        \\
    , .{days_left});

    try w.flush();
}
