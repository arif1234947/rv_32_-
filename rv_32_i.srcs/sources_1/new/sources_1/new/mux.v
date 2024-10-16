`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 13:46:16
// Design Name: 
// Module Name: mux
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux(a,b,s,c);

input [31:0] a,b;
input s;
output [31:0] c;

assign c = (~s) ? a : b ;

endmodule


module mux_3_1 (a,b,c,s,d);

input [31:0] a,b,c;
input [1:0] s;
output [31:0] d;

assign d = (s == 2'b00) ? a : (s == 2'b01) ? b : (s ==2'b10) ? c : 32'h00000000;

endmodule




