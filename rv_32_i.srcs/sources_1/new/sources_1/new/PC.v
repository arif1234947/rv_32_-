`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 14:40:12
// Design Name: 
// Module Name: PC
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


module PC (
    input clk,
    input rst,
    input StallF,           // Fetch a�amas�nda durdurma sinyali
    input [31:0] PC_Next,   // Bir sonraki program sayac� de�eri
    output reg [31:0] PC    // Mevcut program sayac� de�eri
);

always @(posedge clk or posedge rst)  
begin
    if (rst == 1'b1)  
        PC <= 32'b0;        // Reset s�ras�nda program sayac� s�f�rlan�r
    else if (!StallF)       // StallF aktif de�ilse, PC g�ncellenir
        PC <= PC_Next;      // PC, bir sonraki de�ere g�ncellenir
    // StallF aktifse, PC ayn� kal�r (yani durur)
end

endmodule