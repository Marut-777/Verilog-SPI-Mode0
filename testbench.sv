`timescale 1ns/1ps

module tb_spi;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;
    reg [7:0] data_in = 8'hA5;

    wire sclk, cs_n, mosi, miso, done;
    wire [7:0] data_out;
    wire [7:0] data_received;

    spi_master master (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .miso(miso),
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .data_out(data_out),
        .done(done)
    );

    spi_slave slave (
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .miso(miso),
        .data_received(data_received)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("spi_loopback.vcd");
        $dumpvars(0, tb_spi);

        repeat (3) @(negedge clk);
        rst = 0;

        @(negedge clk);
        start = 1;

        @(negedge clk);
        start = 0;

        wait(done == 1);
        #1;

        $display("Master sent     = %h", data_in);
        $display("Slave received  = %h", data_received);
        $display("Master received = %h", data_out);

        if (data_received == data_in && data_out == 8'h3C)
            $display("SPI TEST: PASS");
        else
            $display("SPI TEST: FAIL");

        #20;
        $finish;
    end
endmodule
