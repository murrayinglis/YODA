`timescale 1ns / 1ps

module top_level#(FILT_SIZE=10, DATA_LEN=100)(input wire clk, input wire rx_serial, input wire[7:0] src, input wire[7:0] len, input wire[7:0] dest, input wire begin_filter, input wire transmit_result,  output reg process_done);

/*
INPUTS:
src: location in memory noisy signal is stored
len: length of noisy signal
dest: location in memory to write output
*/
reg[7:0] address;
reg[7:0] data_value; //For writing to RAM
wire[7:0] data;
reg cs, we, oe;
wire done;

reg rst, start;
wire[7:0] filtered_data[DATA_LEN-1:0];

ramcu ramcu_uut(clk, address, data, cs, we, oe);
assign data = !oe ? data_value : 'bz;

SF sf(clk, rst, start, data, done, filtered_data);

reg[7:0] read_byte;
reg data_valid_tx, rst_tx;
reg[7:0] tx_byte;
wire tx_active, tx_serial, tx_done;
UART_RX uart_rx(clk, rx_serial, data_valid_rx, read_byte);
UART_TX uart_tx(rst_tx, clk, data_valid_tx, tx_byte, tx_active, tx_serial, tx_done);

//States: idle (00), start filter(01), filter(10), write_to_mem(11)

reg[7:0] spots;
reg started;

reg reset_sf;
reg start_sf;
reg[2:0] state;
reg wait_cycle;
parameter[2:0] IDLE = 3'b000;
parameter[2:0] POPULATE_RAM = 3'b001;
parameter[2:0] RESET = 3'b010;
parameter[2:0] FILTER = 3'b011;
parameter[2:0] WRITE = 3'b100;
parameter[2:0] READ_OUTPUT = 3'b101;
parameter[2:0] TRANSMIT = 3'b110;

/*
Process: 
    once src, len and dest are provided. User will start the smoothing process
    when the smoothing process is finished, the smoothed signal is written to memory at address dest
*/

initial begin

    //Start in IDLE state
    state= 2'b00;
    reset_sf = 1;
    start_sf = 1;

    //Initialize RAM for writing
    cs = 1; we = 0; oe = 0;
    spots = 8'b0;
    address <= src;
    wait_cycle = 1;
    started = 0;

end

always @ (posedge clk) begin
    begin
        case(state)
            IDLE: begin
                if(begin_filter) begin
                   state <= RESET;
                end
                else if(data_valid_rx) begin
                    data_value = read_byte;
                    we <= 1;
                    state <= POPULATE_RAM;
                end
                else if(transmit_result) begin
                    we <= 0;
                    oe <= 1;
                    address <= dest;
                    wait_cycle <= 1;
                    state <= TRANSMIT;
                end
                else state <= IDLE;
            end
            POPULATE_RAM: begin
                if(spots < len) begin
                    address <= address + 1;
                    spots <= spots + 1;
                    state <= IDLE;
                    // $display("Writing %d to mem[%d]", data_value, address);
                end else begin
                    we <= 0;
                    address <= src;
                    state <= RESET;
                end
            end
            RESET: begin
                if(reset_sf) begin
                    rst <= 1;
                    we <= 0;
                    oe <= 1;
                    reset_sf <= 0;
                end
                else begin
                    rst <= 0;
                    address <= src;
                    state <= FILTER;
                    // $display("Data ending reset (address %d): %d", address, data);
                end
            end 
            FILTER: begin
                if(start_sf) begin
                    start = 1;
                    //read from address 0 on next pos edge
                    start_sf = 0;
                end
                else begin
                    address <= address + 1;
                    //SF starts on next pos edge
                    if(!started) begin
                        start <= 0;
                        started <= 1;
                    end else begin
                        //Supplied whole signal to SF
                        if(address-src == DATA_LEN+1) begin
                            state <= WRITE;
                            rst <= 1;
                            we <= 1;
                            oe <= 0;
                            address <= dest;
                            data_value <= filtered_data[0];
                            spots <= 1;
                            // $display("Writing Mem[%d]: %d", address, data);
                        end
                    end
                end
            end
            WRITE: begin
                rst <= 0;
                if(spots <= DATA_LEN-FILT_SIZE) begin
                    address <= address + 1;
                    data_value <= filtered_data[spots];
                    spots <= spots + 1;
                    $display("Writing mem[%d] <- %d", address, data_value);
                end else begin
                    state <= IDLE;
                end
            end
            TRANSMIT: begin
                if(wait_cycle) begin
                    wait_cycle <= 0;
                end
                else begin
                    data_valid_tx <= 1;
                    tx_byte <= data;
                    address <= address + 1;
                    $display("Transmitting: mem[%d]: %d", address, data);
                    @(posedge tx_done);
                    if(address == dest+DATA_LEN-FILT_SIZE) begin
                        process_done <= 1;
                        state <= IDLE;
                    end
                end
            end
        endcase
    end
end

endmodule