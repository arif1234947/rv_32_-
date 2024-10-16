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
    input [31:0] ALUResultM, WriteDataM, // ALU sonucundan gelen adres ve belleðe yazýlacak veri
    input [4:0] RD_M,                    // Hedef register (write-back için)
    input MemWriteM, MemReadM,            // Belleðe yazma ve okuma sinyalleri
    input ResultSrcM,                     // ALU sonucu veya bellekten okunan veriyi seçen sinyal
    output [31:0] ReadDataM, ALUResultW,  // Bellekten okunan veri ve ALU sonucu
    output RegWriteM,                     // Register'a yazma izni
    output [4:0] RDW,                     // Hedef register (write-back için)

    // UART sinyalleri
    input [7:0] tx_data,                  // UART'a gönderilecek veri
    input tx_start,                       // UART gönderim baþlatma sinyali
    output [7:0] rx_data,                 // UART'tan alýnan veri
    output tx_ready,                      // UART gönderim hazýr sinyali
    input rx                              // UART Rx giriþi
);

    wire [31:0] Data_Memory_Out;          // Bellekten okunan veri
    wire [7:0] uart_rx_data;              // UART'tan gelen veri
    wire [7:0] uart_tx_data;              // UART'a gönderilen veri
    wire uart_tx_ready;                   // UART'ýn hazýr sinyali
    reg uart_select;                      // UART mý yoksa bellek mi kontrol ediliyor

    // UART modülü
    UART uart (
        .clk(clk),
        .rst(rst),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_ready(tx_ready),
        .tx(uart_tx_data),
        .rx(rx),
        .rx_data(uart_rx_data),
        .rx_ready()
    );

    // Bellek adresine göre UART mý yoksa bellek mi kontrol edilecek
    always @(*) begin
        if (ALUResultM == 32'hFFFF0000) begin // UART Tx adresi
            uart_select = 1'b1;
        end else begin
            uart_select = 1'b0;
        end
    end

    // Data Memory modülünü çaðýrma
    Data_Memory data_memory (
        .clk(clk),
        .rst(rst),
        .address(ALUResultM),
        .write_data(WriteDataM),
        .MemWrite(MemWriteM),
        .MemRead(MemReadM),
        .data_out(Data_Memory_Out)
    );

    // Bellekten okunan veri veya ALU sonucunu seç (write-back için)
    assign ReadDataM = uart_select ? uart_rx_data : Data_Memory_Out;
    assign ALUResultW = ALUResultM;

    // Bellek aþamasýndaki sinyalleri bir sonraki aþamaya aktar (write-back)
    assign RegWriteM = ResultSrcM;       // Register'a yazma izni
    assign RDW = RD_M;                   // Hedef register (write-back aþamasýna)

endmodule

