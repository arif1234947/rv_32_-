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
    input [7:0] tx_data,         // G�nderilecek veri (8-bit)
    input tx_start,              // G�nderimi ba�latma sinyali
    output reg tx_ready,         // G�nderim haz�r sinyali
    output reg tx,               // Tx ��k��� (veri ��k���)
    input rx,                    // Rx giri�i (veri giri�i)
    output reg [7:0] rx_data,    // Al�nan veri (8-bit)
    output reg rx_ready,         // Veri al�nd���nda sinyal
    input [15:0] baud_div,       // Programlanabilir baud rate fakt�r�
    output reg [7:0] tx_buffer_data, // TX buffer'dan g�nderilen veri
    output reg [7:0] rx_buffer_data  // RX buffer'dan al�nan veri
);

    // Dahili saya�lar ve kay�tlar
    reg [15:0] baud_counter;       // Baud rate sayac�
    reg [3:0] tx_bit_counter;      // G�nderim bit sayac�
    reg [3:0] rx_bit_counter;      // Al�m bit sayac�
    reg [7:0] tx_shift_reg;        // G�nderim kayd�rma kayd�
    reg [7:0] rx_shift_reg;        // Al�m kayd�rma kayd�
    reg tx_busy;                   // G�nderim mod�l� me�gul
    reg rx_busy;                   // Al�m mod�l� me�gul
    reg [7:0] tx_buffer [31:0];    // 32x8-bit TX buffer (dahili)
    reg [7:0] rx_buffer [31:0];    // 32x8-bit RX buffer (dahili)
    reg [4:0] tx_buffer_write_ptr; // TX tampon yazma i�aret�isi
    reg [4:0] tx_buffer_read_ptr;  // TX tampon okuma i�aret�isi
    reg [4:0] rx_buffer_write_ptr; // RX tampon yazma i�aret�isi
    reg [4:0] rx_buffer_read_ptr;  // RX tampon okuma i�aret�isi

    // Baud Rate �reteci
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_counter <= 0;
        end else if (baud_counter == baud_div) begin
            baud_counter <= 0;
        end else begin
            baud_counter <= baud_counter + 1;
        end
    end

 // Transmitter (G�nderici)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_ready <= 1;
            tx_busy <= 0;
            tx <= 1;  // Varsay�lan olarak hat bo�ta (1)
            tx_bit_counter <= 0;
        end else if (tx_start && tx_ready) begin
            // G�nderim ba�lat�ld���nda
            tx_ready <= 0;
            tx_busy <= 1;
            tx_shift_reg <= tx_data;  // Veriyi kayd�rma kayd�na y�kle
            tx_bit_counter <= 0;
            tx <= 0;  // Start bit
        end else if (baud_counter == baud_div && tx_busy) begin
            if (tx_bit_counter < 8) begin
                tx <= tx_shift_reg[0];  // En d���k biti g�nder
                tx_shift_reg <= tx_shift_reg >> 1;
                tx_bit_counter <= tx_bit_counter + 1;
            end else if (tx_bit_counter == 8) begin
                tx <= 1;  // Stop bit g�nderilir
                tx_bit_counter <= tx_bit_counter + 1;
            end else if (tx_bit_counter == 9) begin
                tx_busy <= 0;
                tx_ready <= 1;  // **8 bit + stop biti tamamland�ktan sonra tx_ready sinyali aktif edilir**
            end
        end
    end


    // Al�m i�lemi (Rx)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_ready <= 0;
            rx_bit_counter <= 0;
            rx_busy <= 0;
        end else if (!rx_busy && !rx) begin
            // Al�m ba�lat�ld���nda
            rx_busy <= 1;
            rx_bit_counter <= 0;
        end else if (baud_counter == baud_div && rx_busy) begin
            if (rx_bit_counter < 8) begin
                rx_shift_reg <= {rx, rx_shift_reg[7:1]};
                rx_bit_counter <= rx_bit_counter + 1;
            end else begin
                rx_data <= rx_shift_reg;  // Veriyi al ve kaydet
                rx_buffer[rx_buffer_write_ptr] <= rx_shift_reg;  // RX tamponuna yaz
                rx_buffer_write_ptr <= rx_buffer_write_ptr + 1;  // Yazma i�aret�isini art�r
                rx_buffer_data <= rx_shift_reg;  // RX buffer'dan ��k�� verisi
                rx_ready <= 1;
                rx_busy <= 0;
            end
        end
    end

endmodule