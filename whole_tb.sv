`timescale 1ns / 1ps

module whole_tb();
    parameter c_BIT_PERIOD  = 8680;

    wire uart_line, process_done;
    reg clk, begin_filter;
    reg[7:0] src = 8'd0, dest = 8'd150, len = 8'd100;
    top_level top(clk, uart_line, src, len, dest, begin_filter, process_done);

    reg rst, data_valid_tx;
    reg[7:0] tx_byte;
    wire tx_active, tx_serial, tx_done;
    UART_TX uart_tx(rst, clk, data_valid_tx, tx_byte, tx_active, tx_serial, tx_done);
    assign uart_line = tx_active ? tx_serial : 1'b1;

    reg[7:0] data_byte;


    initial begin
        clk = 0;
        forever #5 clk=~clk;
    end

    initial
    begin
        int file, r;
      file = $fopen("data.csv", "r");
      while(!$feof(file)) begin
        r = $fscanf(file, "%d", data_byte);
       // Tell UART to send a command (exercise TX)
        #10
        data_valid_tx  <= 1'b1;
        tx_byte <= data_byte;
        #10
        data_valid_tx <= 1'b0;
        @ (posedge tx_done);
        #(c_BIT_PERIOD);
      end
        begin_filter = 0;
        src = 8'b0;
        dest = 8'd150;
        len = 8'd100;


        #10
        //Start filtering
        begin_filter = 1;
        #10
        begin_filter = 0;
    end

    always @ (posedge process_done) begin
        $finish;
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, whole_tb); // Dump all variables in the testbench
    end 

endmodule