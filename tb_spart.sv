module tb_spart(
    input clk,
    input rst_n,
    input rxd,
    output [7:0] rdata,
    output txd,
    input [7:0] tdata,
    output logic rx_done,
    input start_transmission,
    input [15:0] baud
);

    typedef enum logic [1:0] {IDLE, READ, WRITE} state_t;
    state_t state, next_state;

    logic [8:0] shift_reg, read_reg;
    logic enable, load, reset_cnt, reset_rd;

    logic [15:0] count;
    logic [2:0] cnt;

    assign txd = shift_reg[0];
    assign rdata = read_reg[8:1];

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 0;
        end else if(reset_cnt) begin
            cnt <= 0;
        end else if(enable) begin
            cnt <= cnt + 1;
        end else begin
            cnt <= cnt;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            read_reg <= 9'hfff;
        end else if(reset_rd) begin
            read_reg <= '1;
        end else if(enable) begin
            read_reg <= {rxd, read_reg[8:1]};
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            count <= baud;
            enable <= 0;
        end else if(count === 16'h0000) begin
            count <= baud;
            enable <= 1;
        end else begin
            count <= count - 1;
            enable <= 0;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            shift_reg <= '1;
        end else if(load) begin
            shift_reg <= {tdata, 1'b0};
        end else if(enable) begin
            shift_reg <= {1'b1, shift_reg[8:1]};
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        rx_done = 0;
        reset_cnt = 0;
        load = 0;
        reset_rd = 0;
        case(state)
            WRITE: begin
                if(cnt === 3'b111) begin
                    next_state = IDLE;
                end
            end
            READ: begin
                if(read_reg[0] === 1'b0) begin
                    rx_done = 1'b1;
                    next_state = IDLE;
                end
            end
            default: begin
                if(start_transmission) begin
                    load = 1;
                    reset_cnt = 1;
                    next_state = WRITE;
                end
                if(~rxd) begin
                    reset_cnt = 1;
                    reset_rd = 1;
                    next_state = READ;
                end
            end
        endcase
    end

endmodule