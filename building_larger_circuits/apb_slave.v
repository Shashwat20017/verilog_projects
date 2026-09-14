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
    [31:0] reg1, //0x04
    [31:0] reg2, //0x08
    [31:0] reg3; //0x0c

localparam IDLE =2'b00,
           SETUP =2'b01,
           ACCESS =2'b10;


    always@(posedge clk or negedge PRESETn) begin
      if(!PRESETn) begin
        
      end

    end