`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 16:33:55
// Design Name: 
// Module Name: Extend
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


module Extend(In, ImmSrc, Imm_Ext);

 input [31:0] In;      // Komutun tamam� (instruction)
    input [2:0] ImmSrc;   // Immediate t�r�n� se�mek i�in (art�k 3 bit, ��nk� 5 t�r� destekliyor)
    output reg [31:0] Imm_Ext;  // Geni�letilmi� immediate ��k���

    always @(*) begin
        case (ImmSrc)
            3'b000: Imm_Ext = {{20{In[31]}}, In[31:20]}; // I tipi (i�aret geni�letme)
            3'b001: Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]}; // S tipi (i�aret geni�letme)
            3'b010: Imm_Ext = {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0}; // B tipi (i�aret geni�letme)
            3'b011: Imm_Ext = {In[31:12], 12'b0}; // U tipi (i�aretsiz geni�letme)
            3'b100: Imm_Ext = {{11{In[31]}}, In[31], In[19:12], In[20], In[30:21], 1'b0}; // J tipi (i�aret geni�letme)
            default: Imm_Ext = 32'h00000000;  // Default, bilinmeyen bir immediate t�r� varsa s�f�r d�ner
        endcase
    end
endmodule









