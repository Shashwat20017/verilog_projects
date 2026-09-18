module pulse_width_detector(
    input clk, pulse_in, reset, 
    output reg [3:0] pulse_width, 
    output reg valid);

reg [3:0] count;
reg pulse_in_d;

wire rising= (!pulse_in_d && pulse_in);
wire falling= (pulse_in_d && !pulse_in);

always@(posedge clk or negedge reset) begin
    if(!reset) begin
        count<=0;
        pulse_in_d<=0;
        pulse_width<=0;
        valid<=0;
    end
    else begin
        pulse_in_d<=pulse_in;
        if(rising) begin
            count<=4'b1;
            valid<=0;
        end
         else if(falling) begin
            count<=0;
            valid<=1'b1;
            pulse_width <=count;
         end
         else if(pulse_in)begin
            count<=count+1;
            valid<=1'b0;
         end
         else begin
            valid<=0;
         end
    end
end
endmodule