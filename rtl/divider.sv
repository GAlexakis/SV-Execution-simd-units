module divider #(
    parameter int WIDTH = 32
)(
    input logic clk,
    input logic rst,

    input   logic valid,
    output  logic pop,

    input   logic ready,
    output  logic push,

    input   logic [WIDTH - 1 : 0] a,
    input   logic [WIDTH - 1 : 0] b,

    input logic op,

    output  logic [WIDTH - 1 : 0] result
);

    logic [WIDTH - 1 : 0] unit_result;
    logic compute_start;
    logic compute_end;

    unit_state #(.WIDTH(WIDTH), .OP_BITS(1)) divider_state (
        .clk            (clk),
        .rst            (rst),
        .valid          (valid),
        .pop            (pop),
        .ready          (ready),
        .push           (push),
        .compute_start  (compute_start),
        .compute_end    (compute_end),
        .unit_result    (unit_result),
        .result         (result)
    );

    divide_unit #(.WIDTH(WIDTH)) divide_unit (
        .clk            (clk),
        .compute_start  (compute_start),
        .compute_end    (compute_end),
        .a              (a),
        .b              (b),
        .op             (op),
        .result         (unit_result)
    );

endmodule