module poly_eval(
    input signed [31:0] x_values [0:WINDOW_SIZE-1], // Input x-values
    input signed [31:0] polynomial_coefficients [0:DEGREE], // Polynomial coefficients
    output reg signed [31:0] y_values [0:WINDOW_SIZE-1] // Output y-values
);

parameter WINDOW_SIZE = 7; // Size of the data window
parameter DEGREE = 2; // Degree of the polynomial

integer i, j;
reg signed [31:0] x_power;
reg signed [31:0] x_mult_coef;

always @(*) begin
    for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
        x_power = 1;
        y_values[i] = 0;
        for (j = 0; j <= DEGREE; j = j + 1) begin
            x_mult_coef = x_power * polynomial_coefficients[j];
            y_values[i] = y_values[i] + x_mult_coef;
            x_power = x_power * x_values[i];
        end
    end
end

endmodule
