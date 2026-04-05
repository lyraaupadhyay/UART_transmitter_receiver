Complete UART implementation in Verilog featuring 5-state FSM (IDLE, START, DATA, STOP, CLEAR) operating at 9600 baud rate. Supports communication with precise baud rate generation.

FEATURES:-

9600 baud rate generation using clock divider

5-state FSM (IDLE → START → DATA → STOP → CLEAR)

Full-duplex operation (TX + RX independent)

8-bit data transmission with start/stop bits

Parameterizable baud rate and clock frequency

Self-contained testbench with loopback verification
