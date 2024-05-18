`timescale 1ns / 1ps

module whole_tb();

    reg clk, begin_filter;
    reg[7:0] src, dest, len;
    top_level top(clk, src, len, dest, begin_filter);

    initial begin
        clk = 0;
        forever #5 clk=~clk;
    end

    initial begin
        begin_filter = 0;
        src = 8'b0;
        dest = 8'd100;
        len = 8'd50;
        #10
        //Start filtering
        begin_filter = 1;
        #10
        begin_filter = 0;
        #2000
        $finish;
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, whole_tb); // Dump all variables in the testbench
    end 

endmodule