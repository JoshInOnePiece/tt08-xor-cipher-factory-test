`timescale 1ns / 1ps

module tb_xor_encryption_top;

// Parameters
reg iSerial_in;
reg iClk;
reg iRst;
reg iEn;
reg iLoad_key;
reg iLoad_msg;

wire [31:0] oKey;
wire [511:0] oMessage;

reg [31:0] key;
reg [511:0] message;

wire [5:0] bit_counter_key;
wire [9:0] bit_counter_message;

wire [511:0] oCiphertext;
wire oEncrypt_done;

wire [511:0] oAssembled_key;
wire can_encrypt;

wire oSerial_out;
wire oSerial_start;
wire oSerial_end;

reg [511:0] reassembled_serial_out;
integer reassembled_counter;

integer i;

// Clock generation (10 MHz)
localparam CLOCK_PERIOD = 100; // 10 MHz -> T = 1/10MHz = 100 ns
initial iClk = 0;
always #(CLOCK_PERIOD/2) iClk = ~iClk; // Toggle clock every half period

// Instantiate the top module
xor_encryption_top uut (
    .iSerial_in(iSerial_in),
    .iClk(iClk),
    .iRst(iRst),
    .iEn(iEn),
    .iLoad_key(iLoad_key),
    .iLoad_msg(iLoad_msg),
    .oSerial_out(oSerial_out),
    .oSerial_start(oSerial_start),
    .oSerial_end(oSerial_end)
);

// Test sequence
initial begin
    // Initialize inputs
    iRst = 1;
    iEn = 0;
    iLoad_key = 0;
    iLoad_msg = 0;
    iSerial_in = 0;
    reassembled_serial_out = 0;
    reassembled_counter = 0;

    // Apply reset
    #10;
    iRst = 0;
    #10;
    iRst = 1;

    // Start the key loading process
    #10;
    iEn = 1;
    iLoad_key = 1;

    // Define the key to be sent (example: 0xA5A5A5A5)
    key = 32'hA5A5A5A5;
    message = 512'hA3B1F9D2E7C6A5948B7D3E2F1A4C9E7D6B5A2F8C9D1E4B6A3958C7D2E1F3A6B9C4D8E7F1A2B3C5D7E6F9A4B2C8D3E9F1C7A2B5D8E4F9C3D1B7A4C6F2E8D5B3A9C7D4F1E6B8A2C3D5F9E7B4A1C9D2E8F6B5A3C7D1F2E4;

    // Use a for loop to send the key serially, MSB first
    for (i = 31; i >= 0; i = i - 1) begin
        iSerial_in = key[i];
        #CLOCK_PERIOD;
    end

    // Complete the loading process
    #20;
    iLoad_key = 0;

    // Start the message loading process
    #20;
    iLoad_msg = 1;
    for (i = 511; i >= 0; i = i - 1) begin
        iSerial_in = message[i];
        #CLOCK_PERIOD;
    end
    iLoad_msg = 0;

    // Wait for encryption to complete
    wait(uut.xor_encryptor.oEncrypt_done); // Wait until encryption is done

    // Start monitoring the serialized output
    reassembled_counter = 511;  // Set counter to start from MSB

    // Wait for serialization to complete
    wait(oSerial_end);

    // Check the output key
    if (uut.deserializer_key.oData == key)
        $display("Test Passed: Key = 0x%h", key);
    else
        $display("Test Failed: Key = 0x%h", uut.deserializer_key.oData);
    
    // Check the output message
    if (uut.deserializer_message.oData == message)
        $display("Test Passed: Message = 0x%h", message);
    else
        $display("Test Failed: Message = 0x%h", uut.deserializer_message.oData);
    
    // Check if encryption is done and ciphertext is generated
    if (oEncrypt_done)
        $display("Test Passed: Encryption Done. Ciphertext = 0x%h", oCiphertext);
    else
        $display("Test Failed: Encryption Not Done.");

    // Compare the reassembled serial output with the ciphertext
    if (reassembled_serial_out == oCiphertext)
        $display("Test Passed: Serialized Output Matches Ciphertext.");
    else
        $display("Test Failed: Serialized Output = 0x%h, Ciphertext = 0x%h", reassembled_serial_out, oCiphertext);

    // Finish the simulation
    #100;
    $stop;
end

// Monitor and reassemble the serialized output
always @(posedge iClk) begin
    if (oSerial_start && reassembled_counter >= 0) begin
        reassembled_serial_out[reassembled_counter] <= oSerial_out;
        if (reassembled_counter > 0) begin
            reassembled_counter <= reassembled_counter - 1;
        end else begin
            reassembled_counter <= 0;  // Hold at 0 to capture the last bit
        end
    end
end

always @(posedge iClk) begin
    $monitor("Time: %0t | bit_counter_key: %0d | bit_counter_message: %0d | ciphertext: 0x%h | oEncrypt_done: %b | oSerial_out: %b", 
             $time, uut.deserializer_key.oBit_counter, uut.deserializer_message.oBit_counter, oCiphertext, oEncrypt_done, oSerial_out);
end

endmodule
