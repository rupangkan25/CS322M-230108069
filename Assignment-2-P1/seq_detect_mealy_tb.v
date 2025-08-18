`timescale 1ns/1ps

module tb_seq_detect_mealy;

    reg clk, rst, din;
    wire y;

    // Instantiate DUT
    seq_detect_mealy dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .y(y)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("p1.vcd");
        $dumpvars(0, tb_seq_detect_mealy);

        // Init
        clk = 0;
        rst = 1;
        din = 0;

        // Reset for a little while
        #12 rst = 0;

        // Example input sequence: 1101101 (contains overlapping 1101 twice)
        din = 1; #10;
        din = 1; #10;
        din = 0; #10;
        din = 1; #10;  // first detection here
        din = 1; #10;
        din = 0; #10;
        din = 1; #10;  // second detection here

        #20 $finish;
    end

    // Monitor values(outputs)
    initial begin
        $monitor("Time=%0t | din=%b | y=%b | state_q=%0d",
                  $time, din, y, dut.state_q);
    end

endmodule
