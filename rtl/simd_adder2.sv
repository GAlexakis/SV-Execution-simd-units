module simd_adder2 #(
    parameter int MIN_WIDTH = 8,
    parameter int MAX_WIDTH = 64,
    parameter int SEW_WIDTH = $clog2(MAX_WIDTH/MIN_WIDTH) + 1
)(
    input   logic sub,
    input   logic carry_i,
    input   logic [SEW_WIDTH - 1 : 0] sew,
    input   logic [MAX_WIDTH - 1 : 0] opA,
    input   logic [MAX_WIDTH - 1 : 0] opB,
    output  logic [MAX_WIDTH - 1 : 0] result,
    output  logic carry_o
);

    localparam int RATIO = MAX_WIDTH/MIN_WIDTH;

    logic [MAX_WIDTH - 1 : 0] tempB;
    assign tempB = sub ? ~opB : opB;

    logic [MAX_WIDTH/2 - 1 : 0] result_left, result_right;
    assign result = {result_left, result_right};

    logic [MAX_WIDTH/2 - 1 : 0] opA_left, opA_right;
    assign {opA_left, opA_right} = opA;

    logic [MAX_WIDTH/2 - 1 : 0] opB_left, opB_right;
    assign {opB_left, opB_right} = sew[0] ? tempB : opB;

    logic internal_carry;
    generate
        if (RATIO == 1) begin
            assign {carry_o, result_left, result_right} = sew[0] ? opA + tempB + sub : opA + opB + carry_i;
        end else begin
            simd_adder2 #(
                .MIN_WIDTH(MIN_WIDTH),
                .MAX_WIDTH(MAX_WIDTH/2))
            internal_right (
                .sub        (sub),
                .carry_i    (sew[0] ? sub : carry_i),
                .sew        (sew[SEW_WIDTH - 1:1]),
                .opA        (opA_right),
                .opB        (opB_right),
                .result     (result_right),
                .carry_o    (internal_carry)
            );
            simd_adder2 #(
                .MIN_WIDTH(MIN_WIDTH),
                .MAX_WIDTH(MAX_WIDTH/2))
            internal_left (
                .sub        (sub),
                .carry_i    (internal_carry),
                .sew        (sew[SEW_WIDTH - 1:1]),
                .opA        (opA_left),
                .opB        (opB_left),
                .result     (result_left),
                .carry_o    (carry_o)
            );
        end
    endgenerate
endmodule