module SG(
    input clk,
    input rst,
    input start,
    input signed [15:0] data_in,
    output reg signed [15:0] data_out,
    output reg done
);

parameter WINDOW_SIZE = 55;
parameter POLYNOMIAL_DEGREE = 5;

// Assuming WINDOW_SIZE of 55 and POLYNOMIAL_DEGREE of 5
// The coefficients need to be defined according to the application requirement
// For a 5th degree polynomial, you might have something like the following:
// These values are just placeholders and should be calculated for your specific application
localparam signed [15:0] coefficients[0:WINDOW_SIZE-1] = '{...};

reg signed [15:0] data_window [0:WINDOW_SIZE-1];
integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        data_out <= 0;
        done <= 0;
        for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
            data_window[i] <= 0;
        end
    end else begin
        if (start) begin
            // Shift data in the window and insert the new sample
            for (i = WINDOW_SIZE-1; i > 0; i = i - 1) begin
                data_window[i] <= data_window[i-1];
            end
            data_window[0] <= data_in;

            // Check if the window is filled to start filtering
            if (data_window[WINDOW_SIZE-1] !== 0) begin
                done <= 1; // Signal that filtering can be done
                data_out <= perform_filtering(data_window, coefficients);
            end
        end
    end
end

// Perform filtering using the Savitzky-Golay coefficients
function signed [15:0] perform_filtering(
    input signed [15:0] window[WINDOW_SIZE],
    input signed [15:0] coeffs[WINDOW_SIZE]
);
    signed [31:0] sum = 0; // Extended size to avoid overflow
    integer j;
    begin
        for (j = 0; j < WINDOW_SIZE; j = j + 1) begin
            sum = sum + window[j] * coeffs[j];
        end
        perform_filtering = sum >>> 16; // Adjust the scaling if necessary
    end
endfunction

endmodule