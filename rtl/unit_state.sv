module unit_state #(
    parameter int WIDTH     = 32,
    parameter int OP_BITS   = 1
)(
    input logic clk,
    input logic rst,

    input   logic valid,
    output  logic pop,

    input   logic ready,
    output  logic push,

    output  logic compute_start,
    input   logic compute_end,

    input   logic [WIDTH - 1 : 0] unit_result,

    output  logic [WIDTH - 1 : 0] result
);


    typedef enum logic [1 : 0] {
        WAIT_READY,
        WAIT_VALID,
        COMPUTE,
        WAIT_BUFFER
    } state_e;

    state_e state;
    state_e next_state;

    logic buffer_push;
    logic buffer_ready;
    logic buffer_valid;
    logic buffer_pop;

    logic result_valid;

    always_ff @(posedge clk) begin : next_values
        state      <= next_state;
    end

    always_comb begin : fsm_state
        next_state = state;
        if (rst) begin
            if (ready && valid) next_state = COMPUTE;
            else if (ready) next_state = WAIT_VALID;
            else next_state = WAIT_READY;
        end else case (state)
            WAIT_READY : begin
                if (ready) begin
                    if (valid) next_state = COMPUTE;
                    else next_state = WAIT_VALID;
                end
            end
            WAIT_VALID : begin
                if (valid) next_state = COMPUTE;
            end
            COMPUTE : begin
                if (compute_end) begin
                    if (buffer_ready && ready && valid) next_state = COMPUTE;
                    else if (buffer_ready && ready) next_state = WAIT_VALID;
                    else if (buffer_ready) next_state = WAIT_READY;
                    else next_state = WAIT_BUFFER;
                end
            end
            WAIT_BUFFER : begin
                if (buffer_ready) begin
                    if (ready && valid) next_state = COMPUTE;
                    else if (ready) next_state = WAIT_VALID;
                    else  next_state = WAIT_READY;
                end
            end
        endcase
    end

    assign compute_start = (state != COMPUTE || compute_end) && next_state == COMPUTE;

    assign result_valid = compute_end || state == WAIT_BUFFER;

    assign buffer_push  = buffer_ready & result_valid;
    assign buffer_pop   = buffer_valid & ready;

    assign push = buffer_pop;
    assign pop  = compute_start;

    buffer #(.WIDTH(WIDTH)) buffer (
        .clk    (clk),
        .rst    (rst),
        .push   (buffer_push),
        .ready  (buffer_ready),
        .data_i (unit_result),
        .valid  (buffer_valid),
        .pop    (buffer_pop),
        .data_o (result)
    );

endmodule