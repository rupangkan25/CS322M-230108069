module vending_mealy(
    input wire clk,
    input wire rst,         // synchronous active-high reset
    input wire [1:0] coin,  // 01=5, 10=10, 00=idle
    output reg dispense,    // 1-cycle pulse
    output reg chg5         // 1-cycle pulse
);

    // State encoding
    parameter S0  = 2'b00;
    parameter S5  = 2'b01;
    parameter S10 = 2'b10;
    parameter S15 = 2'b11;

    reg [1:0] state_q, state_d;

    // Sequential state register
    always @(posedge clk) begin
        if (rst)
            state_q <= S0;
        else
            state_q <= state_d;
    end

    // Next-state + Mealy outputs
    always @(*) begin
        state_d   = state_q;
        dispense  = 0;
        chg5      = 0;

        case (state_q)
            S0: begin
                if (coin == 2'b01) state_d = S5;          // insert 5
                else if (coin == 2'b10) state_d = S10;    // insert 10
            end

            S5: begin
                if (coin == 2'b01) state_d = S10;         // +5
                else if (coin == 2'b10) state_d = S15;    // +10
            end

            S10: begin
                if (coin == 2'b01) state_d = S15;         // +5
                else if (coin == 2'b10) begin             // +10 => 20
                    dispense = 1;
                    state_d  = S0;
                end
            end

            S15: begin
                if (coin == 2'b01) begin                  // +5 => 20
                    dispense = 1;
                    state_d  = S0;
                end
                else if (coin == 2'b10) begin             // +10 => 25
                    dispense = 1;
                    chg5     = 1;
                    state_d  = S0;
                end
            end
        endcase
    end

endmodule
