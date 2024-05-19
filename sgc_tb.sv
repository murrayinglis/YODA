`timescale 1ns / 1ps

module sgc_tb;

    // Parameters
    parameter WINDOW_SIZE = 7;
    parameter DEGREE = 2;

    // Signals
    reg signed [31:0] data_window [0:WINDOW_SIZE-1];
    reg clk = 0;
    reg reset = 1;
    wire reg [31:0] polynomial_coefficients [0:DEGREE];
    wire [31:0] sum_of_weights;
    wire signed [31:0] y_values [0:WINDOW_SIZE-1];

    // Instantiate Savitzky-Golay Coefficients module
    sgc coefficients_dut (
        .data_window(data_window),
        .polynomial_coefficients(polynomial_coefficients),
        .sum_of_weights(sum_of_weights),
        .y_values(y_values)
    );


    // Clock generation
    always #5 clk = ~clk;

    // Initialize data window
    initial begin
        // Provide sample data
        data_window[0] = 10;
        data_window[1] = 20;
        data_window[2] = 30;
        data_window[3] = 40;
        data_window[4] = 50;
        data_window[5] = 60;
        data_window[6] = 70;

        // Apply reset
        #10 reset = 0;
    end

    // Stimulus
    initial begin
        // Wait for a few clock cycles after reset
        #20;

        // Display results
        $display("Input Data Window:");
        for (int i = 0; i < WINDOW_SIZE; i = i + 1) begin
            $display("%d: %d", i, data_window[i]);
        end

        $display("Polynomial Coefficients:");
        for (int i = 0; i <= DEGREE; i = i + 1) begin
            $display("%d: %d", i, polynomial_coefficients[i]);
        end

        $display("Output y values:");
        for (int i = 0; i < WINDOW_SIZE; i = i + 1) begin
            $display("%d: %d", i, y_values[i]);
        end

        // End simulation
        #10 $finish;
    end

endmodule
