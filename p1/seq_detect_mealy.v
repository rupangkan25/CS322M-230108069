module seq_detect_mealy (
    input  wire clk,
    input  wire rst,    // sync active-high
    input  wire din,    // serial input bit per clock
    output reg  y       // 1-cycle pulse when pattern ...1101 seen
);

    localparam [1:0] IDLE          = 2'd0, // waiting for '1'
                     GOT1          = 2'd1, // seen '1'
                     GOT11         = 2'd2, // seen "11"
                     GOT110        = 2'd3; // seen "110"

    reg [1:0] state_q, state_d; // present and next state

    // Next-state logic and Mealy output
    always @(*) begin
        state_d = state_q;
        y = 1'b0;

        case (state_q)
            IDLE: begin
                if (din) state_d = GOT1;
                else     state_d = IDLE;
            end

            GOT1: begin
                if (din) state_d = GOT11;
                else     state_d = IDLE;
            end

            GOT11: begin
                if (din) state_d = GOT11;   // "111" still contains suffix "11"
                else     state_d = GOT110;
            end

            GOT110: begin
                if (din) begin
                    y       = 1'b1;    // detected 1101
                    state_d = GOT1;    // last '1' may start a new match
                end
                else begin
                    state_d = IDLE;
                end
            end
        endcase
    end

    // State register (synchronous active-high reset)
    always @(posedge clk) begin
        if (rst) begin
            state_q <= IDLE;
        end
        else begin
            state_q <= state_d;
        end
    end

endmodule