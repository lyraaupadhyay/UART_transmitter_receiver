module uart #(
        parameter clk_freq = 50000000,
        parameter baud_rate = 9600
    ) (
        input wire clk,
        input wire reset,
        output reg baud_tick
    );
    // clocks per bit
    localparam   clk_per_bit = clk_freq/baud_rate ; 

    //width of clk counter
    reg [$clog2(clk_per_bit)-1:0] clk_counter;

    always@(posedge clk or negedge reset) begin
        if(~reset)begin
            clk_counter <= 0;
            baud_tick <= 1;
        end
        else begin
            if(clk_counter == clk_per_bit -1)begin
                clk_counter <= 0;
                baud_tick <= 1;
            end
            else begin
                clk_counter <= clk_counter +1;
                baud_tick <= 0;
            end
        end
    end
endmodule

module uart_tx(
    input wire clk,
    input wire reset,
    input wire baud_tick,
    input wire tx_start,
    input wire [7:0] data_in,
    output reg tx,
    output reg tx_done
    );
    //states
    parameter idle = 3'b000;
    parameter start = 3'b001;
    parameter data = 3'b010;
    parameter stop = 3'b011;
    parameter clear = 3'b100;
    reg[2:0]state;

    reg[2:0]bit_index;
    reg [7:0]data_shift;

    always@(posedge clk or negedge reset) begin
        if(~reset)begin
            state <= idle;
            tx <= 1'b1;
            tx_done <= 1'b0;
            bit_index <= 3'b000;
            data_shift <= 8'd0;
        end
        else begin
            tx_done <= 1'b0;
        

            case(state) 
                idle : begin
                    tx <= 1'b1;
                    if(tx_start)begin
                        state <= start;
                        data_shift <= data_in;
                    end
                end
                start: begin
                    tx <= 1'b0;
                    if(baud_tick)begin
                        state <= data;
                    end
                end
                data: begin
                    tx <= data_shift[0];
                    if(baud_tick)begin
                        data_shift <= data_shift >>1;
                        if(bit_index == 7)begin
                            bit_index <= 0;
                            state <= stop;
                        end
                        else begin
                            bit_index <= bit_index +1;
                        end
                    end
                end

                stop: begin
                    tx <= 1'b1;
                    if(baud_tick)begin
                        state <= clear;
                    end
                end
                clear: begin
                    tx_done <= 1'b1;
                    state <= idle;
                end
                default : state <= idle;
            endcase
        end
    end
endmodule
