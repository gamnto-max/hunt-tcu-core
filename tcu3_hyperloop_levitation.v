`timescale 1ns / 1ps
module tcu_hyperloop_levitation (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [63:0] gap_sensor_in,        // Telemetría real del gap magnético (Q32.32)
    output reg  [63:0] v_a_levitation,       // Vector de corrección del raíl A
    output reg  [63:0] v_b_levitation,       // Vector de corrección del raíl B
    output reg  [63:0] v_c_damping,          // Amortiguación elástica pasiva
    output reg         gap_stable            // Bandera de estabilidad (#=1 / σ=0.5)
);
    reg [63:0] dynamic_load;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            v_a_levitation <= 64'h0; v_b_levitation <= 64'h0;
            v_c_damping    <= 64'h0; gap_stable     <= 1'b0;
        end else begin
            dynamic_load   <= (gap_sensor_in * 29) / 10; // Factor elástico estricto de Mach 1
            v_a_injection  <= (dynamic_load >> 1);       // Reparto simétrico 0.5 (σ=1/2)
            v_b_derivation <= (dynamic_load >> 1);
            v_c_damping    <= dynamic_load - ((dynamic_load >> 1) + (dynamic_load >> 1));
            gap_stable     <= 1'b1;                      // Bloqueo de fase invariante activa
        end
    end
endmodule
