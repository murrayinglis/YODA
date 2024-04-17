module sf(
    input clk,            // Clock input
    input rst,            // Reset input
    input signed [15:0] data_in,   // Input data
    output reg signed [15:0] data_out // Output smoothed data
);

parameter COEFF_A0 = 8'b00000001; // Coefficients for second-order filter
parameter COEFF_A1 = 8'b00000010;
parameter COEFF_A2 = 8'b00000001;

reg signed [31:0] acc; // Accumulator for the filter

always @(posedge clk or posedge rst) begin
    if (rst) begin
        acc <= 0; // Reset accumulator on reset signal
        data_out <= 0; // Reset output
    end else begin
        // Update accumulator with new input
        acc <= data_in + (COEFF_A0 * acc) + (COEFF_A1 * (data_in - data_out)) + (COEFF_A2 * (data_in - (2 * data_out) + acc));
        // Output smoothed data
        data_out <= acc >> 16; // Right shift to get rid of accumulated bits
    end
end

endmodule
