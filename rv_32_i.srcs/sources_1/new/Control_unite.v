`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 17:22:15
// Design Name: 
// Module Name: Control_unite
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


module Control_Unit(
    input [6:0] opcode,     // Opcode alan�
    input [2:0] funct3,     // Funct3 alan�
    input [6:0] funct7,     // Funct7 alan� (R tipi komutlar i�in)
    output reg RegWrite,    // Register'a yazma izni
    output reg ALUSrc,      // ALU'ya immediate mi yoksa register m� girecek
    output reg MemWrite,    // Belle�e yazma izni
    output reg ResultSrc,   // Bellekten okunan veri mi yoksa ALU sonucu mu register'a yaz�lacak
    output reg Branch,      // Dallanma i�lemi
    output reg Jump,        // Jump i�lemi (JAL, JALR)
    output reg [3:0] ALUControl, // ALU kontrol sinyali
    output reg [2:0] ImmSrc // Immediate geni�letme i�in 3 bit sinyal
);

    always @(*) begin
        case (opcode)
            // R-Tipi komutlar (�rne�in ADD, SUB, AND, OR, XOR)
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b0;     // ALU'nun ikinci girdisi register'dan gelir
                MemWrite = 1'b0;   // Belle�e yazma yap�lmaz
                ResultSrc = 1'b0;  // ALU sonucu register'a yaz�l�r
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok

                // Funct3 ve Funct7'ye g�re ALU kontrol sinyali
                case ({funct7, funct3})
                    10'b0000000000: ALUControl = 4'b0010;  // ADD
                    10'b0100000000: ALUControl = 4'b0110;  // SUB
                    10'b0000000111: ALUControl = 4'b0000;  // AND
                    10'b0000000110: ALUControl = 4'b0001;  // OR
                    10'b0000000100: ALUControl = 4'b0011;  // XOR
                    10'b0000000001: ALUControl = 4'b0100;  // SLL (Logical shift left)
                    10'b0000000101: ALUControl = 4'b0101;  // SRL (Logical shift right)
                    10'b0100000101: ALUControl = 4'b0111;  // SRA (Arithmetic shift right)
                    default: ALUControl = 4'b0000;         // Varsay�lan: AND
                endcase

                ImmSrc = 3'bxxx;    // R-tipi komutlarda immediate yok
            end

            // I-Tipi komutlar (�rne�in ADDI, LOAD)
            7'b0010011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;     // ALU'nun ikinci girdisi immediate'den gelir
                MemWrite = 1'b0;   // Belle�e yazma yap�lmaz
                ResultSrc = 1'b0;  // ALU sonucu register'a yaz�l�r
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok

                // Funct3'e g�re ALU i�lemi
                case (funct3)
                    3'b000: ALUControl = 4'b0010;  // ADDI
                    3'b111: ALUControl = 4'b0000;  // ANDI
                    3'b110: ALUControl = 4'b0001;  // ORI
                    3'b100: ALUControl = 4'b0011;  // XORI
                    3'b001: ALUControl = 4'b0100;  // SLLI
                    3'b101: ALUControl = (funct7 == 7'b0000000) ? 4'b0101 : 4'b0111;  // SRLI veya SRAI
                    default: ALUControl = 4'b0000;  // Varsay�lan: AND
                endcase

                ImmSrc = 3'b000;    // I-Tipi immediate geni�letme
            end

            // Load komutlar� (�rne�in LW)
            7'b0000011: begin
                RegWrite = 1'b1;
                ALUSrc = 1'b1;     // Bellekten okuma i�in adres immediate'den hesaplan�r
                MemWrite = 1'b0;   // Belle�e yazma yap�lmaz
                ResultSrc = 1'b1;  // Bellekten okunan veri register'a yaz�l�r
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok
                ALUControl = 4'b0010;  // ALU toplama i�lemi yapar
                ImmSrc = 3'b000;    // I-Tipi immediate geni�letme
            end

            // Store komutlar� (�rne�in SW)
            7'b0100011: begin
                RegWrite = 1'b0;   // Belle�e yazma yap�ld��� i�in register'a yazma yap�lmaz
                ALUSrc = 1'b1;     // Belle�e yaz�lacak adres immediate'den hesaplan�r
                MemWrite = 1'b1;   // Belle�e yazma yap�l�r
                ResultSrc = 1'bx;  // Bellekten okuma yap�lmad��� i�in �nemsiz
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok
                ALUControl = 4'b0010;  // ALU toplama i�lemi yapar
                ImmSrc = 3'b001;    // S-Tipi immediate geni�letme
            end

            // Branch komutlar� (�rne�in BEQ)
            7'b1100011: begin
                RegWrite = 1'b0;   // Dallanma komutlar�nda register'a yazma yap�lmaz
                ALUSrc = 1'b0;     // ALU'nun ikinci girdisi register'dan gelir
                MemWrite = 1'b0;   // Belle�e yazma yap�lmaz
                ResultSrc = 1'bx;  // Bellekten okuma yap�lmad��� i�in �nemsiz
                Branch = 1'b1;     // Dallanma i�lemi yap�l�r
                Jump = 1'b0;       // Jump yok

                // Funct3'e g�re dallanma t�r� (�rne�in BEQ, BNE)
                case (funct3)
                    3'b000: ALUControl = 4'b0110;  // BEQ (e�itlik kontrol�)
                    3'b001: ALUControl = 4'b0110;  // BNE (e�it de�il kontrol�)
                    default: ALUControl = 4'b0110;  // Varsay�lan olarak BEQ
                endcase

                ImmSrc = 3'b010;    // B-Tipi immediate geni�letme
            end

            // LUI ve AUIPC komutlar� (U-Tipi)
            7'b0110111, 7'b0010111: begin
                RegWrite = 1'b1;   // Register'a yazma yap�l�r
                ALUSrc = 1'b1;     // Immediate de�er kullan�l�r
                MemWrite = 1'b0;   // Belle�e yazma yap�lmaz
                ResultSrc = 1'b0;  // ALU sonucu register'a yaz�l�r
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b0;       // Jump yok
                ALUControl = 4'b0010;  // ALU toplama i�lemi yapar (AUIPC)
                ImmSrc = 3'b011;    // U-Tipi immediate geni�letme
            end

            // JAL komutu (J-Tipi)
            7'b1101111: begin
                RegWrite = 1'b1;   // Geri d�n�� adresi register'a yaz�l�r
                ALUSrc = 1'b1;     // Immediate kullan�l�r
                MemWrite = 1'b0;   // Belle�e yazma yap�lmaz
                ResultSrc = 1'b0;  // PC + 4 register'a yaz�l�r
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b1;       // Jump var
                ALUControl = 4'b0010;  // ALU toplama i�lemi yapar
                ImmSrc = 3'b100;    // J-Tipi immediate geni�letme
            end

            // JALR komutu (Jump and Link Register)
            7'b1100111: begin
                RegWrite = 1'b1;   // Geri d�n�� adresi register'a yaz�l�r
                ALUSrc = 1'b1;     // Immediate kullan�l�r
                MemWrite = 1'b0;   // Belle�e yazma yap�lmaz
                ResultSrc = 1'b0;  // PC + 4 register'a yaz�l�r
                Branch = 1'b0;     // Dallanma yok
                Jump = 1'b1;       // Jump var
                ALUControl = 4'b0010;  // ALU toplama i�lemi yapar
                ImmSrc = 3'b000;    // I-Tipi immediate geni�letme
            end

            default: begin
                RegWrite = 1'b0;   // Varsay�lan durumda register'a yazma yap�lmaz
                ALUSrc = 1'b0;
                MemWrite = 1'b0;
                ResultSrc = 1'b0;
                Branch = 1'b0;
                Jump = 1'b0;
                ALUControl = 4'b0000;  // ALU durumu ge�ersiz
                ImmSrc = 3'b000;    // Default I-Tipi geni�letme
            end
        endcase
    end
endmodule



