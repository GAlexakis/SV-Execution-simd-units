module simd_multiplier2 #(
    parameter int MIN_WIDTH = 8,
    parameter int MAX_WIDTH = 64,
    parameter int SEW_WIDTH = $clog2(MAX_WIDTH/MIN_WIDTH) + 1
)(
    input   logic clk,
    input   logic high,
    input   logic signA,
    input   logic signB,
    input   logic [SEW_WIDTH - 1 : 0] sew,
    input   logic [MAX_WIDTH - 1 : 0] opA,
    input   logic [MAX_WIDTH - 1 : 0] opB,
    output  logic [MAX_WIDTH - 1 : 0] result
);
    localparam int RATIO = MAX_WIDTH/MIN_WIDTH;

    logic [MAX_WIDTH - 1 : 0] opA_unsigned;
    logic [MAX_WIDTH - 1 : 0] opB_unsigned;
    logic [RATIO - 1 : 0] opA_signs;
    logic [RATIO - 1 : 0] opB_signs;

    always_comb begin
        for (int i = 0; i < RATIO; ++i) begin
            opA_signs[i] = opA[(i + 1)*MIN_WIDTH - 1];
            opB_signs[i] = opB[(i + 1)*MIN_WIDTH - 1];
        end
    end

    simd_unsigned #(
        .MIN_WIDTH(MIN_WIDTH),
        .MAX_WIDTH(MAX_WIDTH)
    ) simd_unsigned_opA (
        .carry_i(1'b0),
        .sew(sew),
        .opA(opA),
        .result(opA_unsigned),
        .carry_o()
    );
    simd_unsigned #(
        .MIN_WIDTH(MIN_WIDTH),
        .MAX_WIDTH(MAX_WIDTH)
    ) simd_unsigned_opB (
        .carry_i(1'b0),
        .sew(sew),
        .opA(opB),
        .result(opB_unsigned),
        .carry_o()
    );

    logic [MAX_WIDTH - 1 : 0] correct_opA;
    logic [MAX_WIDTH - 1 : 0] correct_opB;

    assign correct_opA = signA ? opA_unsigned : opA;
    assign correct_opB = signB ? opB_unsigned : opB;


    logic [RATIO - 1 : 0][RATIO - 1 : 0][2*MIN_WIDTH - 1 : 0] matrix_temp, matrix;
    always_comb for (int i = 0; i < RATIO; ++i) for (int j = 0; j < RATIO; ++j) matrix_temp[i][j] = correct_opB[MIN_WIDTH*i +: MIN_WIDTH] * correct_opA[MIN_WIDTH*j +: MIN_WIDTH];




    logic [RATIO - 1 : 0] result_signs;
    logic [SEW_WIDTH - 1 : 0] sew_ff;
    logic high_ff;
    always_ff @(posedge clk) begin : PIPELINE
        sew_ff <= sew;
        high_ff <= high;
        result_signs <= (signA ? opA_signs : 0) ^ (signB ? opB_signs : 0);
        matrix <= matrix_temp;
    end // PIPELINE



    logic [RATIO - 1 : 0][2*MIN_WIDTH - 1 : 0] first_vector;
    always_comb for (int i = 0; i < RATIO; ++i) first_vector[i] = matrix[i][i];

    logic [SEW_WIDTH - 1 : 0][2*MAX_WIDTH - 1 : 0] vectors;

    assign vectors[SEW_WIDTH - 1] = first_vector;

    logic [2*MAX_WIDTH - 1 : 0] result_unsigned;
    always_comb for (int i = 0; i < SEW_WIDTH; ++i) if (sew_ff[i]) result_unsigned = vectors[i];

    logic [2*MAX_WIDTH - 1 : 0] result_full;
    simd_signed #(
        .MIN_WIDTH(2*MIN_WIDTH),
        .MAX_WIDTH(2*MAX_WIDTH)
    ) simd_signed_result (
        .carry_i(1'b0),
        .sew(sew_ff),
        .opA(result_unsigned),
        .change(result_signs),
        .result(result_full),
        .carry_o()
    );
    simd_half #(
        .MIN_WIDTH(MIN_WIDTH),
        .MAX_WIDTH(MAX_WIDTH)
    ) simd_result_half (
        .high(high_ff),
        .sew(sew_ff),
        .opA(result_full),
        .result(result)
    );

    genvar i;
    generate
        for (i = 0; i < SEW_WIDTH - 1; ++i) begin : parts

            logic [2*MAX_WIDTH - 1 : 0] vector_temp;
            logic [RATIO/(2**(i + 1)) - 1 : 0][RATIO/(2**(i + 1)) - 1 : 0][2*MIN_WIDTH*(2**(i + 1)) - 1 : 0] matrix_temp;

            if (i == 0) begin
                pmul #(.WIDTH(2*MIN_WIDTH), .VECTOR_WIDTH(MAX_WIDTH)) pmul (
                    .matrix_in  (matrix),
                    .matrix_out (matrix_temp),
                    .vector_out (vector_temp)
                );
            end else begin
                pmul #(.WIDTH(2*MIN_WIDTH*(2**i)), .VECTOR_WIDTH(MAX_WIDTH)) pmul (
                    .matrix_in  (parts[i - 1].matrix_temp),
                    .matrix_out (matrix_temp),
                    .vector_out (vector_temp)
                );
            end
            assign vectors[SEW_WIDTH - i - 2] = vector_temp;
        end
    endgenerate

endmodule