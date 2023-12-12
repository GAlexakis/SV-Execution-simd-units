module vadd4    #(
                    parameter int WIDTH = 1,
                    localparam int FINAL_WIDTH = WIDTH == 1 ? 4 : 2*WIDTH
                )(
                    input logic [WIDTH - 1 : 0] tl,
                    input logic [WIDTH - 1 : 0] tr,
                    input logic [WIDTH - 1 : 0] bl,
                    input logic [WIDTH - 1 : 0] br,

                    output logic [FINAL_WIDTH - 1 : 0] result
                );

    localparam int SHAMT = WIDTH == 1 ? 1 : WIDTH/2;

    logic [WIDTH + SHAMT - 1 : 0] tl_temp;
    logic [WIDTH + SHAMT - 1 : 0] tr_temp;
    logic [WIDTH + SHAMT - 1 : 0] bl_temp;
    logic [WIDTH + SHAMT - 1 : 0] br_temp;

    assign tl_temp = {{SHAMT{1'b0}}, tl};
    assign tr_temp = {{SHAMT{1'b0}}, tr};
    assign bl_temp = {bl, {SHAMT{1'b0}}};
    assign br_temp = {br, {SHAMT{1'b0}}};

    logic [WIDTH + SHAMT - 1 : 0] left;
    logic [WIDTH + SHAMT - 1 : 0] right;

    assign left = tl_temp + bl_temp;
    assign right = tr_temp + br_temp;

    logic [FINAL_WIDTH - 1 : 0] left_temp;
    logic [FINAL_WIDTH - 1 : 0] right_temp;

    assign right_temp = {{FINAL_WIDTH - WIDTH - 2*SHAMT{1'b0}}, {SHAMT{1'b0}}, right};
    assign left_temp = {{FINAL_WIDTH - WIDTH - 2*SHAMT{1'b0}}, left, {SHAMT{1'b0}}};

    assign result = left_temp + right_temp;




endmodule