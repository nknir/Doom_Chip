`timescale 1ns / 1ps

module uart_switch_test (
    input  wire CLK100MHZ,
    input  wire SW0,
    output wire uart_tx
);
    localparam integer CLOCKS_PER_BIT = 10_417;    // 100 MHz / 9600, rounded
    localparam integer IDLE_CLOCKS    = 10_000_000; // 100 ms of idle after each frame

    // The physical switch can change at any time. Synchronize it to the clock.
    (* ASYNC_REG = "TRUE" *) reg [1:0] switch_sync = 2'b00;

    reg [9:0]  shift_reg = 10'b1111111111; // UART idles high
    reg [3:0]  bits_left = 4'd0;
    reg [23:0] counter   = 24'd0;

    assign uart_tx = shift_reg[0];

    always @(posedge CLK100MHZ) begin
        switch_sync <= {switch_sync[0], SW0};

        if (bits_left == 0) begin
            if (counter == IDLE_CLOCKS - 1) begin
                // Capture the whole frame: stop bit, data byte, start bit.
                shift_reg <= {1'b1, 7'b0, switch_sync[1], 1'b0};
                bits_left <= 4'd10;
                counter   <= 24'd0;
            end else begin
                counter <= counter + 1'b1;
            end
        end else if (counter == CLOCKS_PER_BIT - 1) begin
            // Send the next bit. Shift in a 1 to return to idle after the stop bit.
            shift_reg <= {1'b1, shift_reg[9:1]};
            bits_left <= bits_left - 1'b1;
            counter   <= 24'd0;
        end else begin
            counter <= counter + 1'b1;
        end
    end
endmodule
