`timescale 1ns/1ps

module tb_vending_mealy;

    reg clk, rst;
    reg [1:0] coin;
    wire dispense, chg5;

    // DUT
    vending_mealy dut (
        .clk(clk),
        .rst(rst),
        .coin(coin),
        .dispense(dispense),
        .chg5(chg5)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz simulation

    initial begin
        $dumpfile("vending_mealy.vcd");
        $dumpvars(0, tb_vending_mealy);

        clk = 0; rst = 1; coin = 2'b00;
        #15 rst = 0;

        // Insert 5 + 5 + 10 = 20 → should vend
        #10 coin = 2'b01; #10 coin = 2'b00; 
        #10 coin = 2'b01; #10 coin = 2'b00;
        #10 coin = 2'b10; #10 coin = 2'b00;

        // Insert 10 + 10 = 20 → should vend
        #10 coin = 2'b10; #10 coin = 2'b00;
        #10 coin = 2'b10; #10 coin = 2'b00;

        // Insert 15 + 10 = 25 → vend + change
        #10 coin = 2'b10; #10 coin = 2'b00;
        #10 coin = 2'b01; #10 coin = 2'b00;
        #10 coin = 2'b10; #10 coin = 2'b00;

        #50 $finish;
    end

endmodule
