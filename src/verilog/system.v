`timescale 1 ns / 1 ps
`include "7_segment_hex.v"
`include "memory.v"
`include "cache.v"

module system (
	input            clk,
	input            resetn,
	output           trap,
	output 	   [7:0] out_byte,
	output        out_byte_en,
	output     [7:0] an_out,
	output     [7:0] c_out
);
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 1;

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 4096;

	// interfaz procesador-cache
	wire core_mem_valid;
	wire core_mem_instr;
	wire core_mem_ready;
	wire [31:0] core_mem_addr;
	wire [31:0] core_mem_wdata;
	wire [3:0] core_mem_wstrb;
	wire [31:0] core_mem_rdata;
	wire core_mem_la_read;
	wire core_mem_la_write;
	wire [31:0] core_mem_la_addr;
	wire [31:0] core_mem_la_wdata;
	wire [3:0] core_mem_la_wstrb;

	// interfaz cache-memoria
	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	wire [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;

	picorv32 picorv32_core (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),
		.mem_valid   (core_mem_valid   ),
		.mem_instr   (core_mem_instr   ),
		.mem_ready   (core_mem_ready   ),
		.mem_addr    (core_mem_addr    ),
		.mem_wdata   (core_mem_wdata   ),
		.mem_wstrb   (core_mem_wstrb   ),
		.mem_rdata   (core_mem_rdata   ),
		.mem_la_read (core_mem_la_read ),
		.mem_la_write(core_mem_la_write),
		.mem_la_addr (core_mem_la_addr ),
		.mem_la_wdata(core_mem_la_wdata),
		.mem_la_wstrb(core_mem_la_wstrb)
	);

	cache_direct cache (
		.clk         (clk         ),
		.resetn      (resetn      ),
		// interfaz procesador-cache
		.core_mem_valid   (core_mem_valid   ),
		.core_mem_instr   (core_mem_instr   ),
		.core_mem_ready   (core_mem_ready   ),
		.core_mem_addr    (core_mem_addr    ),
		.core_mem_wdata   (core_mem_wdata   ),
		.core_mem_wstrb   (core_mem_wstrb   ),
		.core_mem_rdata   (core_mem_rdata   ),
		// interfaz cache-memoria
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   )
	);

	memory mem (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready_delay   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb),
		.out_byte_32 (out_byte_32 ),
		.out_byte_en (wout_byte_en )
	);

	wire [31:0] out_byte_32;
	wire wout_byte_en;
	wire [7:0] an_out, c_out;

	seven_segment_hex sevseg (
        .num_in    (out_byte_32),
        .clk       (clk),
        .resetn    (resetn),
        .an_out    (an_out),
        .c_out     (c_out)
	);

	assign out_byte_en = wout_byte_en;
	assign out_byte = out_byte_32[7:0];

endmodule
