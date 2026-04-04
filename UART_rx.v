module uart_rx #(
    parameter clk_freq = 50000000,
    parameter baud_rate = 9600
)(
    input wire clk,
    input wire reset,
    input wire rx,
    output reg[7:0] data_out,
    output reg rx_done
);
    localparam clks_per_bit = clk_freq/baud_rate;
    localparam half_bit = clks_per_bit/2;

    parameter idle = 3'b000;
    parameter start = 3'b001;
    parameter data = 3'b010;
    parameter stop = 3'b011;
    parameter clear = 3'b100;

    reg[2:0] state,next_state;
    reg[$clog2(clks_per_bit)-1:0]clk_counter, next_clk_counter;
    reg [2:0]bit_index,next_bit_index;
    reg [7:0]rx_datashift,next_rx_datashift;

    // sequential block

    always@(posedge clk or negedge reset)begin
        if(~reset)begin
            state <= idle;
            data_out <= 0;
            clk_counter <=0;
            bit_index <= 0;
            rx_done <= 0;
        end
        else begin
            state <= next_state;
            clk_counter <= next_clk_counter;
            bit_index <= next_bit_index;
            rx_datashift <= next_rx_datashift;
            rx_done <= 0;
            if(state == clear)begin
                rx_done <=1;
            end
            if(state == stop && next_state == clear)begin
                data_out <= rx_datashift;
            end
        end
    end

    // combinational block

    always@(*)begin
        next_bit_index = bit_index;
        next_clk_counter = clk_counter;
        next_rx_datashift = rx_datashift;
        next_state = state;

        case(state)
            idle : begin
                next_clk_counter = 0;
                next_bit_index = 0;
                if(rx == 0)begin
                    next_state = start;
                end
            end
            start : begin
                if(clk_counter == half_bit)begin
                    next_clk_counter = 0;
                    if(rx == 0)begin
                        next_state = data;
                    end
                    else begin
                        next_state = idle;
                    end
                end
                else begin
                    next_clk_counter = clk_counter+1;
                end
            end
            data : begin
                if(clk_counter == clks_per_bit-1)begin
                    next_clk_counter = 0;
                    next_rx_datashift[bit_index] = rx;

                    if(bit_index == 7)begin
                        next_bit_index = 0;
                        next_state = stop;
                    end
                    else begin
                        next_bit_index = bit_index+1;
                    end
                end
                else begin
                    next_clk_counter = clk_counter +1;
                end
            end
            stop : begin
                if(clk_counter == clks_per_bit-1)begin
                    next_clk_counter = 0;
                    next_state = clear;
                end
                else begin
                    next_clk_counter = clk_counter+1;
                end
            end
            clear : begin
                next_state = idle;
            end
        endcase
    end

endmodule