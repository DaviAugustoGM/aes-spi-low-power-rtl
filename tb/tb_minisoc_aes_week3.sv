`timescale 1ns/1ps
module tb_minisoc_aes_week3;
    logic [127:0] mix_in, mix_out, ark_in, key_in, ark_out;
    logic [127:0] round_in, round_key, sub_out, shift_out, mixed_out;
    logic [127:0] round_out, final_out;
    logic [31:0] rng = 32'h20261106;

    minisoc_aes_mix_columns u_mix(mix_in, mix_out);
    minisoc_aes_add_round_key u_ark(ark_in, key_in, ark_out);
    // Testbench-only round composition; no sequential AES controller here.
    minisoc_aes_sub_bytes u_sub(round_in, sub_out);
    minisoc_aes_shift_rows u_shift(sub_out, shift_out);
    minisoc_aes_mix_columns u_round_mix(shift_out, mixed_out);
    minisoc_aes_add_round_key u_round_ark(mixed_out, round_key, round_out);
    minisoc_aes_add_round_key u_final_ark(shift_out, round_key, final_out);

    // FIPS-197 (2001), Appendix C.1: fixed expected intermediate values.
    // https://csrc.nist.gov/files/pubs/fips/197/final/docs/fips-197.pdf
    localparam logic [127:0] SUB_REF [1:10] = '{
        128'h63cab7040953d051cd60e0e7ba70e18c, 128'ha761ca9b97be8b45d8ad1a611fc97369,
        128'h3b59cb73fcd90ee05774222dc067fb68, 128'h2dfb02343f6d12dd09337ec75b36e3f0,
        128'h36400926f9336d2d9fb59d23c42c3950, 128'he847f56514dadde23f77b64fe7f7d490,
        128'hb415f8016858552e4bb6124c5f998a4c, 128'h3e175076b61c04678dfc2295f6a8bfc0,
        128'h5411f4b56bd9700e96a0902fa1bb9aa1, 128'h7a9f102789d5f50b2beffd9f3dca4ea7};
    localparam logic [127:0] SHIFT_REF [1:10] = '{
        128'h6353e08c0960e104cd70b751bacad0e7, 128'ha7be1a6997ad739bd8c9ca451f618b61,
        128'h3bd92268fc74fb735767cbe0c0590e2d, 128'h2d6d7ef03f33e334093602dd5bfb12c7,
        128'h36339d50f9b539269f2c092dc4406d23, 128'he8dab6901477d4653ff7f5e2e747dd4f,
        128'hb458124c68b68a014b99f82e5f15554c, 128'h3e1c22c0b6fcbf768da85067f6170495,
        128'h54d990a16ba09ab596bbf40ea111702f, 128'h7ad5fda789ef4e272bca100b3d9ff59f};
    localparam logic [127:0] MIX_REF [1:9] = '{
        128'h5f72641557f5bc92f7be3b291db9f91a, 128'hff87968431d86a51645151fa773ad009,
        128'h4c9c1e66f771f0762c3f868e534df256, 128'h6385b79ffc538df997be478e7547d691,
        128'hf4bcd45432e554d075f1d6c51dd03b3c, 128'h9816ee7400f87f556b2c049c8e5ad036,
        128'hc57e1c159a9bd286f05f4be098c63439, 128'hbaa03de7a1f9b56ed5512cba5f414d23,
        128'he9f74eec023020f61bf2ccf2353c21c7};
    localparam logic [127:0] KEYS [1:10] = '{
        128'hd6aa74fdd2af72fadaa678f1d6ab76fe, 128'hb692cf0b643dbdf1be9bc5006830b3fe,
        128'hb6ff744ed2c2c9bf6c590cbf0469bf41, 128'h47f7f7bc95353e03f96c32bcfd058dfd,
        128'h3caaa3e8a99f9deb50f3af57adf622aa, 128'h5e390f7df7a69296a7553dc10aa31f6b,
        128'h14f9701ae35fe28c440adf4d4ea9c026, 128'h47438735a41c65b9e016baf4aebf7ad2,
        128'h549932d1f08557681093ed9cbe2c974e, 128'h13111d7fe3944a17f307a78b4d2b30c5};
    localparam logic [127:0] START_REF [1:10] = '{
        128'h00102030405060708090a0b0c0d0e0f0, 128'h89d810e8855ace682d1843d8cb128fe4,
        128'h4915598f55e5d7a0daca94fa1f0a63f7, 128'hfa636a2825b339c940668a3157244d17,
        128'h247240236966b3fa6ed2753288425b6c, 128'hc81677bc9b7ac93b25027992b0261996,
        128'hc62fe109f75eedc3cc79395d84f9cf5d, 128'hd1876c0f79c4300ab45594add66ff41f,
        128'hfde3bad205e5d0d73547964ef1fe37f1, 128'hbd6e7c3df2b5779e0b61216e8b10b689};

    task automatic check128(input logic [127:0] got, expected, input string description);
        if (got !== expected)
            $fatal(1, "%s: esperado=%032h recebido=%032h", description, expected, got);
    endtask

    // Independent polynomial multiplication: form a 16-bit product, then
    // reduce modulo 0x11b. Does not reuse the DUT's xtime formulation.
    function automatic logic [7:0] gf_mul(input logic [7:0] a, b);
        logic [15:0] product;
        product = '0;
        for (int i = 0; i < 8; i++)
            if (b[i]) product ^= {8'b0, a} << i;
        for (int i = 14; i >= 8; i--)
            if (product[i]) product ^= 16'h011b << (i-8);
        return product[7:0];
    endfunction

    function automatic logic [127:0] mix_ref(input logic [127:0] state);
        logic [127:0] result;
        logic [7:0] coefficient;
        result = '0;
        for (int col = 0; col < 4; col++)
            for (int row = 0; row < 4; row++)
                for (int k = 0; k < 4; k++) begin
                    case ((k-row+4)%4)
                        0: coefficient = 8'h02;
                        1: coefficient = 8'h03;
                        default: coefficient = 8'h01;
                    endcase
                    result[127-8*(4*col+row) -: 8] ^=
                        gf_mul(state[127-8*(4*col+k) -: 8], coefficient);
                end
        return result;
    endfunction

    function automatic logic [31:0] next_random();
        rng ^= rng << 13;
        rng ^= rng >> 17;
        rng ^= rng << 5;
        return rng;
    endfunction

    initial begin
        mix_in = '0; ark_in = '0; key_in = '0; round_in = '0; round_key = '0;
        #1;
        check128(mix_out, '0, "MixColumns zero");
        check128(ark_out, '0, "AddRoundKey zero");
        ark_in = 128'h00112233445566778899aabbccddeeff;
        key_in = 128'h000102030405060708090a0b0c0d0e0f;
        #1;
        check128(ark_out, START_REF[1], "AddRoundKey inicial FIPS");
        round_in = ark_out;
        for (int r = 1; r <= 10; r++) begin
            round_key = KEYS[r];
            #1;
            check128(round_in, START_REF[r], $sformatf("Inicio rodada %0d", r));
            check128(sub_out, SUB_REF[r], $sformatf("SubBytes rodada %0d", r));
            check128(shift_out, SHIFT_REF[r], $sformatf("ShiftRows rodada %0d", r));
            if (r < 10) begin
                check128(mixed_out, MIX_REF[r], $sformatf("MixColumns rodada %0d", r));
                check128(round_out, START_REF[r+1], $sformatf("AddRoundKey rodada %0d", r));
                round_in = round_out;
            end else begin
                // Final AES round omits MixColumns.
                check128(final_out, 128'h69c4e0d86a7b0430d8cdb78070b4c55a, "Saida FIPS");
            end
        end
        $display("PASS: FIPS-197 C.1, todos os estados intermediarios, rodadas 1..10");

        // All byte values at every position; other bytes zero. Covers reduction
        // with bit 7 set, matrix orientation and isolation between columns.
        for (int pos = 0; pos < 16; pos++)
            for (int value = 0; value < 256; value++) begin
                mix_in = '0;
                mix_in[127-8*pos -: 8] = 8'(value);
                #1;
                check128(mix_out, mix_ref(mix_in), $sformatf("Mix pos=%0d valor=%0d", pos, value));
            end
        $display("PASS: MixColumns, 4096 casos (16 posicoes x 256 valores)");

        for (int bitpos = 0; bitpos < 128; bitpos++) begin
            ark_in = '0; key_in = 128'b1 << bitpos;
            #1;
            check128(ark_out, key_in, "AddRoundKey bit da chave");
            ark_in = key_in; key_in = '0;
            #1;
            check128(ark_out, ark_in, "AddRoundKey bit do estado");
            key_in = ark_in;
            #1;
            check128(ark_out, '0, "AddRoundKey cancelamento");
        end
        $display("PASS: AddRoundKey, 384 casos de bits isolados e cancelamento");

        for (int n = 0; n < 1000; n++) begin
            for (int wordpos = 0; wordpos < 4; wordpos++) begin
                mix_in[32*wordpos +: 32] = next_random();
                ark_in[32*wordpos +: 32] = next_random();
                key_in[32*wordpos +: 32] = next_random();
            end
            #1;
            check128(mix_out, mix_ref(mix_in), $sformatf("Mix aleatorio %0d", n));
            check128(ark_out, ark_in ^ key_in, $sformatf("ARK aleatorio %0d", n));
        end
        $display("PASS: 1000 estados/chaves pseudoaleatorios, semente 20261106");
        $display("ALL WEEK 3 TESTS PASSED");
        $finish;
    end
endmodule
