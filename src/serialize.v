module serialize #(parameter MSG_SIZE = 8)(
    input iClk,      // half_clock
    input iEn,
    input iRst,      // reset signal
    input iEncrypt_Done,
    input [MSG_SIZE - 1:0] iCiphertext,  // serial data in.
    output reg oData,
    output reg oDone_flag
    );
integer bit_counter;
    
always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin     
        oData <= 0;
        oDone_flag <= 0;
        bit_counter <= 0;
    end else if (iEncrypt_Done && iEn) begin
            oData <= iCiphertext[bit_counter];
            bit_counter <= bit_counter + 1;

        if (bit_counter == MSG_SIZE - 1) begin
            oDone_flag <= 1;
        end else begin
        oDone_flag <= 0; // Optional: Reset flag when not enabled
        end
    end
end
endmodule
