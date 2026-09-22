interface pwd_if(input logic clk);
    logic reset;
    logic pulse_in;
    logic [3:0]pulse_width;
    logic valid;
endinterface 

class pulse_generator;
    mailbox gen_mbx;
    function new(mailbox gen_mbx);
        this.gen_mbx=gen_mbx;
    endfunction

    task run();
        pulse_transaction t;
        repeat(10) begin

            t=new();

            if(!t.randomize()) begin
                $display("randomization failed");
            end
            else begin
                gen_mbx.put(t);
            end
        end
    endtask

endclass

class pulse_transaction;

    rand logic [3:0]width;

    constraint c_width{
        width inside {[2:8]};
    }

endclass

class pulse_driver;

    virtual pwd_if vif; 
    mailbox gen_mbx;

    function new(virtual pwd_if vif, mailbox gen_mbx);
        this.vif=vif;
        this.gen_mbx=gen_mbx;
    endfunction
    task run();
        pulse_transaction t;
        repeat(10) begin
            gen_mbx.get(t);
            drive(t);
        end
    endtask
        

    task drive(pulse_transaction t);
        vif.pulse_in=1;
        repeat(t.width)
            @(posedge vif.clk);
        vif.pulse_in=0;
    endtask
endclass

class pulse_monitor;
    virtual pwd_if vif;
    mailbox actual_mbx;

    function new(virtual pwd_if vif, mailbox actual_mbx);
        this.vif=vif;
        this.actual_mbx=actual_mbx;
    endfunction

    task monitor();

        pulse_transaction actual;

        forever begin
            @(posedge vif.clk);

            if(vif.valid) begin
                actual=new();
                actual.width=vif.pulse_width;
                actual_mbx.put(actual);
                $display("actual width=%0d",vif.pulse_width);
            end
        end
        endtask
endclass

class pulse_scoreboard;
    mailbox actual_mbx;
    mailbox expected_mbx;
    function new(mailbox expected_mbx, mailbox actual_mbx);
        this.expected_mbx=expected_mbx;
        this.actual_mbx=actual_mbx;
    endfunction

    task check();
        pulse_transaction actual;
        pulse_transaction expected;
        forever begin
            actual_mbx.get(actual);
            expected_mbx.get(expected);
            $display("actual width=%0d",actual.width);

            if(expected.width==actual.width)begin
                $display("test passed");
            end
            else begin
                $display("test failed");
            end
        end
    endtask
endclass
module tb_pwd;

logic clk;
pwd_if vif(clk);


pwd DUT(.clk(clk),.pulse_in(vif.pulse_in),.reset(vif.reset),.pulse_width(vif.pulse_width),.valid(vif.valid));


always #5 clk=~clk;

initial begin
    clk=0;

    vif.reset=0;
    vif.pulse_in=0;

    #10; 
    vif.reset=1;
end
mailbox actual_mbx;
mailbox expected_mbx;

pulse_transaction t;
pulse_driver d;
pulse_monitor m;
pulse_scoreboard scb;

initial begin
    actual_mbx=new();
    expected_mbx=new();
    t=new();
    d=new(vif);
    m=new(vif, actual_mbx);
    scb=new(expected_mbx,actual_mbx);
    fork
        m.monitor();
        scb.check();
    join_none 
    
    #10; //reset removal

    if(!t.randomize())
        $display("randomization failed");
    else begin
        $display("width=%0d",t.width);
        expected_mbx.put(t);
        d.drive(t);
    end
end
endmodule