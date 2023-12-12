// module vmul_test;

//     localparam int MIN_WIDTH   = 1;
//     localparam int MAX_WIDTH   = 16;

//     logic [$clog2(MAX/MIN) : 0] sew;
//     logic [WIDTH - 1 : 0] opA;
//     logic [WIDTH - 1 : 0] opB;
//     logic [2*WIDTH - 1 : 0] result;

//     vmul #(.WIDTH(WIDTH), .MIN(MIN), .MAX(MAX)) vmul (
//         .sew    (sew),
//         .opA    (opA),
//         .opB    (opB),
//         .result (result)
//     );

//     genvar i;
//     generate
//         for (i = 4; i <= MAX; i *= 2) begin : results
//             logic [WIDTH/i - 1 : 0][i - 1 : 0] vopA;
//             logic [WIDTH/i - 1 : 0][i - 1 : 0] vopB;
//             logic [WIDTH/i - 1 : 0][2*i - 1 : 0] vresult;
//             assign vopA = opA;
//             assign vopB = opB;
//             assign vresult = result;
//         end
//     endgenerate

// initial begin
//     opA = 16'b1100101001001011;
//     opB = 16'b0100110111010100;
//     sew = 5'b00001;
//     #5;
//     sew = 5'b00010;
//     #5;
//     sew = 5'b00100;
//     #5;
//     sew = 5'b01000;
//     #5;
//     sew = 5'b10000;
//     #5;
// end

// endmodule