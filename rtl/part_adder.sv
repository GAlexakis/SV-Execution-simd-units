module part_adder #(
    parameter int WIDTH = 8
)(
    input   logic carry_i,
    input   logic [WIDTH - 1 : 0] opA,
    input   logic [WIDTH - 1 : 0] opB,
    output  logic [WIDTH - 1 : 0] result,
    output  logic carry_o
);

    assign {carry_o, result} = opA + opB + carry_i;

endmodule