module pmul #(
                parameter int WIDTH = 1,
                parameter int VECTOR_WIDTH = 64,
                localparam int FINAL_WIDTH = WIDTH == 1 ? 4 : 2*WIDTH,
                localparam int SIZE = WIDTH == 1 ? VECTOR_WIDTH : 2*VECTOR_WIDTH/WIDTH,
                localparam int FINAL_SIZE = SIZE/2
            )(
                input logic [SIZE - 1 : 0][SIZE - 1 : 0][WIDTH - 1 : 0] matrix_in,
                output logic [FINAL_SIZE - 1 : 0][FINAL_SIZE - 1 : 0][FINAL_WIDTH - 1 : 0] matrix_out,

                output logic [2*VECTOR_WIDTH - 1 : 0] vector_out
            );

    genvar i, j;
    generate
        for (i = 0; i < SIZE; i += 2) begin
            for (j = 0; j < SIZE; j += 2) begin
                vadd4 #(.WIDTH(WIDTH)) vadd4 (
                    .tl     (matrix_in[i][j + 1]),
                    .tr     (matrix_in[i][j]),
                    .bl     (matrix_in[i + 1][j + 1]),
                    .br     (matrix_in[i + 1][j]),
                    .result (matrix_out[i/2][j/2])
                );
            end
        end
    endgenerate

    always_comb for (int i = 0; i < 2*VECTOR_WIDTH; i += FINAL_WIDTH) vector_out[i +: FINAL_WIDTH] = matrix_out[i/FINAL_WIDTH][i/FINAL_WIDTH];

endmodule