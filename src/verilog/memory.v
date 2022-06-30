module memory (
    input               resetn,
    input               clk,
    input               mem_valid,
    input               mem_instr,
    output reg          mem_ready_delay,
    input       [31:0]  mem_addr,
    input       [31:0]  mem_wdata,
    input        [3:0]  mem_wstrb,
    output reg  [31:0]  mem_rdata,
    input               mem_la_read,
    input               mem_la_write,
    input       [31:0]  mem_la_addr,
    input       [31:0]  mem_la_wdata,
    input        [3:0]  mem_la_wstrb,
    output reg  [31:0]  out_byte_32,
    output reg          out_byte_en
    );

	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 0;

	// 4096 32bit words = 16kB memory
	//parameter MEM_SIZE = 4096;
    // incrementando a 64 kB
    parameter MEM_SIZE = 16384;

	reg [31:0] memory [0:MEM_SIZE-1];

    `ifdef SYNTHESIS
        initial $readmemh("../firmware/firmware.hex", memory);
    `else
        initial $readmemh("firmware.hex", memory);
    `endif

	reg [31:0] m_read_data;
	reg m_read_en;
    reg mem_ready;
    //mem_ready_delay;
    reg [3:0] delay_cnt;
    reg [3:0] delay;

    always @(posedge clk) begin
        if (~resetn) begin
            delay_cnt <= 0;
            delay <= 4'b1100;
			mem_ready_delay <= 0;
        end 
		else if (mem_valid) begin
            if (mem_wstrb) delay <= 4'b1010;
            else delay <= 4'b1100;
            if (delay_cnt == delay) begin
				delay_cnt <= 0;
				mem_ready_delay <= 1;
			end
			else begin
				delay_cnt <= delay_cnt +1 ;
				mem_ready_delay <= 0;
			end
		end
		else begin
			mem_ready_delay <= 0;
			delay_cnt <= 0;
		end
    end

	//always @(negedge clk) begin
//		if (mem_valid) delay_cnt <= next_delay_cnt;
//	end



	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
			mem_ready <= 1;
			out_byte_en <= 0;
			mem_rdata <= memory[mem_la_addr >> 2];
			if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
			end
			else
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en <= 1;
				out_byte_32 <= mem_la_wdata;
			end
		end
	end else begin
		always @(posedge clk) begin
			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready && m_read_en;

			m_read_data <= memory[mem_addr >> 2];
			mem_rdata <= m_read_data;

			out_byte_en <= 0;

			(* parallel_case *)
			case (1)
				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					m_read_en <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					mem_ready <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
					out_byte_en <= 1;
					out_byte_32 <= mem_wdata;
					mem_ready <= 1;
				end
			endcase
		end
	end endgenerate

endmodule