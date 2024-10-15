`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 22:06:12
// Design Name: 
// Module Name: WriteBack_Cycle
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


module WriteBack_Cycle(
 input clk,                      // Saat sinyali
   input [31:0] ReadDataW,          // Bellekten okunan veri
   input [31:0] ALUResultW,         // ALU sonucu
   input [31:0] PCPlus4W,           // PC + 4 de�eri (�rne�in, JAL i�in)
   input [1:0] ResultSrcW,          // Yaz�lacak veriyi se�en sinyal (mux kontrol)
   input RegWriteW,                 // Register'a yazma izni
   input [4:0] RdW,                 // Hedef register adresi
   output [31:0] ResultW            // Register'a yaz�lacak nihai veri

    );
    
    // Mux ile yaz�lacak veriyi se�me
        wire [31:0] selected_data;
    
        
        mux_3_1 mux_3_1_instance (
            .a(ALUResultW),     // ALU sonucu
            .b(ReadDataW),      // Bellekten okunan veri
            .c(PCPlus4W),       // PC + 4 de�eri (JAL komutu i�in)
            .s(ResultSrcW),     // Se�im sinyali
            .d(selected_data)   // ��k��: yaz�lacak veri
        );
    
        // Register dosyas�na yaz�lacak olan nihai veri
        assign ResultW = selected_data;
    
        
   
endmodule
