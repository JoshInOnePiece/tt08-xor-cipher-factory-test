module tt_um_franco_xor_top(
    // input iClk,             // ESP32 Input Clock. clk pin
    // input iRst,             // Active low reset. rst_n
    // input iEn,              // Enable Pin        ena
    // input iSerial_in,       // Serial DATA in    ui_in[0]
    // input iLoad_key,        // Key load flag.    ui_in[1]
    // input iLoad_msg,        // Message load flag.ui_in[2]

    // output oSerial_out,  uo_out[0]
    // output oSerial_start,uo_out[1]
    // output oSerial_end   uo_out[2]

    input clk,              //ESP32 Input Clock
    input ena,
    input rst_n,
    input  [7:0] ui_in,
    output [7:0] uo_out,
    
    input [7:0] uio_in,
    output [7:0] uio_out,
    output [7:0] uio_oe

);

// Key and message wires
wire [31  : 0] oKey;
wire [511 : 0] oMessage;
wire [511 : 0] oAssembled_key;
wire [511 : 0] oCiphertext;

wire [$clog2(32)  : 0] bit_counter_key;
wire [$clog2(512) : 0] bit_counter_message;
wire [($clog2(512)-1) : 0] key_assemble_counter;

wire iRst;
wire can_encrypt;
wire encrypt_done;

//Unused pins to prevent linter warning
wire _unused_pins = &{ui_in[7:3],uio_in[7:0]};
assign uio_out = 0;
assign uio_oe = 0;
assign uo_out[7:3] = 0;

assign iRst = ~rst_n;

// Instantiate the key deserializer module
deserializer #(.DATA_SIZE(32)) deserializer_key (
    .iClk(clk),
    .iRst(iRst),    //iRst
    .iEn(ena),      //iEn
    .iData_in(ui_in[0]),  //iSerial_in
    .iLoading(ui_in[1]),   //iLoad_key
    .oData(oKey),
    .oBit_counter(bit_counter_key)  // Correctly assign the key bit counter
);

// Instantiate the message deserializer module
deserializer #(.DATA_SIZE(512)) deserializer_message (
    .iClk(clk),
    .iRst(iRst),    //iRst
    .iEn(ena),      //iEn
    .iData_in(ui_in[0]), //serial_in
    .iLoading(ui_in[2]),   //iLoad_msg
    .oData(oMessage),
    .oBit_counter(bit_counter_message)  // Correctly assign the message bit counter
);

// Instantiate the key assembler module
key_assembler key_assembler_inst (
    .iClk(clk),
    .iRst(iRst),    //iRst
    .iKey(oKey),
    .iBit_counter_key(bit_counter_key),
    .oAssembled_key(oAssembled_key),
    .oKey_assemble_counter(key_assemble_counter),
    .oCan_encrypt(can_encrypt)
);

// Instantiate the XOR encryption module
xor_encrypt #(.MSG_SIZE(512)) xor_encryptor (
    .iClk(clk),
    .iRst(iRst),    //iRst
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
    .iClk(clk),
    .iRst(iRst),    //iRst
    .iEncrypt_done(encrypt_done),
    .iCiphertext(oCiphertext),
    .oSerial_out(uo_out[0]),
    .oSerial_start(uo_out[1]),
    .oSerial_end(uo_out[2])
);

endmodule
