module slide_intf_tb();

reg clk, rst_n, MISO;

wire SCLK, a2d_SS_n;
wire [2:0] nxtcnt;
wire [11:0] POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME;

slide_intf iDUT(.clk(clk), .cnv_cmplt(cnv_cmplt), .rst_n(rst_n), .chnnl(chnnl), .strt_cnv(strt_cnv), .POT_LP(POT_LP), .POT_B1(POT_B1), .POT_B2(POT_B2), .POT_B3(POT_B3), .POT_HP(POT_HP), .VOLUME(VOLUME));

initial begin
clk = 1'b0;
rst_n = 1'b0;
MISO = 1'b0;
#20
rst_n = 1'b1;
MISO = 1'b1;
#140
rst_n = 1'b0;
#40
rst_n = 1'b1;
end

always begin
 #10 clk = ~clk;
end
endmodule
