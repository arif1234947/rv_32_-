`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 14:49:27
// Design Name: 
// Module Name: Fetch_cycle
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


module Fetch_cycle (
    input clk, rst, PCSrcE, StallF,    // StallF sinyali eklendi
    input [31:0] PCTargetE,
    output [31:0] InstrD, PCD, PCplus4D
);

    wire [31:0] PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;

    reg [31:0] InstrF_reg;
    reg [31:0] PCF_reg, PCPlus4F_reg;

    // PC seçim mux'u: Dallanma olup olmadýðýna göre PC güncellenir
    mux PC_mux(
        .a(PCPlus4F),         // Normalde PC + 4
        .b(PCTargetE),        // Dallanma hedefi
        .s(PCSrcE),           // Dallanma sinyali
        .c(PC_F)              // Güncellenmiþ PC
    );

    PC PC_PC(
        .clk(clk),
        .rst(rst),
        .StallF(StallF),      // StallF sinyali eklendi
        .PC_Next(PC_F),
        .PC(PCF)
    );

    Instruction_Memory IMEM(
        .rst(rst),
        .address(PCF),
        .instruction_out(InstrF)
    );

    PC_Adder PC_Adder(
        .a(PCF),
        .b(32'h00000004),
        .c(PCPlus4F)
    );

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            InstrF_reg <= 32'h00000000;
            PCF_reg <= 32'h00000000;
            PCPlus4F_reg <= 32'h00000000;
        end else if (!StallF) begin  // StallF aktif deðilse, register'lar güncellenir
            InstrF_reg <= InstrF;
            PCF_reg <= PCF;
            PCPlus4F_reg <= PCPlus4F;
        end
        // StallF aktifse, mevcut deðerler korunur (register'lar güncellenmez)
    end

    assign InstrD = (rst == 1'b1) ? 32'h00000000 : InstrF_reg;
    assign PCD = (rst == 1'b1) ? 32'h00000000 : PCF_reg;
    assign PCplus4D = (rst == 1'b1) ? 32'h00000000 : PCPlus4F_reg;

endmodule
