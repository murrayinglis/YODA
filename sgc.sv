module sgc(
    input wire signed [31:0] data_window [0:WINDOW_SIZE-1], // Input data window
    output reg [31:0] polynomial_coefficients [0:DEGREE],
    output reg [31:0] sum_of_weights,
    output reg signed [31:0] y_values [0:WINDOW_SIZE-1] // Output y-values
);

parameter WINDOW_SIZE = 7; // Size of the data window
parameter DEGREE = 2; // Degree of the polynomial

integer i, j;
reg [31:0] weight_matrix [0:DEGREE][0:WINDOW_SIZE-1];
reg [31:0] sum_weights;

reg [31:0] x_power;
reg [31:0] x_mult_coef;

always @(*) begin
    sum_weights = 0;
    for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
        // Calculate weights for each data point
        weight_matrix[0][i] = 1;
        for (j = 1; j <= DEGREE; j = j + 1) begin
            weight_matrix[j][i] = weight_matrix[j-1][i] * i;
        end
        sum_weights = sum_weights + weight_matrix[0][i];
    end
    
    // Normalize weights
    for (i = 0; i <= DEGREE; i = i + 1) begin
        for (j = 0; j < WINDOW_SIZE; j = j + 1) begin
            weight_matrix[i][j] = weight_matrix[i][j] / sum_weights;
        end
    end
    
    // Calculate polynomial coefficients
    for (i = 0; i <= DEGREE; i = i + 1) begin
        polynomial_coefficients[i] = 0;
        for (j = 0; j < WINDOW_SIZE; j = j + 1) begin
            polynomial_coefficients[i] = polynomial_coefficients[i] + 
                                          weight_matrix[i][j] * data_window[j];
        end
    end

    for (i = 0; i < WINDOW_SIZE; i = i + 1) begin
        x_power = 1;
        y_values[i] = 0;
        for (j = 0; j <= DEGREE; j = j + 1) begin
            x_mult_coef = x_power * polynomial_coefficients[j];
            y_values[i] = y_values[i] + x_mult_coef;
            x_power = x_power * i;
        end
    end
end

assign sum_of_weights = sum_weights;

endmodule
