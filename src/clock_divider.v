module clock_divider(iClk,iRst,oClk_slow);

input iClk;
input iRst;
output reg oClk_slow;

always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin
        oClk_slow <= 0;
    end else begin
        oClk_slow = ~ oClk_slow;
    end
end
endmodule
