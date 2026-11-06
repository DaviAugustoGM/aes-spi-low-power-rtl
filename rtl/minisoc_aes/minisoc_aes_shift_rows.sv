// AES ShiftRows, state stored in column-major order.
// Byte 0 is [127:120]; state index = 4*column + row.
// Row r is cyclically shifted left by r columns.
module minisoc_aes_shift_rows (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);
    for (genvar col = 0; col < 4; col++) begin : gen_col
        for (genvar row = 0; row < 4; row++) begin : gen_row
            localparam int OUT_IDX = 4*col + row;
            localparam int IN_IDX  = 4*((col + row) % 4) + row;
            assign state_out[127 - 8*OUT_IDX -: 8] =
                   state_in [127 - 8*IN_IDX  -: 8];
        end
    end
endmodule
