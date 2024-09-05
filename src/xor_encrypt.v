module xor_encrypt #(parameter MSG_SIZE = 512)(
    input iClk,
    input iRst,
    input iCan_encrypt,
    input [MSG_SIZE - 1:0] iKey,
    input [MSG_SIZE - 1:0] iMessage,
    input [$clog2(512):0 ] iMessage_counter,
    input [$clog2(512):0 ] iKey_assemble_counter,
    output reg [MSG_SIZE - 1:0] oCiphertext,
    output reg oEncrypt_done
);

always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin
        oCiphertext   <= 0;
        oEncrypt_done <= 0;
    end else if (iCan_encrypt && iMessage_counter == MSG_SIZE && iKey_assemble_counter == MSG_SIZE && !oEncrypt_done) begin
        oCiphertext <= iMessage ^ iKey;
        oEncrypt_done <= 1;  // Latches once encryption is done
    end
end
endmodule
