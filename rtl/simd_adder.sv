module simd_adder #(
    parameter int MIN_WIDTH = 8,
    parameter int MAX_WIDTH = 64,
    parameter int SEW_WIDTH = $clog2(MAX_WIDTH/MIN_WIDTH) + 1
)(
    input   logic sub,
    input   logic [SEW_WIDTH - 1 : 0] sew,
    input   logic [MAX_WIDTH - 1 : 0] opA,
    input   logic [MAX_WIDTH - 1 : 0] opB,
    output  logic [MAX_WIDTH - 1 : 0] result
);

    logic [MAX_WIDTH - 1 : 0] opB_real;
    assign opB_real = sub ? ~opB : opB;

    localparam int ADDERS = MAX_WIDTH/MIN_WIDTH;
    logic [ADDERS - 1 : 0] carries_i;
    logic [ADDERS - 1 : 0] carries_o;
    logic [ADDERS - 2 : 0] stop_carry;

    always_comb begin
        carries_i[0] = sub;
        for (int i = 1; i < ADDERS; ++i) carries_i[i] = stop_carry[i - 1] ? sub : carries_o[i - 1];
    end


    always_comb begin
        stop_carry = 0;
        for (int i = 0; i < SEW_WIDTH; ++i) begin
            for (int j = ADDERS/(2**i); j < ADDERS; j += ADDERS/(2**i))
                stop_carry[j - 1] |= sew[i];
        end
    end

    //! THIS IS NOT FOR THE ADDER AND HAS TO BE REMOVED
    logic [ADDERS - 1 : 0] mul_flag;
    logic [ADDERS - 1 : 0][ADDERS - 1 : 0] mul_sel;
    logic [ADDERS - 1 : 0][ADDERS - 1 : 0] mul_final_flags;
    logic [SEW_WIDTH - 2 : 0]sew_rev;
    always_comb begin
        mul_flag[0] = 1'b1;
        for (int i = 1; i < ADDERS; ++i) mul_flag[i] = ~stop_carry[i - 1] & mul_flag[i - 1];

        for (int i = 0; i < SEW_WIDTH - 1; ++i) sew_rev[i] = sew[SEW_WIDTH - i - 1];

        mul_sel[0] = mul_flag;
        for (int i = 1; i < ADDERS; ++i) if (!sew[0]) begin
            mul_sel[i] = mul_sel[i - 1] << sew_rev;
        end

        for (int i = 0; i < SEW_WIDTH; ++i) if (sew[i]) begin
            for (int j = 0; j < ADDERS; ++j) begin
                mul_final_flags[j] = mul_sel[j/(2**(SEW_WIDTH - i - 1))];
            end
        end
    end
    logic [ADDERS - 1 : 0][MAX_WIDTH - 1 : 0] mul_masks;
    always_comb for (int i = 0; i < ADDERS; ++i) for (int j = 0; j < ADDERS; ++j) mul_masks[i][j*MIN_WIDTH +: MIN_WIDTH] = {MIN_WIDTH{mul_final_flags[i][j]}};

    genvar i, j;
    generate
        for (i = 0; i < ADDERS; ++i) begin : gen_part_adders
            part_adder #(.WIDTH(MIN_WIDTH)) padder (
                .carry_i    (carries_i[i]),
                .opA        (opA[i*MIN_WIDTH +: MIN_WIDTH]),
                .opB        (opB_real[i*MIN_WIDTH +: MIN_WIDTH]),
                .result     (result[i*MIN_WIDTH +: MIN_WIDTH]),
                .carry_o    (carries_o[i])
            );
        end
    endgenerate

endmodule