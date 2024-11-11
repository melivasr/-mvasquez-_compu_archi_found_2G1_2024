module mux2a1 (input logic a,b,s, output logic y);
 assign y = ~s & a  |  s & b;
endmodule 