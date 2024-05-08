module DU (
    input signed [15:0] numerator,
    input signed [15:0] denominator,
    output reg signed [15:0] quotient,
    output reg signed [15:0] remainder
);

reg signed [15:0] temp_numerator;
reg signed [15:0] temp_quotient;
reg signed [15:0] temp_remainder;
reg signed [15:0] shift_value;
integer i;

always @(*) begin
    temp_numerator = numerator;
    temp_quotient = 0;
    temp_remainder = 0;

    for (i = 0; i < 16; i = i + 1) begin
        temp_remainder = temp_remainder << 1;
        temp_remainder[0] = temp_numerator[15];

        shift_value = temp_remainder - denominator;

        if (shift_value >= 0) begin
            temp_remainder = shift_value;
            temp_quotient[i] = 1;
        end

        temp_numerator = temp_numerator << 1;
    end
end

assign quotient = temp_quotient;
assign remainder = temp_remainder;

endmodule
