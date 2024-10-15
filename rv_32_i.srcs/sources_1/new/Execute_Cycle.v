`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 21:29:49
// Design Name: 
// Module Name: Execute_Cycle
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


module Execute_Cycle(
  input clk, rst,                      // Clock ve reset sinyalleri
  input [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, // Register'dan gelen veriler ve geni�letilmi� immediate
  input [4:0] RS1_E, RS2_E, RD_E,      // Register numaralar�
  input [3:0] ALUControlE,             // ALU kontrol sinyali
  input ALUSrcE, MemWriteE, MemReadE, ResultSrcE, BranchE, JumpE,  // Kontrol sinyalleri
  input [2:0] funct3_E,                // funct3 sinyali (dallanma ve ALU i�lemleri i�in)
  input RegWriteM, RegWriteW,           // Memory ve Write-back a�amalar�ndaki yazma izni
  input [31:0] ALUResultM, ResultW,     // ALU sonucu ve write-back sonucu
  input [4:0] RD_M, RD_W,              // Memory ve Write-back a�amalar�ndaki hedef register'lar
  output [31:0] ALUResultM_out, WriteDataM, PCTargetE, PCPlus4M,   // ��k�� verileri
  output ZeroE, LessE,                 // Zero ve Less bayraklar�
  output MemWriteM, MemReadM, ResultSrcM, BranchM, JumpM,          // Bellek, Branch, Jump sinyalleri
  output [4:0] RD_M_out                // Hedef register (write-back i�in)
);

  // Forwarding sinyalleri
  wire [1:0] ForwardAE, ForwardBE;
  
  // ALU giri� ve ��k��lar�
  wire [31:0] SrcA, SrcB, ALUResult; 
  wire Zero, Less;

  // Forwarding i�lemleri: SrcA ve SrcB'yi mux ile se�iyoruz
  mux_3_1 muxA (
    .a(RD1_E),         // Register'dan gelen veri
    .b(ALUResultM),     // Memory a�amas�ndan gelen veri
    .c(ResultW),        // Write-back a�amas�ndan gelen veri
    .s(ForwardAE),      // Forwarding se�im sinyali
    .d(SrcA)            // ALU'nun A giri�i
  );

  mux_3_1 muxB (
    .a(RD2_E),         // Register'dan gelen veri
    .b(ALUResultM),     // Memory a�amas�ndan gelen veri
    .c(ResultW),        // Write-back a�amas�ndan gelen veri
    .s(ForwardBE),      // Forwarding se�im sinyali
    .d(SrcB)            // ALU'nun B giri�i
  );

  // ALU i�lemleri
  ALU alu (
    .A(SrcA),
    .B(SrcB),
    .ALUControl(ALUControlE),
    .Result(ALUResult),
    .Zero(Zero),
    .Less(Less)
  );

  // Branch ve Jump karar� (Zero ve Less bayraklar�na g�re)
  Branch_Jump_Control branch_jump_control (
    .Branch(BranchE),
    .Jump(JumpE),
    .Zero(Zero),
    .Less(Less),
    .funct3(funct3_E),
    .PCSrc(PCTargetE)   // Nihai branch veya jump karar�
  );

  // Hazard unit'ten forwarding sinyalleri i�in giri�-��k�� ba�lant�s�
  Hazard_unit hazard_unit_inst (
    .rst(rst),
    .MemReadM(MemReadE),           // Memory a�amas�ndaki belle�e okuma sinyali
    .Ready(1'b1),                  // Ready sinyali (veri haz�r)
    .RegWriteM(RegWriteM),         // Memory a�amas�ndaki yazma izni
    .RegWriteW(RegWriteW),         // Write-back a�amas�ndaki yazma izni
    .Rd_M(RD_M),                   // Memory a�amas�ndaki hedef register
    .Rd_W(RD_W),                   // Write-back a�amas�ndaki hedef register
    .Rs1_E(RS1_E), .Rs2_E(RS2_E),  // Execute a�amas�ndaki kaynak register'lar
    .ForwardAE(ForwardAE),         // ALU i�in forwarding sinyali A
    .ForwardBE(ForwardBE)          // ALU i�in forwarding sinyali B
  );

  // Pipeline register'lar (Memory a�amas�na ge�i�)
  reg MemWriteE_r, MemReadE_r, ResultSrcE_r, BranchE_r, JumpE_r;
  reg [31:0] ALUResultE_r, WriteDataE_r, PCPlus4E_r;
  reg [4:0] RD_E_r;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset s�ras�nda t�m sinyalleri s�f�rla
      MemWriteE_r <= 1'b0;
      MemReadE_r <= 1'b0;
      ResultSrcE_r <= 1'b0;
      BranchE_r <= 1'b0;
      JumpE_r <= 1'b0;
      ALUResultE_r <= 32'h00000000;
      WriteDataE_r <= 32'h00000000;
      PCPlus4E_r <= 32'h00000000;
      RD_E_r <= 5'h00;
    end else begin
      // Normal �al��ma s�ras�nda sinyalleri ge�i�tir
      MemWriteE_r <= MemWriteE;
      MemReadE_r <= MemReadE;
      ResultSrcE_r <= ResultSrcE;
      BranchE_r <= BranchE;
      JumpE_r <= JumpE;
      ALUResultE_r <= ALUResult;
      WriteDataE_r <= RD2_E;       // Belle�e yaz�lacak veri (RD2'den gelen veri)
      PCPlus4E_r <= PCPlus4E;      // PC + 4 de�eri
      RD_E_r <= RD_E;              // Hedef register (write-back a�amas�nda kullan�lacak)
    end
  end

  // Zero ve Less bayraklar�
  assign ZeroE = Zero;
  assign LessE = Less;

  // ��k�� sinyalleri (Memory a�amas�na aktar�lacak)
  assign ALUResultM_out = ALUResultE_r;
  assign WriteDataM = WriteDataE_r;
  assign PCTargetE = PCE + Imm_Ext_E; // Branch veya Jump hedefi
  assign PCPlus4M = PCPlus4E_r;
  assign MemWriteM = MemWriteE_r;
  assign MemReadM = MemReadE_r;
  assign ResultSrcM = ResultSrcE_r;
  assign BranchM = BranchE_r;
  assign JumpM = JumpE_r;
  assign RD_M_out = RD_E_r;

endmodule
