`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2024 22:29:46
// Design Name: 
// Module Name: UART
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


module UART (
    input clk,                   // Saat sinyali
    input rst,                   // Reset sinyali
    input [7:0] tx_data,         // Gönderilecek veri (8-bit)
    input tx_start,              // Gönderimi baþlatma sinyali
    output reg tx_ready,         // Gönderim hazýr sinyali
    output reg tx,               // Tx çýkýþý (veri çýkýþý)
    input rx,                    // Rx giriþi (veri giriþi)
    output reg [7:0] rx_data,    // Alýnan veri (8-bit)
    output reg rx_ready,         // Veri alýndýðýnda sinyal
    input [15:0] baud_div,       // Programlanabilir baud rate faktörü
    output reg [7:0] tx_buffer_data, // TX buffer'dan gönderilen veri
    output reg [7:0] rx_buffer_data  // RX buffer'dan alýnan veri
);

    // Dahili sayaçlar ve kayýtlar
    reg [15:0] baud_counter;       // Baud rate sayacý
    reg [3:0] tx_bit_counter;      // Gönderim bit sayacý
    reg [3:0] rx_bit_counter;      // Alým bit sayacý
    reg [7:0] tx_shift_reg;        // Gönderim kaydýrma kaydý
    reg [7:0] rx_shift_reg;        // Alým kaydýrma kaydý
    reg tx_busy;                   // Gönderim modülü meþgul
    reg rx_busy;                   // Alým modülü meþgul
    reg [7:0] tx_buffer [31:0];    // 32x8-bit TX buffer (dahili)
    reg [7:0] rx_buffer [31:0];    // 32x8-bit RX buffer (dahili)
    reg [4:0] tx_buffer_write_ptr; // TX tampon yazma iþaretçisi
    reg [4:0] tx_buffer_read_ptr;  // TX tampon okuma iþaretçisi
    reg [4:0] rx_buffer_write_ptr; // RX tampon yazma iþaretçisi
    reg [4:0] rx_buffer_read_ptr;  // RX tampon okuma iþaretçisi

    // Baud Rate Üreteci
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_counter <= 0;
        end else if (baud_counter == baud_div) begin
            baud_counter <= 0;
        end else begin
            baud_counter <= baud_counter + 1;
        end
    end

 // Transmitter (Gönderici)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_ready <= 1;
            tx_busy <= 0;
            tx <= 1;  // Varsayýlan olarak hat boþta (1)
            tx_bit_counter <= 0;
        end else if (tx_start && tx_ready) begin
            // Gönderim baþlatýldýðýnda
            tx_ready <= 0;
            tx_busy <= 1;
            tx_shift_reg <= tx_data;  // Veriyi kaydýrma kaydýna yükle
            tx_bit_counter <= 0;
            tx <= 0;  // Start bit
        end else if (baud_counter == baud_div && tx_busy) begin
            if (tx_bit_counter < 8) begin
                tx <= tx_shift_reg[0];  // En düþük biti gönder
                tx_shift_reg <= tx_shift_reg >> 1;
                tx_bit_counter <= tx_bit_counter + 1;
            end else if (tx_bit_counter == 8) begin
                tx <= 1;  // Stop bit gönderilir
                tx_bit_counter <= tx_bit_counter + 1;
            end else if (tx_bit_counter == 9) begin
                tx_busy <= 0;
                tx_ready <= 1;  // **8 bit + stop biti tamamlandýktan sonra tx_ready sinyali aktif edilir**
            end
        end
    end


    // Alým iþlemi (Rx)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_ready <= 0;
            rx_bit_counter <= 0;
            rx_busy <= 0;
        end else if (!rx_busy && !rx) begin
            // Alým baþlatýldýðýnda
            rx_busy <= 1;
            rx_bit_counter <= 0;
        end else if (baud_counter == baud_div && rx_busy) begin
            if (rx_bit_counter < 8) begin
                rx_shift_reg <= {rx, rx_shift_reg[7:1]};
                rx_bit_counter <= rx_bit_counter + 1;
            end else begin
                rx_data <= rx_shift_reg;  // Veriyi al ve kaydet
                rx_buffer[rx_buffer_write_ptr] <= rx_shift_reg;  // RX tamponuna yaz
                rx_buffer_write_ptr <= rx_buffer_write_ptr + 1;  // Yazma iþaretçisini artýr
                rx_buffer_data <= rx_shift_reg;  // RX buffer'dan çýkýþ verisi
                rx_ready <= 1;
                rx_busy <= 0;
            end
        end
    end

endmodule