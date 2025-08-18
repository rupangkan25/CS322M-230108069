module traffic_light(
    input wire clk,
    input wire rst,   // synchronous active-high reset
    input wire tick,  // 1 Hz tick pulse
    output reg ns_g, ns_y, ns_r,
    output reg ew_g, ew_y, ew_r
);

    // State encoding (binary)
    parameter NS_GREEN  = 2'b00;
    parameter NS_YELLOW = 2'b01;
    parameter EW_GREEN  = 2'b10;
    parameter EW_YELLOW = 2'b11;

    reg [1:0] state_q, state_d;
    reg [3:0] tick_count_q, tick_count_d;

    // State duration constants
    parameter NS_G_TIME = 5;
    parameter NS_Y_TIME = 2;
    parameter EW_G_TIME = 5;
    parameter EW_Y_TIME = 2;

    // Sequential: state & counter update
    always @(posedge clk) begin
        if (rst) begin
            state_q <= NS_GREEN;
            tick_count_q <= 0;
        end else begin
            state_q <= state_d;
            tick_count_q <= tick_count_d;
        end
    end

    // Next-state logic
    always @(*) begin
        state_d = state_q;
        tick_count_d = tick_count_q;

        if (tick) begin
            tick_count_d = tick_count_q + 1;
            case (state_q)
                NS_GREEN:  if (tick_count_q == NS_G_TIME-1) begin
                               state_d = NS_YELLOW;
                               tick_count_d = 0;
                           end
                NS_YELLOW: if (tick_count_q == NS_Y_TIME-1) begin
                               state_d = EW_GREEN;
                               tick_count_d = 0;
                           end
                EW_GREEN:  if (tick_count_q == EW_G_TIME-1) begin
                               state_d = EW_YELLOW;
                               tick_count_d = 0;
                           end
                EW_YELLOW: if (tick_count_q == EW_Y_TIME-1) begin
                               state_d = NS_GREEN;
                               tick_count_d = 0;
                           end
            endcase
        end
    end

    // Moore outputs
    always @(*) begin
        ns_g=0; ns_y=0; ns_r=0;
        ew_g=0; ew_y=0; ew_r=0;

        case (state_q)
            NS_GREEN:  begin ns_g=1; ew_r=1; end
            NS_YELLOW: begin ns_y=1; ew_r=1; end
            EW_GREEN:  begin ew_g=1; ns_r=1; end
            EW_YELLOW: begin ew_y=1; ns_r=1; end
        endcase
    end

endmodule
