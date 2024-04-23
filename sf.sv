`timescale 1ns / 1ps

module SF (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] dat,
    input wire rdy,
    input wire [7:0] len,
    input reset,
    output reg req,
    output reg [7:0] filtered_data [31:0]
);

// Internal registers for filter
parameter reg [3:0] M = 2; //Size of filter
reg [7:0] sum;
integer file_handle;

// Internal registers for adc values
reg [7:0] adc_data [31:0];
reg started;
reg eof;
reg [7:0]idx;
string s;

always @(posedge start) begin
    started <= 1;
end

always @(posedge clk) begin 
    if (rst) begin
        $display("SF module reset");
        sum <= 0;
        req <= 0;
        started <= 0;
        idx <= 0;
        eof <= 0;

    // Read in signal from the adc

    end else if (started && !eof) begin // Idle mode until start
        if (started && !req) begin
            req <= 1;   // Request ADC value once start signal received
        end else if (rdy) begin // ADC ready, read in value
            adc_data[idx] <= dat;
            //#1 $display("%d",adc_data[idx]);
            #1 idx <= idx+1;
            req <= 0;
            if (dat == 255) begin
                //$display("Reached end of file");
                eof = 1;

                // Concatenate array elements into a string
                for (int i = 0; i < len; i = i + 1) begin
                    s = {s, $sformatf("%h", adc_data[i]), " "}; // Concatenate each element with a space separator
                end
                $display("ADC data read in: %s",s);
                s = "";
            end
        end

    // Apply filter once read in adc values

    end else if (eof) begin
        for(int i = 0; i < len; i = i + 1) begin
            sum = 0;
            for(int j = 0; j < M; j = j + 1) begin
                sum = sum + adc_data[i+j];
            end
            filtered_data[i] = sum/M;         
        end
        started = 0;
        eof = 0;
        for (int i = 0; i < len; i = i + 1) begin
            s = {s, $sformatf("%h", filtered_data[i]), " "}; // Concatenate each element with a space separator
        end
        $display("Filtered data: %s",s);
        

        file_handle = $fopen("output.txt", "w"); // Open the file for writing
        for (int i = 0; i < len; i = i + 1) begin
            $fwrite(file_handle, "%d\n", filtered_data[i]); // Write each element followed by a space separator
        end
        $fclose(file_handle); // Close the file
    end
end

endmodule