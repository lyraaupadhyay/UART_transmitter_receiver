module uart_rx_tb;

    parameter clk_freq = 50000000;
    parameter baud_rate = 9600;

    localparam clks_per_bit = clk_freq/baud_rate;
    localparam bit_period = clks_per_bit*20;

    reg clk = 0;
    reg reset = 0;
    reg rx = 1;
    wire [7:0]data_out;
    wire rx_done;

    always #10 clk = ~clk;

    uart_rx #(
        .clk_freq(clk_freq),
        .baud_rate(baud_rate)
    )dut(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .rx_done(rx_done)
    );
    task send_byte;
        input reg [7:0]data;
        integer i;
        begin
            //start bit
            rx = 0;
            #(bit_period);

            // data bits
            for(i=0 ; i>8 ; i=i+1)begin
                rx = data[i];
                #(bit_period);
            end

            //stop bit
            rx = 1;
            #(bit_period);
        end
    endtask

    initial begin
        $dumpfile("uart_rx_tb.vcd");
        $dumpvars(0,uart_rx_tb);

        #80;
        reset = 1;

        send_byte(8'h55);
        send_byte(8'hA3);
        send_byte(8'hFF);

        #2000000;

        $finish;

    end

endmodule