// AES forward MixColumns, GF(2^8), modulus x^8+x^4+x^3+x+1.
// Column-major: byte 0 = [127:120]; each column occupies 32 bits.
module minisoc_aes_mix_columns (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);
    function automatic logic [7:0] xtime(input logic [7:0] a);
        return {a[6:0], 1'b0} ^ (8'h1b & {8{a[7]}});
    endfunction

    for (genvar col = 0; col < 4; col++) begin : gen_col
        wire [7:0] a0 = state_in[127 - 32*col -: 8];
        wire [7:0] a1 = state_in[119 - 32*col -: 8];
        wire [7:0] a2 = state_in[111 - 32*col -: 8];
        wire [7:0] a3 = state_in[103 - 32*col -: 8];
        assign state_out[127 - 32*col -: 8] = xtime(a0) ^ xtime(a1) ^ a1 ^ a2 ^ a3;
        assign state_out[119 - 32*col -: 8] = a0 ^ xtime(a1) ^ xtime(a2) ^ a2 ^ a3;
        assign state_out[111 - 32*col -: 8] = a0 ^ a1 ^ xtime(a2) ^ xtime(a3) ^ a3;
        assign state_out[103 - 32*col -: 8] = xtime(a0) ^ a0 ^ a1 ^ a2 ^ xtime(a3);
    end
endmodule
