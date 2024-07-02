`include "Defines.vh"

module Fixed_Point_Unit 
#(
    parameter WIDTH = 32,
    parameter FBITS = 10
)
(
    input wire clk,
    input wire reset,
    
    input wire [WIDTH - 1 : 0] operand_1,
    input wire [WIDTH - 1 : 0] operand_2,
    
    input wire [ 1 : 0] operation,

    output reg [WIDTH - 1 : 0] result,
    output reg ready
);

    always @(*)
    begin
        case (operation)
            `FPU_ADD    : begin result <= operand_1 + operand_2; ready <= 1; end
            `FPU_SUB    : begin result <= operand_1 - operand_2; ready <= 1; end
            `FPU_MUL    : begin result <= product[WIDTH + FBITS - 1 : FBITS]; ready <= product_ready; end
            `FPU_SQRT   : begin result <= root; ready <= root_ready; end
            default     : begin result <= 'bz; ready <= 0; end
        endcase
    end

    always @(posedge reset)
    begin
        if (reset)  ready = 0;
        else        ready = 'bz;
    end
    // ------------------- //
    // Square Root Circuit //
    // ------------------- //
    reg [WIDTH - 1 : 0] root;
    reg root_ready;

        /*
         *  Describe Your Square Root Calculator Circuit Here.
         */

    // *********** Square Root Internal Signals  *********** \\
    reg [WIDTH - 1 : 0] radic;
    reg [WIDTH - 1 : 0] aux_root;
    reg [WIDTH - 1 : 0] aux_result;
    reg [WIDTH - 1 : 0] f_result;
    reg [WIDTH - 1 : 0] iteration;
    reg [WIDTH - 1 : 0] aux_operand_1;

    // State machine for square root
    localparam INITIAL = 2'd0;  // 2'd0 -> zero in decimal 
    localparam SQRT = 2'd1;     // 2'd1 -> one in decimal
    reg state1;
    reg [1 : 0] two_bit;

    always @(posedge clk) begin
        if (reset)
        begin
            state1 <= INITIAL;
            root <= 0;
            root_ready <= 0;
            aux_operand_1 <= operand_1;
        end
        else 
        begin
            case (state1)
                INITIAL: begin
                    if (operation == `FPU_SQRT) begin
                        // Initialize for square root calculation
                        radic <= operand_1[WIDTH - 1: WIDTH - 2];
                        aux_root <= 2'b01;
                        iteration <= (WIDTH + FBITS) / 2; // Calculate iterations for fixed-point
                        state1 <= SQRT;
                        f_result <= 0;
                    end
                end
                SQRT: begin
                    if (iteration > 0) 
                    begin
                        //radic minus aux_root to find next digit for f_result
                        aux_result <= radic - aux_root;
                        //Checking if aux_result is negative or not
                        if(aux_result < 0 ) 
                        begin
                            //If result is negative next digit is 0 and a shift will work
                            f_result <= (f_result << 1);
                        end 
                        else 
                        begin
                            //If result is not negative next digit will be 1. A shift and a plus 1 
                            f_result <= (f_result << 1) + 1;
                        end

                        //Shifting operan_1_temp to bring next two MSB bits
                        aux_operand_1 <= aux_operand_1 << 2;
                        //Extract two MSB bits of operand_1e_temp
                        two_bit <= aux_operand_1[WIDTH - 1 : WIDTH - 2];
                        //Append 01 to radic for next iteration
                        radic <= (radic << 2) + two_bit;
                        //Append 01 to result for next iteration
                        aux_root <= (f_result << 2) + 1 ;
                        
                        iteration <= iteration - 1;
                    end else begin
                        root <= f_result;
                        root_ready <= 1;
                        state1 <= INITIAL;
                    end
                end
            endcase
        end
    end

        
    // ------------------ //
    // Multiplier Circuit //
    // ------------------ //   
    reg [64 - 1 : 0] product;
    reg product_ready;

    reg     [15 : 0] multiplierCircuitInput1;
    reg     [15 : 0] multiplierCircuitInput2;
    wire    [31 : 0] multiplierCircuitResult;

    Multiplier multiplier_circuit
    (
        .operand_1(multiplierCircuitInput1),
        .operand_2(multiplierCircuitInput2),
        .product(multiplierCircuitResult)
    );

    reg     [31 : 0] partialProduct1;
    reg     [31 : 0] partialProduct2;
    reg     [31 : 0] partialProduct3;
    reg     [31 : 0] partialProduct4;
    
        /*
         *  Describe Your 32-bit Multiplier Circuit Here.
         */

         
          //Three bit register to store 32-bit multiplication state
    reg [2:0] state;

    //Define parameters for each state
    localparam INITIALSTATE = 3'b000;   // 3'b000 -> 0
    localparam FIRSTMUL = 3'b001;       //3'b001 -> 1
    localparam SECONDMUL = 3'b010;      //3'b010 -> 2
    localparam THIRDMUL = 3'b011;       //3'b011 -> 3
    localparam FOURTHMUL = 3'b100;      //3'b100 -> 4
    localparam ADD = 3'b101;            //3'b101 -> 5

    always @(posedge clk) begin
        if (reset)                  //All state parameters would be Zero 
        begin
            state <= INITIALSTATE;  // Sets state to Zero
            product <= 0;
            product_ready <= 0;
        end
         else 
         begin
            case (state)
                //Initializing registers
                INITIALSTATE:
                begin
                    if (operation == `FPU_MUL) begin   // Checking For FPU Multiply Function Call
                        // Al * Bl
                        multiplierCircuitInput1 <= operand_1[15 : 0];
                        multiplierCircuitInput2 <= operand_2[15 : 0];
                        partialProduct1 <= 0;
                        partialProduct2 <= 0;
                        partialProduct3 <= 0;
                        partialProduct4 <= 0;
                        // Changing State to FIRSTMUL On The Next Cycle
                        state <= FIRSTMUL;
                    end
                end
                FIRSTMUL: begin
                    // Storing Partial Product Results
                    partialProduct1 <= multiplierCircuitResult;
                    // Ah * Bl
                    multiplierCircuitInput1 <= operand_1[31 : 16];
                    multiplierCircuitInput2 <= operand_2[15 : 0];
                    // Changing State to SECONDMUL On The Next Cycle
                    state <= SECONDMUL;
                end
                SECONDMUL: begin
                    // Storing Partial Product Result with a 16-bit Shift To The Left
                    partialProduct2 <= multiplierCircuitResult << 16;
                    // Al * Bh
                    multiplierCircuitInput1 <= operand_1[15 : 0];
                    multiplierCircuitInput2 <= operand_2[31 : 16];
                    // Changing State to THIRDMUL On The Next Cycle
                    state <= THIRDMUL;
                end
                THIRDMUL: begin
                    // Store partial product with 16-bit shift to the left
                    partialProduct3 <= multiplierCircuitResult << 16;
                    // Ah * Bh
                    multiplierCircuitInput1 <= operand_1[31 : 16];
                    multiplierCircuitInput2 <= operand_2[31 : 16];
                    // Change state to be FOURTHMUL at next cycle
                    state <= FOURTHMUL;
                end
                FOURTHMUL: begin
                    // Store partial product with 32-bit shift to the left
                    partialProduct4 <= multiplierCircuitResult << 32;
                    //  Change state to be ADD at next cycle
                    state <= ADD;
                end
                ADD: begin
                    // Storing Partial Product
                    product <= partialProduct1 + partialProduct2 + partialProduct3 + partialProduct4;
                    // Moving to the Starting Point
                    state <= INITIALSTATE;
                    product_ready <= 1; 
                end
                default: begin
                    state <= INITIALSTATE;
                end
            endcase
        end
    end
endmodule


module Multiplier
(
    input wire [15 : 0] operand_1,
    input wire [15 : 0] operand_2,

    output reg [31 : 0] product
);

    always @(*)
    begin
        product <= operand_1 * operand_2;
    end
endmodule