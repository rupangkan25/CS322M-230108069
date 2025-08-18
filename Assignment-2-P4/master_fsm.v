// master_fsm.v
module master_fsm(
    input wire clk,
    input wire rst,    // sync active-high
    input wire ack,
    output reg req,
    output reg [7:0] data,
    output reg done
);
    localparam IDLE=0, ASSERT_REQ=1, WAIT_ACK_DROP=2, NEXT_BYTE=3, DONE=4;
    reg [2:0] state, next_state;
    reg [1:0] idx;

    // Byte ROM
    function [7:0] get_byte(input [1:0] i);
        case(i)
            2'd0: get_byte = 8'hA0;
            2'd1: get_byte = 8'hA1;
            2'd2: get_byte = 8'hA2;
            2'd3: get_byte = 8'hA3;
            default: get_byte = 8'h00;
        endcase
    endfunction

    // Combinational logic
    always @(*) begin
        next_state = state;
        req = 0; done = 0;
        data = get_byte(idx);

        case(state)
            IDLE:        next_state = ASSERT_REQ;
            ASSERT_REQ:  begin req = 1; if (ack) next_state = WAIT_ACK_DROP; end
            WAIT_ACK_DROP: begin if (!ack) next_state = NEXT_BYTE; end
            NEXT_BYTE: begin
                if (idx == 2'd3) next_state = DONE;
                else next_state = ASSERT_REQ;
            end
            DONE: begin done = 1; next_state = IDLE; end
        endcase
    end

    // Sequential logic
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            idx <= 0;
        end else begin
            state <= next_state;
            if (state == WAIT_ACK_DROP && !ack) idx <= idx + 1;
            if (state == DONE) idx <= 0;
        end
    end
endmodule
