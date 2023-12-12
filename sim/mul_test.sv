module mul_test;

    localparam int MIN_WIDTH = 8;
    localparam int MAX_WIDTH = 64;
    localparam int SEW_WIDTH = $clog2(MAX_WIDTH/MIN_WIDTH) + 1;

    logic high;
    logic signA;
    logic signB;
    logic [SEW_WIDTH - 1 : 0] sew;
    logic [MAX_WIDTH - 1 : 0] opA;
    logic [MAX_WIDTH - 1 : 0] opB;
    logic [MAX_WIDTH - 1 : 0] result;

    logic clk;
    always begin
        clk = 1'b1;
        #5;
        clk = 1'b0;
        #5;
    end

    simd_multiplier2 #(
        .MIN_WIDTH(MIN_WIDTH),
        .MAX_WIDTH(MAX_WIDTH),
        .SEW_WIDTH(SEW_WIDTH)
    ) dut (
        .clk(clk),
        .high(high),
        .signA(signA),
        .signB(signB),
        .sew(sew),
        .opA(opA),
        .opB(opB),
        .result(result)
    );
    // simd_unsigned #(
    //     .MIN_WIDTH(MIN_WIDTH),
    //     .MAX_WIDTH(MAX_WIDTH),
    //     .SEW_WIDTH(SEW_WIDTH)
    // ) dut (
    //     .carry_i(1'b0),
    //     .sew(sew),
    //     .opA(opA),
    //     .result(result),
    //     .carry_o()
    // );

    logic [1 : 0][31 : 0] opA32, opB32, opA32_u, opB32_u, result32, result32_u;
    logic [3 : 0][15 : 0] opA16, opB16, opA16_u, opB16_u, result16, result16_u;
    logic [7 : 0][7 : 0] opA8, opB8, opA8_u, opB8_u, result8, result8_u;

    assign opA32 = opA;
    assign opA16 = opA;
    assign opA8 = opA;

    assign opB32 = opB;
    assign opB16 = opB;
    assign opB8 = opB;

    assign result32 = result;
    assign result16 = result;
    assign result8 = result;

    assign opA32_u = dut.opA_unsigned;
    assign opA16_u = dut.opA_unsigned;
    assign opA8_u = dut.opA_unsigned;

    assign opB32_u = dut.opB_unsigned;
    assign opB16_u = dut.opB_unsigned;
    assign opB8_u = dut.opB_unsigned;

    assign result32_u = dut.result_unsigned;
    assign result16_u = dut.result_unsigned;
    assign result8_u = dut.result_unsigned;


    class rng;
        rand bit [63:0] a;
        rand bit [63:0] b;
    endclass //rng

    rng r = new();

    longint res;
    int res32[2];
    shortint res16[4];
    byte res8[8];
    int rep_count;
    initial begin
        rep_count = 1;
        high = 1'b0;
        signA = 1'b1;
        signB = 1'b1;
        repeat(rep_count) begin
            @(negedge clk);
            sew = 4'b0001;
            r.randomize();
            opA = r.a;
            opB = r.b;
            res = opA + opB;
            $display("%d", res);
        end
        repeat(rep_count) begin
            @(negedge clk);
            sew = 4'b0010;
            r.randomize();
            opA = r.a;
            opB = r.b;
            res32[1] = opA32[1] + opB32[1];
            res32[0] = opA32[0] + opB32[0];
            $display("%d\t%d", res32[1], res32[0]);
        end
        repeat(rep_count) begin
            @(negedge clk);
            sew = 4'b0100;
            r.randomize();
            opA = r.a;
            opB = r.b;
            res16[3] = opA16[3] + opB16[3];
            res16[2] = opA16[2] + opB16[2];
            res16[1] = opA16[1] + opB16[1];
            res16[0] = opA16[0] + opB16[0];
            $display("%d\t%d\t%d\t%d", res16[3], res16[2], res16[1], res16[0]);
        end
        repeat(rep_count) begin
            @(negedge clk);
            sew = 4'b1000;
            r.randomize();
            opA = r.a;
            opB = r.b;
            res8[7] = opA8[7] + opB8[7];
            res8[6] = opA8[6] + opB8[6];
            res8[5] = opA8[5] + opB8[5];
            res8[4] = opA8[4] + opB8[4];
            res8[3] = opA8[3] + opB8[3];
            res8[2] = opA8[2] + opB8[2];
            res8[1] = opA8[1] + opB8[1];
            res8[0] = opA8[0] + opB8[0];
            $display("%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", res8[7], res8[6], res8[5], res8[4], res8[3], res8[2], res8[1], res8[0]);
        end
        @(negedge clk);
        opA = {8'd5, 8'd5, 8'd5, 8'd5, 8'd5, 8'd5, 8'd5, 8'd5};
        opB = {8'd5, 8'd5, 8'd5, 8'd5, 8'd5, 8'd5, 8'd5, 8'd5};
        @(negedge clk);
        sew = 4'b0100;
        opA = {16'(2*16 - 5), 16'(2*16 - 5), 16'(2*16 - 5), 16'(2*16 - 5)};
        opB = {16'(2*16 - 5), 16'(2*16 - 5), 16'(2*16 - 5), 16'(2*16 - 5)};
        @(negedge clk);
        sew = 4'b0010;
        opA = {32'(-1), 32'(-1)};
        opB = {32'(-1), 32'(-1)};
        @(negedge clk);
        $finish;
    end

endmodule