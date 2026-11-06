// SubBytes: 16 independent parallel AES S-Boxes.
// Byte 0 is state_in[127:120], byte 15 is state_in[7:0].
module minisoc_aes_sub_bytes (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);
    for (genvar b = 0; b < 16; b++) begin : gen_sbox
        minisoc_aes_sbox u_sbox (
            .byte_in  (state_in [127 - 8*b -: 8]),
            .byte_out (state_out[127 - 8*b -: 8])
        );
    end
endmodule
