// tb_link_top.v
`timescale 1ns/1ps

module tb_link_top;
    reg clk, rst;
    wire done;

    // Instantiate DUT (top module with master + slave)
    link_top dut(
        .clk(clk),
        .rst(rst),
        .done(done)
    );

    // Clock generation: 10ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // VCD dumping
    initial begin
        $dumpfile("waves_link.vcd");           // new VCD file
        $dumpvars(0, tb_link_top);             // dump testbench
        $dumpvars(0, tb_link_top.dut);         // dump DUT
        $dumpvars(0, tb_link_top.dut.u_master); // dump master FSM
        $dumpvars(0, tb_link_top.dut.u_slave);  // dump slave FSM
    end

    // Reset + simulation control
    initial begin
        // Apply reset
        rst = 1;
        repeat (2) @(posedge clk);
        rst = 0;

        // Run for 200 cycles max
        repeat (200) @(posedge clk);

        $display("Simulation finished at time %0t", $time);
        $finish;
    end

    // Console debug output
    initial begin
        $monitor("t=%0t : req=%b ack=%b data=%h done=%b",
                  $time,
                  dut.u_master.req,
                  dut.u_slave.ack,
                  dut.u_master.data,
                  dut.u_master.done);
    end
endmodule
