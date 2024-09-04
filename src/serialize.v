module serialize #(parameter MSG_SIZE = 512)(
    input iClk,
    input iRst,
    input iEncrypt_done,
    input [MSG_SIZE - 1:0] iCiphertext,
    output reg oSerial_out,
    output reg oSerial_start,
    output reg oSerial_end
);

integer serial_counter;

always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin
        oSerial_out   <= 0;   
        oSerial_start <= 0; 
        oSerial_end   <= 0;    
        serial_counter <= MSG_SIZE - 1;  // Initialize counter to start from MSB
    end else if (iEncrypt_done && serial_counter >= 0) begin
        oSerial_start <= 1;  // Start serializing
        oSerial_out <= iCiphertext[serial_counter];  // Output current bit
        
        if (serial_counter > 0) begin
            serial_counter <= serial_counter - 1;  // Decrement counter
        end else if (serial_counter == 0) begin
            oSerial_end <= 1;  // Signal the end of serialization
            serial_counter <= -1;  // Prevent further decrementing
        end
    end
end

endmodule
