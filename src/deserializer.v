

module deserializer #(parameter DATA_SIZE = 32)(
    input iClk,
    input iRst,
    input iEn,
    input iData_in,
    input iLoading,
    output reg [DATA_SIZE - 1 : 0] oData,
    output reg [($clog2(DATA_SIZE)-1): 0 ] oBit_counter
);

reg [($clog2(DATA_SIZE)-1): 0 ] bit_counter;

always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin
       // If reset is active (low), reset all the registers
       oData <= 0; 
       bit_counter <= {$clog2(DATA_SIZE){1'b0}};
       oBit_counter <= {$clog2(DATA_SIZE){1'b0}};
       
    end else if (iEn && iLoading) begin
        // Continue loading if enabled and in loading mode
        if (bit_counter < DATA_SIZE) begin
            oData <= {oData[DATA_SIZE-2:0], iData_in}; // Shift in the new bit
            bit_counter <= bit_counter + 1;
        end
        
        if (bit_counter == DATA_SIZE) begin
            oBit_counter <= bit_counter;
        end

        end else if (!iLoading) begin
        // Maintain the last value when not loading
        oBit_counter <= bit_counter;
    end
end

endmodule