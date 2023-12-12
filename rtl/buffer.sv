module buffer #(
    parameter int WIDTH = 32
)(
    input logic clk,
    input logic rst,

    input   logic push,
    output  logic ready,
    input   logic [WIDTH - 1 : 0] data_i,

    output  logic valid,
    input   logic pop,
    output  logic [WIDTH - 1 : 0] data_o
);

    logic full;
    logic [WIDTH - 1 : 0] data;

    always_ff @(posedge clk) if (push) data <= data_i;
    assign data_o = data;

    always_ff @(posedge clk) begin
        if (rst) full <= 1'b0;
        else if (push) full <= 1'b1;
        else if (pop) full <= 1'b0;
    end

    assign ready = ~full;
    assign valid = full;

endmodule