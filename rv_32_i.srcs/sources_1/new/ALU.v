`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 20:45:22
// Design Name: 
// Module Name: ALU
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


module ALU(
 input [31:0] A, B,           // ALU'nun iki giri�i
   input [3:0] ALUControl,      // ALU'nun yapaca�� i�lemi belirleyen kontrol sinyali
   output reg [31:0] Result,    // ALU'nun i�lem sonucu
   output Zero,                 // Zero bayra��: ALU sonucu s�f�r m�?
   output Less                  // Less bayra��: A < B mi?

    );
    
    
    
      // Zero bayra��: ALU'nun sonucu s�f�rsa aktif olur
      assign Zero = (Result == 32'b0);
      
      // Less bayra��: A < B kontrol� (A i�aretli ve i�aretsiz olabilir)
      assign Less = ($signed(A) < $signed(B));
  
      always @(*) begin
          case (ALUControl)
              4'b0010: Result = A + B;        // Toplama (ADD)
              4'b0110: Result = A - B;        // ��karma (SUB)
              4'b0000: Result = A & B;        // Mant�ksal AND
              4'b0001: Result = A | B;        // Mant�ksal OR
              4'b0011: Result = A ^ B;        // Mant�ksal XOR
              4'b0100: Result = A << B[4:0];  // Mant�ksal sola kayd�rma (SLL)
              4'b0101: Result = A >> B[4:0];  // Mant�ksal sa�a kayd�rma (SRL)
              4'b0111: Result = $signed(A) >>> B[4:0];  // Aritmetik sa�a kayd�rma (SRA)
              default: Result = 32'b0;        // Varsay�lan durum: ALU sonucu s�f�r
          endcase
      end
endmodule
