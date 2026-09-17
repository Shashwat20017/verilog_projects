module apb_slave (
    input        PCLK,
    input        PRESETn,
    input        PSEL,
    input        PENABLE,
    input        PWRITE,
    input [7:0]  PADDR,
    input [31:0] PWDATA,
    output reg [31:0] PRDATA,
    output reg       PREADY,
    output reg       PSLVERR
);

reg [31:0] reg0, //0x00
           reg1, //0x04
           reg2, //0x08
           reg3; //0x0c

reg [1:0] current_state, next_state;

localparam IDLE =2'b00,
           SETUP =2'b01,
           ACCESS =2'b10;

//next stsate logic
    always@(posedge PCLK or negedge PRESETn) begin

      if(!PRESETn) begin
        current_state<= IDLE;
      end
      else begin
        current_state<=next_state;
      end
    end

    always@(*) begin
      PREADY=0;
      PSLVERR=0;

      next_state=current_state;
     case (current_state)
     IDLE : begin
      if(PSEL) begin
        next_state=SETUP;
      end
      else begin
        next_state=IDLE;
      end
     end

      SETUP: begin
        if(PENABLE) begin
          next_state=ACCESS;

      end 
        else begin
          next_state=SETUP;
        end
      end

      ACCESS: begin
        PREADY=1;
        if(PSEL) begin
          next_state=SETUP;
        end
        else begin
          next_state=IDLE;
        end

        case(PADDR)
        8'h00, 8'h04, 8'h08, 8'h0c: PSLVERR=0;
        default: PSLVERR=1;
        endcase
      end
      

      default: begin
        next_state=IDLE;
        end 
      end
     endcase   
    end

    always@(posedge PCLK or negedge PRESETn) begin
      if(!PRESETn) begin
           reg0<=0; 
           reg1<=0;
           reg2<=0;
           reg3<=0;
      end
      else  begin
        if(PENABLE && PSEL && PWRITE) begin
          case(PADDR)
          8'h00: begin 
            reg0<=PWDATA;
            end
          8'h04:begin
            reg1<=PWDATA;
             end
          8'h08: begin 
            reg2<=PWDATA;
             end
          8'h0c: begin
            reg3<=PWDATA;
             end
          endcase
      end
      else if(PENABLE && PSEL && !PWRITE) begin // read logic
          PRDATA<=0;
          case(PADDR)
          8'h00: begin 
            PRDATA<=reg0;
             end
          8'h04:begin
            PRDATA<=reg1;
             end
          8'h08: begin 
            PRDATA<=reg2;
             end
          8'h0c: begin
            PRDATA<=reg3;
             end
          default: PRDATA<=0;
          endcase
    end
    

endmodule
