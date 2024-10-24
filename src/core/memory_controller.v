```verilog
module memory_controller (
    input  wire clk,                    // System clock
    input  wire [31:0] address,         // Address bus from CPU
    input  wire [31:0] data_in,         // Data bus input from CPU (write data)
    output reg  [31:0] data_out,        // Data bus output to CPU (read data)
    input  wire mem_read,               // Memory read signal
    input  wire mem_write,              // Memory write signal
    input  wire [7:0] bios_data [0:4095] // BIOS data (16 KB, loaded from an external source)
);

    // Memory regions declaration
    reg [31:0] wram_internal [0:8191];  // Internal WRAM (32 KB)
    reg [31:0] wram_external [0:65535]; // External WRAM (256 KB)
    reg [31:0] vram [0:24575];          // VRAM (96 KB)
    reg [31:0] rom [0:8388607];         // ROM (32 MB max)

    always @(posedge clk) begin
        if (mem_read) begin
            // Decode memory address to determine the source
            case (address[31:24])
                8'h00: data_out <= {24'h000000, bios_data[address[13:2]]};  // BIOS (0x00000000 - 0x00003FFF)
                8'h03: data_out <= wram_internal[address[15:2]];            // Internal WRAM
                8'h02: data_out <= wram_external[address[17:2]];            // External WRAM
                8'h06: data_out <= vram[address[16:2]];                     // VRAM
                8'h08, 8'h09: data_out <= rom[address[23:2]];               // ROM
                default: data_out <= 32'h00000000;                          // Undefined region returns zero
            endcase
        end

        if (mem_write) begin
            // Decode memory address for writing
            case (address[31:24])
                8'h03: wram_internal[address[15:2]] <= data_in;             // Internal WRAM (write)
                8'h02: wram_external[address[17:2]] <= data_in;             // External WRAM (write)
                8'h06: vram[address[16:2]] <= data_in;                      // VRAM (write)
                // BIOS and ROM are read-only, no writes allowed
            endcase
        end
    end

endmodule
```
