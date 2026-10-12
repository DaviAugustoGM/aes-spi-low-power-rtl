`timescale 1ns/1ps
module tb_smoke;
    logic clk = 0;
    logic global_reset_n = 1;
    wire ready;
    aes_spi_top dut (.*);
    always #5 clk = ~clk;
    task automatic check(input logic expected);
        if (ready !== expected) $fatal(1, "ready=%b expected=%b", ready, expected);
    endtask
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_smoke);
        #1; global_reset_n = 0;
        #2; check(0);
        #4; global_reset_n = 1;
        @(posedge clk); #1; check(0);
        @(posedge clk); #1; check(0);
        @(posedge clk); #1; check(1);
        // Reset while running, away from a rising clock edge.
        #2; global_reset_n = 0;
        #1; check(0);
        #2; global_reset_n = 1;
        repeat (2) begin @(posedge clk); #1; check(0); end
        @(posedge clk); #1; check(1);
        $display("PASS: reset assertion, synchronized release and ready");
        $finish;
    end
    initial begin
        #1000; $fatal(1, "Timeout");
    end
endmodule
