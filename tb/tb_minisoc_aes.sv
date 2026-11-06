`timescale 1ns/1ps

module tb_minisoc_aes;
    logic [7:0]   byte_in;
    logic [7:0]   byte_out;
    logic [127:0] sub_in;
    logic [127:0] sub_out;
    logic [127:0] shift_in;
    logic [127:0] shift_out;

    minisoc_aes_sbox u_sbox (
        .byte_in(byte_in),
        .byte_out(byte_out)
    );

    minisoc_aes_sub_bytes u_sub_bytes (
        .state_in(sub_in),
        .state_out(sub_out)
    );

    minisoc_aes_shift_rows u_shift_rows (
        .state_in(shift_in),
        .state_out(shift_out)
    );

    // Tabela de referencia independente do DUT (FIPS-197, S-Box AES).
    // Na concatenacao, SBOX_REF[7:0] corresponde ao indice 00.
    localparam logic [2047:0] SBOX_REF = {
        128'h16bb54b00f2d99416842e6bf0d89a18c,
        128'hdf2855cee9871e9b948ed9691198f8e1,
        128'h9e1dc186b95735610ef6034866b53e70,
        128'h8a8bbd4b1f74dde8c6b4a61c2e2578ba,
        128'h08ae7a65eaf4566ca94ed58d6d37c8e7,
        128'h79e4959162acd3c25c2406490a3a32e0,
        128'hdb0b5ede14b8ee4688902a22dc4f8160,
        128'h73195d643d7ea7c41744975fec130ccd,
        128'hd2f3ff1021dab6bcf5389d928f40a351,
        128'ha89f3c507f02f94585334d43fbaaefd0,
        128'hcf584c4a39becb6a5bb1fc20ed00d153,
        128'h842fe329b3d63b52a05a6e1b1a2c8309,
        128'h75b227ebe28012079a059618c323c704,
        128'h1531d871f1e5a534ccf73f362693fdb7,
        128'hc072a49cafa2d4adf04759fa7dc982ca,
        128'h76abd7fe2b670130c56f6bf27b777c63
    };

    task automatic check128(
        input logic [127:0] got,
        input logic [127:0] expected,
        input string description
    );
        if (got !== expected) begin
            $display("FAIL: %s", description);
            $display(" esperado = %032h", expected);
            $display(" recebido = %032h", got);
            $fatal(1, "Teste interrompido");
        end
        $display("PASS: %s", description);
    endtask

    initial begin
        byte_in  = '0;
        sub_in   = '0;
        shift_in = '0;
        #1;

        // Verifica exaustivamente as 256 entradas da S-Box.
        for (int i = 0; i < 256; i++) begin
            byte_in = 8'(i);
            #1;
            if (byte_out !== SBOX_REF[i*8 +: 8]) begin
                $fatal(1,
                    "FAIL: S-Box entrada=%02h esperado=%02h obtido=%02h",
                    byte_in, SBOX_REF[i*8 +: 8], byte_out);
            end
        end
        $display("PASS: S-Box (256/256 entradas)");

        // FIPS-197, Appendix C.1 (edicao 2001), AES-128 Cipher, rodada 1.
        sub_in = 128'h00102030405060708090a0b0c0d0e0f0;
        #1;
        check128(sub_out,
            128'h63cab7040953d051cd60e0e7ba70e18c,
            "SubBytes rodada 1");

        shift_in = 128'h63cab7040953d051cd60e0e7ba70e18c;
        #1;
        check128(shift_out,
            128'h6353e08c0960e104cd70b751bacad0e7,
            "ShiftRows rodada 1");

        // FIPS-197, Appendix C.1 (edicao 2001), AES-128 Cipher, rodada 10.
        sub_in = 128'hbd6e7c3df2b5779e0b61216e8b10b689;
        #1;
        check128(sub_out,
            128'h7a9f102789d5f50b2beffd9f3dca4ea7,
            "SubBytes rodada 10");

        shift_in = 128'h7a9f102789d5f50b2beffd9f3dca4ea7;
        #1;
        check128(shift_out,
            128'h7ad5fda789ef4e272bca100b3d9ff59f,
            "ShiftRows rodada 10");

        // Verifica explicitamente a permutacao para bytes 00..0F.
        shift_in = 128'h000102030405060708090a0b0c0d0e0f;
        #1;
        check128(shift_out,
            128'h00050a0f04090e03080d02070c01060b,
            "ShiftRows ordem dos bytes");

        $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
