module simd_multiplier #(
    parameter int MIN_WIDTH = 8,
    parameter int MAX_WIDTH = 64,
    parameter int SEW_WIDTH = $clog2(MAX_WIDTH/MIN_WIDTH) + 1
)(
    input   logic mulh,
    input   logic [SEW_WIDTH - 1 : 0] sew,
    input   logic [MAX_WIDTH - 1 : 0] opA,
    input   logic [MAX_WIDTH - 1 : 0] opB,
    output  logic [MAX_WIDTH - 1 : 0] result
);
    localparam int RATIO = MAX_WIDTH/MIN_WIDTH;
    logic [RATIO - 2 : 0] stop_carry;
    logic [RATIO - 1 : 0] mul_flag;
    logic [RATIO - 1 : 0][RATIO - 1 : 0] mul_sel;
    logic [RATIO - 1 : 0][RATIO - 1 : 0] mul_final_flags;
    logic [SEW_WIDTH - 2 : 0]sew_rev;

    always_comb begin
        stop_carry = 0;
        for (int i = 0; i < SEW_WIDTH; ++i) begin
            for (int j = RATIO/(2**i); j < RATIO; j += RATIO/(2**i))
                stop_carry[j - 1] |= sew[i];
        end

        mul_flag[0] = 1'b1;
        for (int i = 1; i < RATIO; ++i) mul_flag[i] = ~stop_carry[i - 1] & mul_flag[i - 1];
        for (int i = 0; i < SEW_WIDTH - 1; ++i) sew_rev[i] = sew[SEW_WIDTH - i - 1];

        mul_sel[0] = mul_flag;
        for (int i = 1; i < RATIO; ++i) if (!sew[0]) begin
            mul_sel[i] = mul_sel[i - 1] << sew_rev;
        end

        for (int i = 0; i < SEW_WIDTH; ++i) if (sew[i]) begin
            for (int j = 0; j < RATIO; ++j) begin
                mul_final_flags[j] = mul_sel[j/(2**(SEW_WIDTH - i - 1))];
            end
        end
    end

    logic [RATIO - 1 : 0][MAX_WIDTH - 1 : 0] mul_masks;
    always_comb for (int i = 0; i < RATIO; ++i) for (int j = 0; j < RATIO; ++j) mul_masks[i][j*MIN_WIDTH +: MIN_WIDTH] = {MIN_WIDTH{mul_final_flags[i][j]}};

    logic [MAX_WIDTH - 1 : 0][MAX_WIDTH - 1 : 0] parts;
    always_comb for (int i = 0; i < MAX_WIDTH; ++i) parts[i] = opB[i] ? opA & mul_masks[i/MIN_WIDTH] : 0;



    logic [SEW_WIDTH - 1 : 0][MAX_WIDTH - 1 : 0] results_mul_temp, results_mulh_temp;
    always_comb for (int i = 0; i < SEW_WIDTH; ++i) if (sew[i]) result = mulh ? results_mulh_temp[i] : results_mul_temp[i];


    genvar i, k;
    generate
        for (i = 0; i < SEW_WIDTH; ++i) begin : gen_shift_adders
            logic [RATIO/(2**i) - 1 : 0][2*MIN_WIDTH*(2**i) - 1 : 0] mul_temp;
            if (i == 0) begin
                always_comb begin
                    mul_temp = 0;
                    for (int j = 0; j < MAX_WIDTH; ++j) begin
                        mul_temp[j/MIN_WIDTH] += parts[j] << (j%MIN_WIDTH);
                    end
                end
            end else begin
                for (k = 0; k < RATIO/(2**i); ++k) begin
                    assign mul_temp[k] = gen_shift_adders[i - 1].mul_temp[2*k] + ((gen_shift_adders[i - 1].mul_temp[2*k + 1]) << (MIN_WIDTH*2**(i - 1)));
                end
            end

            assign {results_mulh_temp[i], results_mul_temp[i]} = mul_temp[i];

        end
    endgenerate

endmodule