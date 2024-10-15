`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 21:59:02
// Design Name: 
// Module Name: Memory_Cycle
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


module Memory_Cycle(
input clk, rst,                     // Clock ve reset sinyalleri
    input [31:0] ALUResultM, WriteDataM, // ALU sonucundan gelen adres ve belle�e yaz�lacak veri
    input [4:0] RD_M,                    // Hedef register (write-back i�in)
    input MemWriteM, MemReadM,            // Belle�e yazma ve okuma sinyalleri
    input ResultSrcM,                     // ALU sonucu veya bellekten okunan veriyi se�en sinyal
    output [31:0] ReadDataM, ALUResultW,  // Bellekten okunan veri ve ALU sonucu
    output RegWriteM,                     // Register'a yazma izni
    output [4:0] RDW                     // Hedef register (write-back i�in)

    );
    
    
    wire [31:0] Data_Memory_Out;          // Bellekten okunan veri
    
        // Data Memory mod�l�n� �a��rma
        Data_Memory data_memory (
            .clk(clk),
            .rst(rst),
            .address(ALUResultM),             // ALU sonucundan gelen bellek adresi
            .write_data(WriteDataM),          // Belle�e yaz�lacak veri
            .MemWrite(MemWriteM),             // Belle�e yazma izni
            .MemRead(MemReadM),               // Bellekten okuma izni
            .data_out(Data_Memory_Out)        // Bellekten okunan veri (output: data_out)
        );
    
        // Bellekten okunan veri veya ALU sonucunu se� (write-back i�in)
        assign ReadDataM = Data_Memory_Out;
        assign ALUResultW = ALUResultM;
    
        // Bellek a�amas�ndaki sinyalleri bir sonraki a�amaya aktar (write-back)
        assign RegWriteM = ResultSrcM;       // Register'a yazma izni
        assign RDW = RD_M;                   // Hedef register (write-back a�amas�na)
endmodule
