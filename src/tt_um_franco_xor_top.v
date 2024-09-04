module xor_encryption_top(
    input iSerial_in,       // Serial DATA in
    input iClk,             // ESP32 Input Clock.
    input iRst,             // Active low reset.
    input iEn,              // Enable Pin
    input iLoad_key,        // Key load flag.
    input iLoad_msg,        // Message load flag.

    output oSerial_out,
    output oSerial_start,
    output oSerial_end
);

// Key and message wires
wire [31  : 0] oKey;
wire [511 : 0] oMessage;
wire [511 : 0] oAssembled_key;
wire [511 : 0] oCiphertext;

wire [$clog2(32)  : 0] bit_counter_key;
wire [$clog2(512) : 0] bit_counter_message;
wire [$clog2(512) : 0] key_assemble_counter;

wire can_encrypt;
wire encrypt_done;

// Instantiate the key deserializer module
deserializer #(.DATA_SIZE(32)) deserializer_key (
    .iClk(iClk),
    .iRst(iRst),
    .iEn(iEn),
    .iData_in(iSerial_in),
    .iLoading(iLoad_key),
    .oData(oKey),
    .oBit_counter(bit_counter_key)  // Correctly assign the key bit counter
);

// Instantiate the message deserializer module
deserializer #(.DATA_SIZE(512)) deserializer_message (
    .iClk(iClk),
    .iRst(iRst),
    .iEn(iEn),
    .iData_in(iSerial_in),
    .iLoading(iLoad_msg),
    .oData(oMessage),
    .oBit_counter(bit_counter_message)  // Correctly assign the message bit counter
);

// Instantiate the key assembler module
key_assembler key_assembler_inst (
    .iClk(iClk),
    .iRst(iRst),
    .iKey(oKey),
    .iBit_counter_key(bit_counter_key),
    .oAssembled_key(oAssembled_key),
    .oKey_assemble_counter(key_assemble_counter),
    .oCan_encrypt(can_encrypt)
);

// Instantiate the XOR encryption module
xor_encrypt #(.KEY_SIZE(32), .MSG_SIZE(512)) xor_encryptor (
    .iClk(iClk),
    .iRst(iRst),
    .iCan_encrypt(can_encrypt),  
    .iKey(oAssembled_key),       
    .iMessage(oMessage),         
    .iKey_assemble_counter(key_assemble_counter),
    .iMessage_counter(bit_counter_message),
    .oCiphertext(oCiphertext),   
    .oEncrypt_done(encrypt_done)
);

// Instantiate the serializer module
serialize #(.MSG_SIZE(512)) serialize_output (
    .iClk(iClk),
    .iRst(iRst),
    .iEncrypt_done(encrypt_done),
    .iCiphertext(oCiphertext),
    .oSerial_out(oSerial_out),
    .oSerial_start(oSerial_start),
    .oSerial_end(oSerial_end)
);

endmodule
