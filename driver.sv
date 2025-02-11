//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
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
module driver(
    input clk,
    input rst_n,
    input [1:0] br_cfg,
    output logic iocs,
    output logic iorw,
    input rda,
    input tbr,
    output logic [1:0] ioaddr,
    inout logic [7:0] databus
    );

    typedef enum logic [1:0] {LOAD_LOWER_BAUD, LOAD_HIGHER_BAUD, READ, WRITE} state_t;
    state_t state, next_state;

    localparam BAUD_4800 = 16'd4800;
    localparam BAUD_9600 = 16'd9600;
    localparam BAUD_19200 = 16'd19200;
    localparam BAUD_38400 = 16'd38400;

    logic [7:0] stored_data;
    logic store_data, send_baud, send_data;

    assign databus = send_baud ? 
                        (send_data ? 
                            (br_cfg[1] ? 
                                (br_cfg[0] ? 
                                    BAUD_38400[15:8] : 
                                    BAUD_19200[15:8]) : 
                                (br_cfg[0] ? 
                                    BAUD_9600[15:8] : 
                                    BAUD_4800[15:8])) :
                            (br_cfg[1] ? 
                                (br_cfg[0] ? 
                                    BAUD_38400[7:0] : 
                                    BAUD_19200[7:0]) : 
                                (br_cfg[0] ? 
                                    BAUD_9600[7:0] : 
                                    BAUD_4800[7:0]))) :
                        (send_data ?
                            stored_data :
                            8'bzzzzzzzz);

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            state <= LOAD_LOWER_BAUD;
        end else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            stored_data <= 8'h00;
        end else if(store_data) begin
            stored_data <= databus;
        end
    end

    always_comb begin
        // Set defaults
        next_state = state;
        iocs = 1'b0;
        iorw = 1'b0;
        store_data = 1'b0;
        ioaddr = 2'b00;
        send_data = 1'b0;
        send_baud = 1'b0;

        // Adjust by state
        case(state)
            WRITE: begin
                if(tbr) begin
                    iocs = 1'b1;
                    iorw = 1'b0;
                    ioaddr = 2'b00;
                    send_data = 1'b1;
                    next_state = READ;
                end
            end
            READ: begin
                if(rda) begin
                    iocs = 1'b1;
                    iorw = 1'b1;
                    ioaddr = 2'b00;
                    store_data = 1'b1;
                    next_state = WRITE;
                end
            end
            LOAD_HIGHER_BAUD: begin
                iocs = 1'b1;
                ioaddr = 2'b11;
                send_baud = 1'b1;
                send_data = 1'b1;
            end
            default: begin // LOAD_LOWER_BAUD
                iocs = 1'b1;
                ioaddr = 2'b10;
                send_baud = 1'b1;
            end
        endcase
    end


endmodule
