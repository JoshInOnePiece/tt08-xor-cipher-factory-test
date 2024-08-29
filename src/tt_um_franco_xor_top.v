module tt_um_franco_xor_top(
    input iEn,
    input iData_in,
    input iClk,
    input iRst,
    input iLoad_key,
    input iLoad_msg,
    output oClk_slow,
    output reg oData_out,
    output oDone_flag
);

    // Internal registers
    wire [3:0] key;
    wire [7:0] message;
    wire [7:0] assembled_key;
    wire [7:0] ciphertext;
    
    wire key_bit;
    wire message_bit;
    wire oAssembled;
    wire oEncrypt_flag;
    wire serial_out;

    // Instantiate clock divider
    clock_divider half_clock(
        .iClk(iClk),
        .iRst(iRst),
        .oClk_slow(oClk_slow)
    );

    // Instantiate deserializer for the key
    deserializer #(.DATA_SIZE(4)) deserialize_key (
        .iEn(iEn),
        .iData_in(iData_in),
        .iClk(oClk_slow),
        .iRst(iRst),
        .iLoading(iLoad_key),
        .oData(key),
        .oDone_flag(key_bit)
    );

    // Instantiate deserializer for the message
    deserializer #(.DATA_SIZE(8)) deserialize_message (
        .iEn(iEn),
        .iData_in(iData_in),
        .iClk(oClk_slow),
        .iRst(iRst),
        .iLoading(iLoad_msg),
        .oData(message),
        .oDone_flag(message_bit)
    );

    // Instantiate key assembler
    assemble_key #(.KEY_SIZE(4), .MSG_SIZE(8)) key_assembler (
        .iEn(iEn),
        .iAssemble(key_bit),
        .iClk(oClk_slow),
        .iRst(iRst),
        .iKey(key),
        .oKey_Assembled(assembled_key),
        .oAssembled(oAssembled)
    );
    
    xor_encrypt #(.MSG_SIZE(8)) xor_module (
        .iEn(iEn),
        .iClk(oClk_slow),
        .iRst(iRst),
        .iEncrypt(oAssembled),
        .iKey_Assembled(assembled_key),
        .iMessage(message),
        .oCiphertext(ciphertext),
        .oEncrypt_flag(oEncrypt_flag)
    );
    
    serialize #(.MSG_SIZE(8)) serializer_message(
        .iClk(oClk_slow),
        .iEn(iEn),
        .iRst(iRst),
        .iEncrypt_Done(oEncrypt_flag),
        .iCiphertext(ciphertext),
        .oData(serial_out),
        .oDone_flag(oDone_flag)
    );

always @(posedge oClk_slow or negedge iRst) begin
    if (!iRst) begin 
        oData_out <= 0;
    end else if (oDone_flag && iEn) begin
        oData_out <= serial_out;
    end
end
endmodule