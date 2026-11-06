// Round key supplied externally; same byte order as state_in.
// Purely combinational; key expansion belongs to a later delivery.
module minisoc_aes_add_round_key (
    input  logic [127:0] state_in,
    input  logic [127:0] round_key,
    output logic [127:0] state_out
);
    assign state_out = state_in ^ round_key;
endmodule
