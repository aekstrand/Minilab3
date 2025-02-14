//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        iocs,
    input  logic        iorw,
    output logic        rda,
    output logic        tbr,
    input  logic [1:0]  ioaddr,
    inout  logic [7:0]  databus,
    output logic        txd,
    input  logic        rxd
);

logic [7:0] tx_buffer, rx_buffer;
logic [15:0] db_buffer;
logic [3:0] tx_count, rx_count;
logic       trx_en;
logic       transmitting;
logic reset_rda, set_rda;
int         baud_count;

typedef enum logic[1:0]{IDLE, TX_START, TX, RX} state_t;
state_t state, nxt_state;

assign load_tx_buf = (ioaddr == 2'b00) && !iorw && iocs;
assign databus = ((ioaddr == 2'b00) && iorw && iocs) ? rx_buffer : 8'bzzzzzzzz;
assign reset_rda = (ioaddr == 2'b00) && iorw && iocs;

// Transmit buffer
always_comb begin
    if (transmitting && state == TX_START)
        txd <= 1'b0;
    else if (transmitting)
        txd <= tx_buffer[0];
    else
        txd <= 1'b1;
end

// TX data output
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        tx_buffer <= 8'h00;
    else if (load_tx_buf)
        tx_buffer <= databus;
    else if (transmitting && trx_en && state == TX)
        tx_buffer <= tx_buffer >> 1;
    else
        tx_buffer <= tx_buffer;
end

// Division buffers
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        db_buffer <= 16'h0000;
    end
    else if (ioaddr == 2'b10 && !iorw && iocs) begin
        db_buffer <= {db_buffer[15:8], databus};
    end
    else if (ioaddr == 2'b11 && !iorw && iocs) begin
        db_buffer <= {databus, db_buffer[7:0]};
    end
    else begin
        db_buffer <= db_buffer;
    end
end

// TX bit count
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        tx_count <= 8'h00;
    else if (transmitting && trx_en && state == TX)
        tx_count <= tx_count + 1'b1;
    else if (transmitting)
        tx_count <= tx_count;
    else
        tx_count <= 8'h00;
end

// RX bit count
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_count <= 8'h00;
        rx_buffer <= '0;
    end
    else if (trx_en && state == RX) begin
        rx_count <= rx_count + 1'b1;
        rx_buffer <= {rxd, rx_buffer[7:1]};
    end
    else if (state == RX) begin
        rx_count <= rx_count;
        rx_buffer <= rx_buffer;
    end
    else begin
        rx_count <= 8'h00;
        rx_buffer <= rx_buffer;
    end
end

// Baud rate generator
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        baud_count <= db_buffer;
        trx_en <= 1'b0;
    end
    else if (baud_count == 16'h0000) begin
        baud_count <= db_buffer;
        trx_en <= 1'b1;
    end
    else begin
        baud_count <= baud_count - 1'b1;
        trx_en <= 1'b0;
    end
end

// rda set-reset
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rda <= 0;
    end else if(set_rda) begin
        rda <= 1;
    end else if(reset_rda) begin
        rda <= 0;
    end else begin
        rda <= rda;
    end
end


/////////////////////// Control FSM ///////////////////////

always_ff @(posedge clk or negedge rst_n)
    if (!rst_n)
        state <= IDLE;
    else
        state <= nxt_state;

always_comb begin
    nxt_state = state;
    transmitting = 1'b0;
    set_rda = 1'b0;
    tbr = 1'b0;

    case(state)
        IDLE : begin
            tbr = 1'b1;
            if (load_tx_buf)
                nxt_state = TX_START;
            else if (!rxd && trx_en)
                nxt_state = RX;
        end
        TX_START : begin
            transmitting = 1'b1;
            if (trx_en)
                nxt_state = TX;
        end
        TX : begin
            transmitting = 1'b1;
            if (tx_count == 7 && trx_en)
                nxt_state = IDLE;
        end
        RX : begin
            if (rx_count == 7 & trx_en) begin
                nxt_state = IDLE;
                set_rda = 1'b1;
            end
        end
        default : nxt_state = IDLE;
    endcase
end

endmodule
