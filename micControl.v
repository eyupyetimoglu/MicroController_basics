
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
module Microcontroller(
    input clk,
    input reset,
    input [7:0] data_in,
    output reg [7:0] data_out // Changed to reg type for always block assignment
);
    // Register File
    reg [7:0] registers [0:15];
    reg [7:0] instruction_register;
    reg [3:0] program_counter;
    reg [7:0] alu_out;
    integer i; // Declared here

    // ALU
    always @(*) begin
        case (instruction_register[7:4]) // Opcode
            4'b0000: alu_out = registers[instruction_register[3:0]] + data_in; // ADD
            4'b0001: alu_out = registers[instruction_register[3:0]] - data_in; // SUB
            4'b0010: alu_out = registers[instruction_register[3:0]] & data_in; // AND
            4'b0011: alu_out = registers[instruction_register[3:0]] | data_in; // OR
            default: alu_out = 8'b0;
        endcase
    end

    // Control Unit
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            program_counter <= 4'b0;
            instruction_register <= 8'b0;
            alu_out <= 8'b0;
            for (i = 0; i < 16; i = i + 1) begin
                registers[i] <= 8'b0;
            end
        end else begin
            instruction_register <= data_in; // Fetch Instruction
            registers[instruction_register[3:0]] <= alu_out; // Execute and Write Back
            program_counter <= program_counter + 1; // Increment Program Counter
        end
        data_out <= alu_out; // Assigning output
    end
endmodule

module Microcontroller_tb;
    // Inputs
    reg clk;
    reg reset;
    reg [7:0] data_in;

    // Outputs
    wire [7:0] data_out;

    // Instantiate the Microcontroller
    Microcontroller microControl (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test Sequence
    initial begin
        reset = 1;
        data_in = 8'b0;
        #20; // Wait for reset

        reset = 0;
        
        data_in = 8'b00001010; // Opcode: 0000 (ADD), Operand: 1010
        #20;

        data_in = 8'b00011001; // Opcode: 0001 (SUB), Operand: 1001
        #20;

        data_in = 8'b00100101; // Opcode: 0010 (AND), Operand: 0101
        #20;

        data_in = 8'b00111100; // Opcode: 0011 (OR), Operand: 1100
        #20;

        $stop;
    end

    // Monitor
    initial begin
        $monitor("Reset = %b | Data_in = %b | Data_out = %b", reset, data_in, data_out);
    end
endmodule



