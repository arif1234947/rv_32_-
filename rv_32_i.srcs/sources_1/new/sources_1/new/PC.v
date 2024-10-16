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
    input StallF,           // Fetch aþamasýnda durdurma sinyali
    input [31:0] PC_Next,   // Bir sonraki program sayacý deðeri
    output reg [31:0] PC    // Mevcut program sayacý deðeri
);

always @(posedge clk or posedge rst)  
begin
    if (rst == 1'b1)  
        PC <= 32'b0;        // Reset sýrasýnda program sayacý sýfýrlanýr
    else if (!StallF)       // StallF aktif deðilse, PC güncellenir
        PC <= PC_Next;      // PC, bir sonraki deðere güncellenir
    // StallF aktifse, PC ayný kalýr (yani durur)
end

endmodule