module xor_encrypt #(parameter MSG_SIZE = 8)(
    input iEn,
    input iClk,
    input iRst,
    input iEncrypt,
    input [MSG_SIZE - 1:0]iKey_Assembled,
    input [MSG_SIZE - 1:0]iMessage,
    output reg [MSG_SIZE - 1:0] oCiphertext,
    output reg oEncrypt_flag
    );
    
always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin
        oCiphertext <= 0;
        oEncrypt_flag <= 0;
    end else if (iEncrypt && iEn) begin
        oCiphertext <= iMessage ^ iKey_Assembled;
        oEncrypt_flag <=1;
    end else begin
            oCiphertext <= oCiphertext;
    end
end    
endmodule
