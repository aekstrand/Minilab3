module lab1_spart_tb();

    // DUT inputs
    logic clk;
    logic [3:0] KEY;
    logic [9:0] SW;

    // DUT outputs
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;

    // DUT inouts
    wire [35:0] GPIO;
    
    // tb signals
    logic err;
    logic [7:0] rdata, tdata;
    logic rx_done, start_transmission;

    // DUT
    lab1_spart iDUT (.CLOCK_50(clk), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .KEY(KEY), .LEDR(LEDR), .SW(SW), .GPIO(GPIO));

    // SPART sender
    tb_spart transceiver (.clk(clk), .rst_n(KEY[0]), .rxd(GPIO[3]), .rdata(rdata), .txd(GPIO[5]), .tdata(tdata), .rx_done(rx_done), .start_transmission(start_transmission), .baud(iDUT.spart0.db_buffer));

    initial begin
        $display("Initializing testbench!");
        clk = 0;
        err = 0;
        KEY = 4'b0000;
        SW = 10'h000;
        tdata = 8'h65;
        @(negedge clk);
        $display("Reseting device (4800 baud)...");
        KEY[0] = 0;
        @(negedge clk);
        KEY[0] = 1;
        repeat(200) @(negedge clk);
        $display("Verifying that correct baud rate has been loaded (4800)...");
        if(HEX0 !== 7'b1000000 || HEX1 !== 7'b1000000 || HEX2 !== 7'b0000000 || HEX3 !== 7'b0011001 || HEX4 !== 7'b1111111 || HEX5 !== 7'b11111111) begin
            $display("ERROR: Baud rate not set correctly! Recieved 0: %b 1: %b 2: %b 3: %b 4: %b 5: %b.", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
            err = 1;
        end
        // Send 'e' to SPART
        start_transmission = 1;
        @(negedge clk);
        start_transmission = 0;
        @(posedge rx_done);
        $display("Verifying sending 'e' at 4800!");
        if(rdata !== tdata) begin
            $display("ERROR: Recieved %h and expected %h!", rdata, tdata);
            err = 1;
        end
        repeat(200) @(negedge clk);
        // Send '{' (8'h7b)
        tdata = 8'h7b;
        start_transmission = 1;
        @(negedge clk);
        start_transmission = 0;
        @(posedge rx_done);
        $display("Verifying sending '{' at 4800!");
        if(rdata !== tdata) begin
            $display("ERROR: Recieved %h and expected %h!", rdata, tdata);
            err = 1;
        end
        repeat(200) @(negedge clk);
        $display("Changing baud to 9600!");
        SW[8] = 1;
        KEY[0] = 0;
        @(negedge clk);
        KEY[0] = 1;
        @(negedge clk);
        // Send 'e' to SPART
        tdata = 8'h65;
        start_transmission = 1;
        @(negedge clk);
        start_transmission = 0;
        @(posedge rx_done);
        $display("Verifying sending 'e' at 9600!");
        if(rdata !== tdata) begin
            $display("ERROR: Recieved %h and expected %h!", rdata, tdata);
            err = 1;
        end
        repeat(200) @(negedge clk);
        // Send '{' (8'h7b)
        tdata = 8'h7b;
        start_transmission = 1;
        @(negedge clk);
        start_transmission = 0;
        @(posedge rx_done);
        $display("Verifying sending '{' at 9600!");
        if(rdata !== tdata) begin
            $display("ERROR: Recieved %h and expected %h!", rdata, tdata);
            err = 1;
        end
        repeat(200) @(negedge clk);
        $display("Changing baud to 19200!");
        SW[8] = 0;
        SW[9] = 1;
        KEY[0] = 0;
        @(negedge clk);
        KEY[0] = 1;
        @(negedge clk);
        // Send 'e' to SPART
        tdata = 8'h65;
        start_transmission = 1;
        @(negedge clk);
        start_transmission = 0;
        @(posedge rx_done);
        $display("Verifying sending 'e' at 19200!");
        if(rdata !== tdata) begin
            $display("ERROR: Recieved %h and expected %h!", rdata, tdata);
            err = 1;
        end
        repeat(200) @(negedge clk);
        // Send '{' (8'h7b)
        tdata = 8'h7b;
        start_transmission = 1;
        @(negedge clk);
        start_transmission = 0;
        @(posedge rx_done);
        $display("Verifying sending '{' at 19200!");
        if(rdata !== tdata) begin
            $display("ERROR: Recieved %h and expected %h!", rdata, tdata);
            err = 1;
        end
        repeat(200) @(negedge clk);
        $display("Changing baud to 38400!");
        SW[8] = 1;
        KEY[0] = 0;
        @(negedge clk);
        KEY[0] = 1;
        @(negedge clk);
        // Send 'e' to SPART
        tdata = 8'h65;
        start_transmission = 1;
        @(negedge clk);
        start_transmission = 0;
        @(posedge rx_done);
        $display("Verifying sending 'e' at 38400!");
        if(rdata !== tdata) begin
            $display("ERROR: Recieved %h and expected %h!", rdata, tdata);
            err = 1;
        end
        repeat(200) @(negedge clk);
        // Send '{' (8'h7b)
        tdata = 8'h7b;
        start_transmission = 1;
        @(negedge clk);
        start_transmission = 0;
        @(posedge rx_done);
        $display("Verifying sending '{' at 38400!");
        if(rdata !== tdata) begin
            $display("ERROR: Recieved %h and expected %h!", rdata, tdata);
            err = 1;
        end
        repeat(200) @(negedge clk);

        if(err) begin
            $display("Not all tests passed! See above...");
        end else begin
            $display("YAHOO!!! All tests passed!");
        end
        $stop();

    end

    always #50 clk = ~clk;

endmodule