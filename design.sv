`timescale 1ns/1ps

// SPI Master: Mode 0, MSB first
module spi_master (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] data_in,
    input wire miso,

    output reg sclk,
    output reg cs_n,
    output reg mosi,
    output reg [7:0] data_out,
    output reg done
);

    localparam IDLE = 1'b0;
    localparam TRANSFER = 1'b1;

    reg state;
    reg phase;
    reg [3:0] bit_count;
    reg [7:0] tx_shift;
    reg [7:0] rx_shift;

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            phase     <= 0;
            bit_count <= 0;
            tx_shift  <= 0;
            rx_shift  <= 0;
            sclk      <= 0;
            cs_n      <= 1;
            mosi      <= 0;
            data_out  <= 0;
            done      <= 0;
        end else begin
            done <= 0;

            case (state)
                IDLE: begin
                    sclk <= 0;
                    cs_n <= 1;
                    phase <= 0;

                    if (start) begin
                        tx_shift  <= data_in;
                        rx_shift  <= 0;
                        bit_count <= 0;
                        mosi      <= data_in[7];
                        cs_n      <= 0;
                        state     <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if (phase == 0) begin
                        // Rising SCLK edge: sample MISO
                        sclk <= 1;
                        rx_shift <= {rx_shift[6:0], miso};
                        phase <= 1;
                    end else begin
                        // Falling SCLK edge: prepare next MOSI bit
                        sclk <= 0;
                        phase <= 0;

                        if (bit_count == 7) begin
                            data_out <= rx_shift;
                            cs_n <= 1;
                            state <= IDLE;
                            done <= 1;
                        end else begin
                            bit_count <= bit_count + 1;
                            tx_shift <= {tx_shift[6:0], 1'b0};
                            mosi <= tx_shift[6];
                        end
                    end
                end
            endcase
        end
    end
endmodule


// Simple SPI Slave: receives a byte and replies with 8'h3C
module spi_slave (
    input wire sclk,
    input wire cs_n,
    input wire mosi,

    output reg miso,
    output reg [7:0] data_received
);

    localparam [7:0] REPLY = 8'h3C;

    reg [7:0] reply_shift;
    reg [3:0] bit_count;

    initial begin
        reply_shift = REPLY;
        bit_count = 0;
        data_received = 0;
        miso = REPLY[7];
    end

    // When selected, prepare the first reply bit
    always @(negedge cs_n) begin
        reply_shift <= REPLY;
        bit_count <= 0;
        data_received <= 0;
        miso <= REPLY[7];
    end

    // Slave samples MOSI on rising SCLK edges
    always @(posedge sclk) begin
        if (!cs_n) begin
            data_received <= {data_received[6:0], mosi};
            bit_count <= bit_count + 1;
        end
    end

    // Slave prepares the next MISO bit on falling SCLK edges
    always @(negedge sclk) begin
        if (!cs_n) begin
            reply_shift <= {reply_shift[6:0], 1'b0};
            miso <= reply_shift[6];
        end
    end
endmodule
