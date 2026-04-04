module uart_tb;

    // Parameters
    parameter clk_freq  = 50000000;
    parameter baud_rate = 9600;

    // Signals
    reg clk = 0;
    reg reset = 0;

    reg tx_start = 0;
    reg [7:0] data_in = 0;

    wire baud_tick;
    wire tx;
    wire tx_done;

    // Clock generation (50 MHz → 20ns period)
    always #10 clk = ~clk;

    // Instantiate baud generator
    uart #(
        .clk_freq(clk_freq),
        .baud_rate(baud_rate)
    ) baud_gen (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // Instantiate transmitter
    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx(tx),
        .tx_done(tx_done)
    );

    // Task to send byte
    task send_byte;
        input [7:0] data;
        begin
            @(posedge clk);
            data_in  <= data;
            tx_start <= 1;

            @(posedge clk);
            tx_start <= 0;

            wait(tx_done);
            @(posedge clk);
        end
    endtask

    initial begin

        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        // Reset sequence
        #80;
        reset = 1;

        // Send bytes
        send_byte(8'h55);
        send_byte(8'hA3);
        send_byte(8'hFF);

        #2000000;  // wait 2ms

        $display("Simulation Complete");
        $finish;
    end
endmodule