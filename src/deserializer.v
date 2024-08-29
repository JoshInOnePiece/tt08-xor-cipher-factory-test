module deserializer #(parameter DATA_SIZE = 4)(
    input iEn,
    input iClk,      // half_clock
    input iRst,      // reset signal
    input iData_in,  // serial data in.
    input iLoading,  // Loading flag
    output reg [DATA_SIZE - 1:0] oData,
    output reg oDone_flag
);
    
integer bit_counter;

always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin
        oData <= 0;
        bit_counter <= 0; // Added missing initialization
        oDone_flag <= 0;  // Added initialization for the flag
    end else if (iEn) begin
        if (iLoading) begin // Check for individual loading flag
            oData <= {oData[DATA_SIZE-2:0], iData_in}; // Concatenate data in to the output reg
            bit_counter <= bit_counter + 1;
            
            if (bit_counter == DATA_SIZE) begin
                oDone_flag <= 1; // Set done flag when loading is complete
            end
        end
    end
end
endmodule
