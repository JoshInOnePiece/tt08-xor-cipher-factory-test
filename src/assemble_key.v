module assemble_key #(parameter KEY_SIZE = 4, parameter MSG_SIZE = 8)(
    input iEn,
    input iAssemble,
    input iClk,
    input iRst,
    input [KEY_SIZE - 1:0] iKey,
    output reg [MSG_SIZE - 1:0] oKey_Assembled,
    output reg oAssembled
);

reg [($clog2(MSG_SIZE+1))-1:0] bit_counter;

always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin
        oKey_Assembled <= 0;
        bit_counter <= 0;
        oAssembled <= 0;
    end else if (iEn && iAssemble) begin
        if (bit_counter < MSG_SIZE) begin
            oKey_Assembled <= {oKey_Assembled[MSG_SIZE-KEY_SIZE-1:0], iKey}; // Shift in the key
            bit_counter <= bit_counter + KEY_SIZE;
        end else if (bit_counter >= MSG_SIZE) begin
            oAssembled <= 1;
        end
    end else if (oAssembled && bit_counter >= MSG_SIZE) begin
            oAssembled <= 0;
            oKey_Assembled <= 0;
            bit_counter <= 0;
        end
    end
endmodule