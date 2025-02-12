`timescale 1ns/1ps

module spart_unit_tb;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic iocs;
    logic iorw;
    logic rda;
    logic tbr;
    logic [1:0] ioaddr;
    wire [7:0] databus;
    logic txd;
    logic rxd;
    logic [7:0] wrdata;
    logic [7:0] rdata;
    logic rx_done;

    // Instantiate the DUT (Device Under Test)
    spart uut (
        .clk(clk),
        .rst_n(rst_n),
        .iocs(iocs),
        .iorw(iorw),
        .rda(rda),
        .tbr(tbr),
        .ioaddr(ioaddr),
        .databus(databus),
        .txd(txd),
        .rxd()
    );

    tb_spart spart_tester (
        .clk(clk),
        .rst_n(rst_n),
        .rxd(txd),
        .txd(rxd),
        .rdata(rdata),
        .tdata('0),
        .rx_done(rx_done),
        .start_transmission(0),
        .baud(16'h0064)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns period (100MHz)

    assign databus = !iorw ? wrdata : 8'hz;

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        iocs = 0;
        iorw = 1;  // Read mode
        ioaddr = 2'b00;
        wrdata = 8'h00;
        //rxd = 1;  // Default idle state for UART

        // Reset the system
        #20 rst_n = 1;

        // Write a byte to the upper division buffer
        #10 iocs = 1;
        iorw = 0;  // Write mode
        ioaddr = 2'b11;
        wrdata = 8'h00;  // Example data byte
        #10 iocs = 0;
        iorw = 1;

        // Write a byte to the lower division buffer
        #10 iocs = 1;
        iorw = 0;  // Write mode
        ioaddr = 2'b10;
        wrdata = 8'h64;  // Example data byte
        #10 iocs = 0;
        iorw = 1;
        
        // Write a byte to the TX buffer
        #10 iocs = 1;
        iorw = 0;  // Write mode
        ioaddr = 2'b00;
        wrdata = 8'hA5;  // Example data byte
        #10 iocs = 0;
        iorw = 1;

        // Wait for transmission
        fork 
            begin
                @ (posedge rx_done)begin 
                    if (rdata != 8'hA5)
                        $display("ERROR: incorrect data received: %h", rdata);
                    #2000;
                    $stop;
                end
            end
            begin
                #20000;
                $stop;
            end
        join_any
        #10000;

        $stop;

        // Check if transmission completed
        if (tbr)
            $display("Transmission complete: TX buffer ready.");
        else
            $display("Transmission error: TX buffer not ready.");

        // Observe TXD output
        #100;

        // End simulation
        $stop;
    end
endmodule
