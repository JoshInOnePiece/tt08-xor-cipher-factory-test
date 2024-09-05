module key_assembler (
    input iClk,
    input iRst,
    input [31 : 0] iKey,
    input [$clog2(32) :0] iBit_counter_key,
    output reg [511 : 0] oAssembled_key,
    output reg [8   : 0] oKey_assemble_counter,
    output reg oCan_encrypt
);

    always @(posedge iClk or negedge iRst) begin    
        if (!iRst) begin
            oKey_assemble_counter <= 0;
            oCan_encrypt <= 0;
            oAssembled_key <= 0;
        end else begin
            if (iBit_counter_key == 32) begin
                // Assemble the key in 512-bit register by assigning each 32-bit segment
                if (oKey_assemble_counter < (511+1)) begin
                    oAssembled_key[oKey_assemble_counter +: 32] <= iKey;  // Assign 32 bits at a time
                    oKey_assemble_counter <= oKey_assemble_counter + 32;
                end
                
                if (oKey_assemble_counter >= (511+1)) begin
                    oCan_encrypt <= 1;
                end
            end
        end
    end
endmodule
