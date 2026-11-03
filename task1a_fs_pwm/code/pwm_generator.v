// Logic Quest Bot : Task 1A : PWM Generator
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the clk_5MHz Clock Frequency to 500Hz and perform Pulse Width Modulation on it.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//PWM Generator
//Inputs : clk_5MHz, pulse_width
//Output : clk_500Hz, pwm_signal

module pwm_generator(
    input clk_5MHz,
    input reset_n,
    input [4:0] pulse_width,
    output reg clk_500Hz, pwm_signal
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

/*
 add your code here 
 */
 reg [8:0] sub;
reg [4:0] step;

always @(posedge clk_5MHz or negedge reset_n) begin
    if (!reset_n) begin
        sub        <= 9'd0;
        step       <= 5'd0;
        clk_500Hz  <= 1'b0;
        pwm_signal <= 1'b0;
    end
    else begin
        if (sub == 9'd499) begin
            sub <= 9'd0;
            if (step == 5'd19)
                step <= 5'd0;
            else
                step <= step + 5'd1;
        end
        else begin
            sub <= sub + 9'd1;
        end

        clk_500Hz  <= (step < 5'd10);
        pwm_signal <= (step < pulse_width);
    end
end
 
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule

