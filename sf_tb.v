`timescale 1ns / 1ps

module sf_tb;

reg clk;
reg rst;
reg signed [15:0] data_in;
wire signed [15:0] data_out;
reg integer file_handle;

// Instantiate the filter module
sf filter_inst (
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .data_out(data_out)
);

// Clock generation
always #5 clk = ~clk;


// Stimulus generation
initial begin
    clk = 0;
    rst = 1;
    data_in = 0;
    #10 rst = 0;
    // Open file for writing
    file_handle = $fopen("data.txt", "w");  
    // Check if the file opened successfully
    if (file_handle == 0) begin
        $display("Error opening file for writing");
        $finish; // Terminate simulation
    end

    // Test with some input data
    data_in = 100;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 200;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 150;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 250;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 180;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 120;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 200;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 220;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 180;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 250;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 190;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    data_in = 150;
    #10 $fdisplay(file_handle, "%d %d", data_in, data_out);
    $fclose(file_handle);
    $finish;
end

endmodule
