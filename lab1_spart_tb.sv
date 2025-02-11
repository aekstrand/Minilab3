module lab1_spart_tb();

    // DUT inputs
    logic clk;
    logic [3:0] KEY;
    logic [9:0] SW;

    // DUT outputs
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;

    // DUT inouts
    logic [35:0] GPIO;
    
    // tb signals
    logic err;

    // DUT
    lab1_spart iDUT (.CLOCK_50(clk), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .KEY(KEY), .LEDR(LEDR), .SW(SW), .GPIO(GPIO));

    initial begin
        $display("Initializing testbench!");
        clk = 0;
        err = 0;
        KEY = 4'b0000;
        SW = 10'h000;
        GPIO = 36'hfffffffff;
        @(negedge clk);
        $display("Reseting device (4800 baud)...");
        KEY[0] = 0;
        @(negedge clk);
        KEY[0] = 1;
        repeat(2) @(negedge clk);
        $display("Verifying that correct baud rate has been loaded (4800)...");
        if(HEX0 !== 7'b1000000 || HEX1 !== 7'b1000000 || HEX2 !== 7'b0000000 || HEX3 !== 7'b0011001 || HEX4 !== 7'b1111111 || HEX5 !== 7'b11111111) begin
            $display("ERROR: Baud rate not set correctly! Recieved 0: %b 1: %b 2: %b 3: %b 4: %b 5: %b.", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
            err = 1;
        end

    end

    always #50 clk = ~clk;

endmodule