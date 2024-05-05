module LSR (
    input [15:0] data [0:DATA_SIZE-1], // Input array of data points
    input reg [15:0] shift, // how much window is shifted by
    input wire rst,
    input wire start,
    output reg signed [15:0] m,         // gradient
    output reg signed [15:0] b          // y intercept
);

parameter SCALE_FACTOR = 1;
parameter ALPHA = 8'b0000_0001;

// fixed-point (Q24.8)
reg signed [31:0] m_fixed = 32'h0;
reg signed [31:0] b_fixed = 32'h0;
reg signed [31:0] partial_b = 32'h0;
reg signed [31:0] partial_m = 32'h0;
reg signed [31:0] x = 0;
reg signed [31:0] y = 0;
reg signed [31:0] x_fixed = 32'h0;
reg signed [31:0] y_fixed = 32'h0;
reg signed [31:0] temp = 32'h0; 


integer unsigned i; // Loop counter
reg started;

always @(posedge start) begin
    started = 1;
end

always @* begin
    if (rst) begin
        started <= 0;
        m_fixed <= 32'h0;
        b_fixed <= 32'h0;
        partial_b <= 32'h0;
        partial_m <= 32'h0;
    end else if (started) begin


        for (i = 0; i < DATA_SIZE; i = i + 1) begin
            //$display("x: %d, y: %d", x_fixed[31:16], $signed(y_fixed[31:16]));
            //$display("b: %b, m: %b", $signed(b_fixed), $signed(m_fixed));
            $display("b: %d, m: %d", $signed(b_fixed[31:16]), $signed(m_fixed[31:16]));
            x = (i+shift);
            y = data[i+shift];
            x_fixed = x<<16;
            y_fixed = y<<16;
            
            temp = (m_fixed[31:16] * x_fixed[31:16]) + (m_fixed[15:0] * x_fixed[15:0]); // int part + frac part
            partial_b = 2*(b_fixed+temp-y_fixed);
            //$display("temp: %b", temp[31:0]);
            //$display("pb: %b", partial_b[31:0]);

            temp = 2*(b_fixed+temp-y_fixed);
            temp = (x_fixed[31:16] * temp[31:16]) + (x_fixed[15:0] * temp[15:0]); // int part + frac part
            partial_m = temp;

            //partial_m = 2*x_fixed*(b_fixed+m_fixed*x_fixed-y_fixed);


            // Update m and b using fixed-point arithmetic
            b_fixed = b_fixed - (partial_b >> 10); 
            m_fixed = m_fixed - (partial_m >> 10); 
        end

        started <= 0;


        $display("b: %d, m: %d", $signed(b_fixed[31:16]), $signed(m_fixed[31:16]));
    end
end

endmodule
