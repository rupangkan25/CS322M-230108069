`timescale 1ns/1ps

module tb_traffic_light;

    reg clk, rst, tick;
    wire ns_g, ns_y, ns_r, ew_g, ew_y, ew_r;

    // DUT
    traffic_light dut (
        .clk(clk), .rst(rst), .tick(tick),
        .ns_g(ns_g), .ns_y(ns_y), .ns_r(ns_r),
        .ew_g(ew_g), .ew_y(ew_y), .ew_r(ew_r)
    );

    // Clock generator
    always #5 clk = ~clk; // 100 MHz simulation clock

    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);

        clk = 0; rst = 1; tick = 0;
        #20 rst = 0;

        // Generate 1 Hz tick (simulate with 50 cycles)
        repeat (40) begin
            #50 tick = 1;
            #10 tick = 0;
        end

        #100 $finish;
    end

endmodule
