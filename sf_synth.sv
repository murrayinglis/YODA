`timescale 1ns / 1ps

module SF #(
    parameter DATA_WIDTH = 8,
    parameter FILT_SIZE = 10,
    parameter DATA_LEN = 100
) (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg done,
    output reg [DATA_WIDTH-1:0] filtered_data[0:(DATA_LEN)-1]
);

    localparam FILT_SUM_WIDTH = DATA_WIDTH * FILT_SIZE;

    reg [DATA_WIDTH-1:0] data_buffer [FILT_SIZE-1:0];
    reg [$clog2(DATA_LEN):0] data_idx;
    reg [FILT_SUM_WIDTH-1:0] sum;
    reg started;
    reg[$clog2(DATA_LEN)-1:0] winNum;

    always @(posedge clk) begin
        if (rst) begin
            data_idx <= 0;
            sum <= 0;
            started <= 0;
            winNum <= 0;
        end else if (start) begin
            started <= 1;
        end else if (started) begin
            sum <= 0;
            //First 4 values must be read before any output written
            if (data_idx < FILT_SIZE) begin
                data_buffer[data_idx] = data_in;
                // $display("Writing data_buffer[%d]: %d", data_idx, data_buffer[data_idx]);
                data_idx = data_idx + 1;
            end 
            else if(data_idx < DATA_LEN) begin
                for (int j = 0; j < FILT_SIZE; j = j + 1) begin
                    sum = sum + data_buffer[j];
                    // $display("Reading data_buffer[%d]: %d", (filt_idx+j), data_buffer[(filt_idx + j)]);
                end
                filtered_data[winNum] = sum /FILT_SIZE;
                $display(filtered_data[winNum]);
                winNum <= winNum + 1;
                data_buffer[data_idx % FILT_SIZE] <= data_in;
                data_idx <= data_idx + 1;
            end
            else begin
                done <= 1;
            end
        end
    end

endmodule