module uart_loopback_tb;
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] data_in;

    wire tx;
    wire rx;
    wire [7:0] data_out;
    wire rx_done;

    assign rx = tx;   // loopback connection
    // Clock generation
    initial clk = 0;
    always #10 clk = ~clk; 

    // Instantiate UART TX
    uart_tx tx_inst(
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .data_in(data_in),
    .tx(tx)
    );
    // Instantiate UART RX
    uart_rx rx_inst(
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .data_out(data_out),
    .rx_done(rx_done)
    );

    initial begin
        reset = 1;
        tx_start = 0;
        data_in = 0;

        #80;
        reset = 0;

        send_byte(8'h55);
        send_byte(8'hA3);
        send_byte(8'hF0);

        #1000000;
        $finish;

    end

    task send_byte;
    input [7:0] byte;

    begin

        @(posedge clk);
        data_in = byte;
        tx_start = 1;

        @(posedge clk);
        tx_start = 0;

        // wait until RX receives
        wait(rx_done);

        if(data_out == byte)
            $display("PASS: Sent %h Received %h", byte, data_out);
        else
            $display("FAIL: Sent %h Received %h", byte, data_out);

    end

    endtask

    // Waveform
    initial begin
        $dumpfile("uart_loopback.vcd");
        $dumpvars(0, uart_loopback_tb);
    end
       
endmodule 