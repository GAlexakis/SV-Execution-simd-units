module div_test;

    localparam int WIDTH = 32;
    logic clk;
    logic rst;
    logic valid;
    logic pop;
    logic ready;
    logic push;
    logic [WIDTH - 1 : 0] a;
    logic [WIDTH - 1 : 0] b;
    logic op;
    logic [WIDTH - 1 : 0] result;

    divider #(.WIDTH(WIDTH)) dut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .pop(pop),
        .ready(ready),
        .push(push),
        .op(op),
        .a(a),
        .b(b),
        .result(result)
    );

    always begin
        clk = 1'b1;
        #5;
        clk = 1'b0;
        #5;
    end

    initial begin
        rst = 1'b1;
        @(negedge clk);
        @(negedge clk);
        rst = 1'b0;
        a = 126;
        b = 17;
        op = 1;
        $display("div = %d, rem = %d", a/b, a%b);
        @(negedge clk);
        valid = 1'b1;
        repeat (200) @(negedge clk);
        ready = 1'b1;
        @(negedge clk);
        a = 30;
        b = 29;
        op = 0;
        repeat (200) @(negedge clk);

        $finish;
    end

endmodule