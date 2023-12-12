module vector_divide_unit #(
    parameter int WIDTH = 64
)(
    input logic clk,

    input   logic compute_start,
    output  logic compute_end,

    input   logic [WIDTH - 1 : 0] a,
    input   logic [WIDTH - 1 : 0] b,

    input logic op,
    input logic [$clog2(WIDTH/8) - 1 : 0] sew,

    output  logic [WIDTH - 1 : 0] result
);

    logic [WIDTH - 1 : 0] div;
    logic [WIDTH - 1 : 0] rem;
    logic [WIDTH - 1 : 0] saved_a;
    logic [WIDTH - 1 : 0] saved_b;
    logic  saved_op;

    logic invert;
    assign invert = {rem[WIDTH - 2 : 0], saved_a[WIDTH - 1]}  >= saved_b;

    logic [WIDTH - 1 : 0] sub_rem;
    assign sub_rem = {rem[WIDTH - 2 : 0], saved_a[WIDTH - 1]} - saved_b;

    logic [$clog2(WIDTH) : 0] left_zeros_a;
    logic [$clog2(WIDTH) : 0] right_zeros_a;
    logic [$clog2(WIDTH) : 0] counter;

    logic computing;
    logic found_left_a;
    logic found_right_a;
    always_comb begin
        left_zeros_a    = 0;
        right_zeros_a   = 0;
        found_left_a    = 1'b0;
        found_right_a   = 1'b0;
        for (int i = 0; i < WIDTH; ++i) begin
            if (!(a[WIDTH - i - 1] || found_left_a)) left_zeros_a += 1;
            if (!(a[i] || found_right_a)) right_zeros_a += 1;
            if (a[WIDTH - i - 1]) found_left_a = 1'b1;
            if (a[i]) found_right_a = 1'b1;
        end
    end

    always_ff @(posedge clk) begin
        if (compute_start) counter <= right_zeros_a;
        else if (computing && !(|saved_a) && counter > 0) counter <= counter - 1;
    end
    assign compute_end = computing && counter == 0;
    always_ff @(posedge clk) begin
        if (compute_start) computing = 1'b1;
        else if (compute_end) computing = 1'b0;
    end

    always_ff @(posedge clk) begin
        if (compute_start) begin
            saved_a     <= a << left_zeros_a;
            saved_b     <= b;
            saved_op    <= op;
            div         <= 0;
            rem         <= 0;
        end else begin
            saved_a <= {saved_a[WIDTH - 2 : 0], 1'b0};
            rem[0] <= invert ? sub_rem[0] : saved_a[WIDTH - 1];
            for (int i = 1; i < WIDTH; ++i) begin
                rem[i] <= invert ? sub_rem[i] :  rem[i - 1];
            end
            div <= {div[WIDTH - 2 : 0], invert};
        end
    end

    assign result = saved_op ? div : rem;

endmodule