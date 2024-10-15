`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 21:49:12
// Design Name: 
// Module Name: Data_Memory
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


module Data_Memory(
input clk,    
    input rst,               // Saat sinyali
    input [31:0] address,       // Belle�e eri�im adresi
    input [31:0] write_data,    // Belle�e yaz�lacak veri
    input MemWrite,             // Belle�e yazma izni sinyali
    input MemRead,              // Bellekten okuma izni sinyali
    output reg [31:0] data_out, // Bellekten okunan veri
    output reg Ready            // Ready sinyali
    );
    
     reg [31:0] memory [0:511];  // 512 x 32-bit bellek alan� (2 KB)
       reg [1:0] cycle_counter;    // Verinin haz�r olup olmad���n� takip eden saya�
   
       // Belle�e veri yazma i�lemi
       always @(posedge clk) begin
           if (MemWrite) begin
               memory[address[10:2]] <= write_data;   // Belle�e veri yazma i�lemi (aligned)
           end
       end
   
       // Bellekten veri okuma i�lemi
       always @(posedge clk or posedge rst) begin
           if (rst) begin
               data_out <= 32'b0;
               Ready <= 1'b0;
               cycle_counter <= 2'b00;  // Reset durumunda saya� ve ready sinyali s�f�rlan�r
           end else if (MemRead) begin
               if (cycle_counter < 2'b10) begin
                   cycle_counter <= cycle_counter + 1;  // Bellekten veri okuma s�resi
                   Ready <= 1'b0;  // Veri haz�r de�il
               end else begin
                   data_out <= memory[address[10:2]];  // Bellekten veri okuma i�lemi (aligned)
                   Ready <= 1'b1;  // Veri haz�r
               end
           end else begin
               data_out <= 32'b0;
               Ready <= 1'b0;
               cycle_counter <= 2'b00;  // MemRead aktif de�ilse, saya� s�f�rlan�r
           end
       end

endmodule
