// slave_fsm.v
module slave_fsm(
    input wire clk,
    input wire rst,
    input wire req,
    input wire [7:0] data_in,
    output reg ack,
    output reg [7:0] last_byte
);
    localparam WAIT_REQ=0, ASSERT_ACK=1, HOLD_ACK=2, DROP_ACK=3;
    reg [1:0] state, next_state;

    always @(*) begin
        next_state = state;
        ack = 0;
        case(state)
            WAIT_REQ: if (req) next_state = ASSERT_ACK;
            ASSERT_ACK: begin ack = 1; next_state = HOLD_ACK; end
            HOLD_ACK:  begin ack = 1; next_state = DROP_ACK; end
            DROP_ACK:  if (!req) next_state = WAIT_REQ;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= WAIT_REQ;
            last_byte <= 8'h00;
        end else begin
            state <= next_state;
            if (state == WAIT_REQ && req) last_byte <= data_in; // latch data
        end
    end
endmodule
