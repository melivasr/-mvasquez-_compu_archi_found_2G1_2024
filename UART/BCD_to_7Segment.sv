module BCD_to_7Segment (
    input  logic [3:0] bcd,    // 4 bits BCD input (A[3], B[2], C[1], D[0])
    output logic [6:0] seg     // 7-segment output (g[6], f[5], e[4], d[3], c[2], b[1], a[0])
);

    // ======== Segmento 'a' ========
    // a = (~A & ~B & ~C & D) | (~A & B & ~C & ~D) | (A & ~B & C & D) | (A & B & ~C & D)
    assign seg[0] = (~bcd[3] & ~bcd[2] & ~bcd[1] & bcd[0]) |
                   (~bcd[3] & bcd[2] & ~bcd[1] & ~bcd[0]) |
                   (bcd[3] & ~bcd[2] & bcd[1] & bcd[0]) |
                   (bcd[3] & bcd[2] & ~bcd[1] & bcd[0]);

    // ======== Segmento 'b' ========
    // b = (A & B & ~D) | (A & C & D) | (B & C & ~D) | (~A & B & ~C & D)
    assign seg[1] = (bcd[3] & bcd[2] & ~bcd[0]) |
                   (bcd[3] & bcd[1] & bcd[0]) |
                   (bcd[2] & bcd[1] & ~bcd[0]) |
                   (~bcd[3] & bcd[2] & ~bcd[1] & bcd[0]);

    // ======== Segmento 'c' ========
    // c = (A & B & C) | (A & B & ~D) | (~A & ~B & C & ~D)
    assign seg[2] = (bcd[3] & bcd[2] & bcd[1]) |
                   (bcd[3] & bcd[2] & ~bcd[0]) |
                   (~bcd[3] & ~bcd[2] & bcd[1] & ~bcd[0]);

    // ======== Segmento 'd' ========
    // d = (B & C & D) | (~A & ~B & ~C & D) | (~A & B & ~C & ~D) | (A & ~B & C & ~D)
    assign seg[3] = (bcd[2] & bcd[1] & bcd[0]) |
                   (~bcd[3] & ~bcd[2] & ~bcd[1] & bcd[0]) |
                   (~bcd[3] & bcd[2] & ~bcd[1] & ~bcd[0]) |
                   (bcd[3] & ~bcd[2] & bcd[1] & ~bcd[0]);

    // ======== Segmento 'e' ========
    // e = (~A & D) | (~A & B & ~C) | (~B & ~C & D)
    assign seg[4] = (~bcd[3] & bcd[0]) |
                   (~bcd[3] & bcd[2] & ~bcd[1]) |
                   (~bcd[2] & ~bcd[1] & bcd[0]);

    // ======== Segmento 'f' ========
    // f = (~A & C & D) | (~A & ~B & C) | (~A & ~B & D) | (A & B & ~C & D)
    assign seg[5] = (~bcd[3] & bcd[1] & bcd[0]) |
                   (~bcd[3] & ~bcd[2] & bcd[1]) |
                   (~bcd[3] & ~bcd[2] & bcd[0]) |
                   (bcd[3] & bcd[2] & ~bcd[1] & bcd[0]);

    // ======== Segmento 'g' ========
    // g = (~A & ~B & ~C) | (~A & B & C & D) | (A & B & ~C & ~D)
    assign seg[6] = (~bcd[3] & ~bcd[2] & ~bcd[1]) |
                   (~bcd[3] & bcd[2] & bcd[1] & bcd[0]) |
                   (bcd[3] & bcd[2] & ~bcd[1] & ~bcd[0]);

endmodule