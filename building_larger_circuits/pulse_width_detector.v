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

module tb_pwd;
reg clk, pulse_in, reset;
wire [3:0] pulse_width;
wire valid;

pulse_width_detector DUT(.clk(clk), .pulse_in(pulse_in), .reset(reset), .pulse_width(pulse_width), .valid(valid));

always #5 clk=~clk;

initial begin

    $monitor("time=%0t reset=%b pulse_in=%b pulse_width=%d valid=%b",
         $time, reset, pulse_in, pulse_width, valid);
end

initial begin
    $display("----------------simulation starts------------------");
    clk=0;
    reset=0;
    pulse_in=0;

    #10; reset=1;

    //test_1
    #10;
    pulse_in=1;
    #40;
    pulse_in=0;
  
  	@(posedge clk);
	#1;

  	if(pulse_width==4'd4)begin
        $display("test 1 passed");
    end
    else begin
        $display("test 1 failed");
    end
    
    //test_2
    #30;
    pulse_in=1;
    #70;
    pulse_in=0;
  	
    @(posedge clk);
  	#1;

  	if(pulse_width==4'd7)begin
        $display("test 1 passed");
    end
    else begin
        $display("test 1 failed");
    end
    #20;
    $finish;

end
endmodule