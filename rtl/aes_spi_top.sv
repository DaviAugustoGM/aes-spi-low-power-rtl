`timescale 1ns/1ps
// Week-1 environment example. This module DOES NOT perform AES or SPI.
// Replace this provisional interface after receiving the functional specification.
module aes_spi_top (
    input logic clk,
    input logic global_reset_n,
    output logic ready
);
    logic rst_n;
    reset_sync u_reset (.clk(clk), .arst_n(global_reset_n), .rst_n(rst_n));
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) ready <= 1'b0;
        else ready <= 1'b1;
    end
endmodule
