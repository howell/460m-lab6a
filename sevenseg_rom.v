module sevenseg_rom(HexVal, Out);

	 input [3:0] HexVal;
	 output [7:0] Out;

	 reg [7:0] tempOut;

	 assign Out = tempOut;

	 always @(HexVal)
	 begin
		tempOut <= 0;
		case(HexVal)
			0: begin
				tempOut <= ~(8'b11111100);
			end
			1: begin
				tempOut <= ~(8'b01100000);
			end
			2: begin
				tempOut <= ~(8'b11011010);
			end
			3: begin
				tempOut <= ~(8'b11110010);
			end
			4: begin
				tempOut <= ~(8'b01100110);
			end
			5: begin
				tempOut <= ~(8'b10110110);
			end
			6: begin
				tempOut <= ~(8'b10111110);
			end
			7: begin
				tempOut <= ~(8'b11100000);
			end
			8: begin
				tempOut <= ~(8'b11111110);
			end
			9: begin
				tempOut <= ~(8'b11110110);
			end

            10: begin
                tempOut <= ~(8'b11101110);
            end

            11: begin
                tempOut <= ~(8'b00111110);
            end

            12: begin
                tempOut <= ~(8'b10011100);
            end

            13: begin
                tempOut <= ~(8'b01111010);
            end

            14: begin
                tempOut <= ~(8'b10011110);
            end

            15: begin
                tempOut <= ~(8'b10001110);
            end

			default: begin // error - turn everything on
				tempOut <= ~(8'b11111111);
			end
		endcase
	 end /* always */

endmodule /* sevenseg_rom */
