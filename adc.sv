// TSC simulation module

// set simulation time:
`timescale 1ns / 1ps

module ADC (
    input wire req,      // Request signal from TSC
    input wire rst,      // Reset signal for ADC
    output reg rdy,      // Ready signal to indicate completion
    output reg [15:0] dat, // Data output from the array
    output reg [15:0] len
);

// Constant array of values (16 data values)
  // reg [7:0]
  // integer adc_data [15:0] = {
  reg [15:0] adc_data [0:1023];
  // Additional variables
  reg [15:0] file_index; // Variable to keep track of the current index in the array
  reg data_ready;       // Flag to indicate if data is ready to be output
  integer file;         // File handle variable
  reg [15:0] idx;
  integer value;
  integer e;

initial begin
    idx = 0;
    len = 0;
    // Open the CSV file for reading
    file = $fopen("data.csv", "r");
    if (file == 0) begin
        $display("Error opening file");
        $stop;
    end
    // Read the entire CSV file into adc_data array
    while (idx < 10000 && !$feof(file)) begin
        len = len + 1;
        // Read the next value from the file
        e = $fscanf(file, "%d", value);
        //$display("%d",value);
        
        // Check if the value is 255
        if (value == 255) begin
            //$display("End reading");
            adc_data[idx] = value;
            // If value is 255, exit the loop
            idx = 10000;
        end else begin
            // Otherwise, process the value (in this example, store it in an array)
            //$display("%d",adc_data[idx]);
            adc_data[idx] = value;
            //$display("%d",idx);
            idx = idx + 1;
        end
    end
    // Close the file after reading
    $fclose(file);
    // Set data ready flag
    file_index = 0;
    //$display("%d",len);
  end



// Data output process
always @ (posedge req or posedge rst) begin
    //if (req) begin $display("req received"); end
    if (rst) begin
        // Reset the device
        $display("ADC reset");
        rdy <= 0;
        dat <= 8'b00000000; // Reset data output
        file_index <= 0; // Reset array index
        data_ready = 1;
    
    end else if (req && data_ready) begin
        // Read data from the sample array using modular arithmetic
        dat <= adc_data[file_index % 10000]; // Wrap around if file_index exceeds BIG
        file_index <= file_index + 1;
        //#1$display("%d",file_index);
        //#1$display("%d",dat);
        

        // Raise RDY line
        rdy <= 1;
    end else begin
        // Lower RDY line if not processing
        rdy <= 0;
    end
end

endmodule
