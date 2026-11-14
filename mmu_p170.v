module l0_tlb (
  input clk,
  input rst,
  input req_valid,
  input [63:0] req_va,
  input req_is_write,
  input req_is_fetch,
  input [63:0] satp,
  input [1:0] priv,
  input mstatus_mxr,
  input mstatus_sum,
  input fill_valid,
  input [63:0] fill_va,
  input [43:0] fill_ppn,
  input [4:0] fill_perm,
  input [15:0] fill_asid,
  input [0:0] fill_g,
  input [1:0] fill_level,
  input sfence_valid,
  input [63:0] sfence_va,
  input [15:0] sfence_asid,
  output hit,
  output [63:0] pa,
  output fault,
  output [3:0] cause
);

  wire [11:0] _tmp_w0;
  assign _tmp_w0 = req_va[11:0];
  reg [26:0] vpn [0:3];
  reg [43:0] ppn [0:3];
  reg [4:0] perm [0:3];
  reg [0:0] valid [0:3];
  reg [15:0] asid [0:3];
  reg [0:0] g [0:3];
  reg [1:0] lvl [0:3];
  wire [26:0] va_vpn;
  wire [15:0] satp_asid;
  wire [0:0] m0;
  wire [0:0] m1;
  wire [0:0] m2;
  wire [0:0] m3;
  wire [0:0] hit_any;
  wire [0:0] r;
  wire [0:0] w;
  wire [0:0] x;
  wire [0:0] u;
  wire [0:0] ok;
  reg [1:0] fill_rr;
  wire [26:0] sfvpn;
  wire [0:0] sfva0;
  wire [0:0] sfasid0;
  wire [43:0] ppn0_out;
  wire [43:0] ppn1_out;
  wire [43:0] ppn2_out;
  wire [43:0] ppn3_out;
  wire [43:0] pa_base;
  wire [0:0] vm0;
  wire [0:0] vm1;
  wire [0:0] vm2;
  wire [0:0] vm3;
  wire [0:0] am0;
  wire [0:0] am1;
  wire [0:0] am2;
  wire [0:0] am3;
  assign va_vpn = req_va[38:12];
  assign satp_asid = satp[59:44];
  assign sfvpn = sfence_va[38:12];
  assign sfva0 = (sfence_va == 0);
  assign sfasid0 = (sfence_asid == 0);
  assign vm0 = ((lvl[0] == 0) ? (vpn[0] == va_vpn) : ((lvl[0] == 1) ? (vpn[0][26:9] == va_vpn[26:9]) : ((lvl[0] == 2) ? (vpn[0][26:18] == va_vpn[26:18]) : 0)));
  assign vm1 = ((lvl[1] == 0) ? (vpn[1] == va_vpn) : ((lvl[1] == 1) ? (vpn[1][26:9] == va_vpn[26:9]) : ((lvl[1] == 2) ? (vpn[1][26:18] == va_vpn[26:18]) : 0)));
  assign vm2 = ((lvl[2] == 0) ? (vpn[2] == va_vpn) : ((lvl[2] == 1) ? (vpn[2][26:9] == va_vpn[26:9]) : ((lvl[2] == 2) ? (vpn[2][26:18] == va_vpn[26:18]) : 0)));
  assign vm3 = ((lvl[3] == 0) ? (vpn[3] == va_vpn) : ((lvl[3] == 1) ? (vpn[3][26:9] == va_vpn[26:9]) : ((lvl[3] == 2) ? (vpn[3][26:18] == va_vpn[26:18]) : 0)));
  assign am0 = ((asid[0] == satp_asid) | g[0]);
  assign am1 = ((asid[1] == satp_asid) | g[1]);
  assign am2 = ((asid[2] == satp_asid) | g[2]);
  assign am3 = ((asid[3] == satp_asid) | g[3]);
  assign m0 = ((valid[0] & vm0) & am0);
  assign m1 = ((valid[1] & vm1) & am1);
  assign m2 = ((valid[2] & vm2) & am2);
  assign m3 = ((valid[3] & vm3) & am3);
  assign hit_any = (((m0 | m1) | m2) | m3);
  assign hit = (hit_any & (satp[63:60] == 8));
  assign ppn0_out = ((lvl[0] == 0) ? ppn[0] : ((lvl[0] == 1) ? {ppn[0][43:9], req_va[20:12]} : ((lvl[0] == 2) ? {ppn[0][43:18], req_va[29:12]} : ppn[0])));
  assign ppn1_out = ((lvl[1] == 0) ? ppn[1] : ((lvl[1] == 1) ? {ppn[1][43:9], req_va[20:12]} : ((lvl[1] == 2) ? {ppn[1][43:18], req_va[29:12]} : ppn[1])));
  assign ppn2_out = ((lvl[2] == 0) ? ppn[2] : ((lvl[2] == 1) ? {ppn[2][43:9], req_va[20:12]} : ((lvl[2] == 2) ? {ppn[2][43:18], req_va[29:12]} : ppn[2])));
  assign ppn3_out = ((lvl[3] == 0) ? ppn[3] : ((lvl[3] == 1) ? {ppn[3][43:9], req_va[20:12]} : ((lvl[3] == 2) ? {ppn[3][43:18], req_va[29:12]} : ppn[3])));
  assign pa_base = (m0 ? ppn0_out : (m1 ? ppn1_out : (m2 ? ppn2_out : ppn3_out)));
  assign pa = (({{20{1'b0}}, pa_base} << 12) | {{52{1'b0}}, _tmp_w0});
  assign r = (m0 ? perm[0][0] : (m1 ? perm[1][0] : (m2 ? perm[2][0] : perm[3][0])));
  assign w = (m0 ? perm[0][1] : (m1 ? perm[1][1] : (m2 ? perm[2][1] : perm[3][1])));
  assign x = (m0 ? perm[0][2] : (m1 ? perm[1][2] : (m2 ? perm[2][2] : perm[3][2])));
  assign u = (m0 ? perm[0][3] : (m1 ? perm[1][3] : (m2 ? perm[2][3] : perm[3][3])));
  assign ok = (((priv == 0) ? u : ((priv == 1) ? (u ? (0 ? 0 : mstatus_sum) : 1) : ((priv == 3) ? 1 : 0))) & (0 ? x : (req_is_write ? w : (r ? 1 : (mstatus_mxr ? x : 0)))));
  assign fault = (hit_any & (!ok));
  assign cause = (req_is_fetch ? 12 : (req_is_write ? 15 : 13));

always @(posedge clk or posedge rst) begin
    if (rst) begin
      fill_rr <= {1'd0, 0};
      valid[0] <= 0;
      valid[1] <= 0;
      valid[2] <= 0;
      valid[3] <= 0;
    end else begin
      if (sfence_valid) begin
        if (sfva0 ? (sfasid0 ? 1 : ((asid[0] == sfence_asid) & (!g[0]))) : (sfasid0 ? ((lvl[0] == 0) ? (vpn[0] == sfvpn) : ((lvl[0] == 1) ? (vpn[0][26:9] == sfvpn[26:9]) : ((lvl[0] == 2) ? (vpn[0][26:18] == sfvpn[26:18]) : 0))) : ((((lvl[0] == 0) ? (vpn[0] == sfvpn) : ((lvl[0] == 1) ? (vpn[0][26:9] == sfvpn[26:9]) : ((lvl[0] == 2) ? (vpn[0][26:18] == sfvpn[26:18]) : 0))) & (asid[0] == sfence_asid)) & (!g[0])))) begin
          valid[0] <= 0;
        end
        if (sfva0 ? (sfasid0 ? 1 : ((asid[1] == sfence_asid) & (!g[1]))) : (sfasid0 ? ((lvl[1] == 0) ? (vpn[1] == sfvpn) : ((lvl[1] == 1) ? (vpn[1][26:9] == sfvpn[26:9]) : ((lvl[1] == 2) ? (vpn[1][26:18] == sfvpn[26:18]) : 0))) : ((((lvl[1] == 0) ? (vpn[1] == sfvpn) : ((lvl[1] == 1) ? (vpn[1][26:9] == sfvpn[26:9]) : ((lvl[1] == 2) ? (vpn[1][26:18] == sfvpn[26:18]) : 0))) & (asid[1] == sfence_asid)) & (!g[1])))) begin
          valid[1] <= 0;
        end
        if (sfva0 ? (sfasid0 ? 1 : ((asid[2] == sfence_asid) & (!g[2]))) : (sfasid0 ? ((lvl[2] == 0) ? (vpn[2] == sfvpn) : ((lvl[2] == 1) ? (vpn[2][26:9] == sfvpn[26:9]) : ((lvl[2] == 2) ? (vpn[2][26:18] == sfvpn[26:18]) : 0))) : ((((lvl[2] == 0) ? (vpn[2] == sfvpn) : ((lvl[2] == 1) ? (vpn[2][26:9] == sfvpn[26:9]) : ((lvl[2] == 2) ? (vpn[2][26:18] == sfvpn[26:18]) : 0))) & (asid[2] == sfence_asid)) & (!g[2])))) begin
          valid[2] <= 0;
        end
        if (sfva0 ? (sfasid0 ? 1 : ((asid[3] == sfence_asid) & (!g[3]))) : (sfasid0 ? ((lvl[3] == 0) ? (vpn[3] == sfvpn) : ((lvl[3] == 1) ? (vpn[3][26:9] == sfvpn[26:9]) : ((lvl[3] == 2) ? (vpn[3][26:18] == sfvpn[26:18]) : 0))) : ((((lvl[3] == 0) ? (vpn[3] == sfvpn) : ((lvl[3] == 1) ? (vpn[3][26:9] == sfvpn[26:9]) : ((lvl[3] == 2) ? (vpn[3][26:18] == sfvpn[26:18]) : 0))) & (asid[3] == sfence_asid)) & (!g[3])))) begin
          valid[3] <= 0;
        end
      end
      if (fill_valid) begin
        vpn[fill_rr] <= fill_va[38:12];
        ppn[fill_rr] <= fill_ppn;
        perm[fill_rr] <= fill_perm;
        asid[fill_rr] <= fill_asid;
        g[fill_rr] <= fill_g;
        lvl[fill_rr] <= fill_level;
        valid[fill_rr] <= 1;
        fill_rr <= ((fill_rr + 1) & 3);
      end
    end
end

endmodule

module l1_tlb (
  input clk,
  input rst,
  input req_valid,
  input [63:0] req_va,
  input req_is_write,
  input req_is_fetch,
  input [3:0] req_id,
  input [63:0] satp,
  input [1:0] priv,
  input mstatus_mxr,
  input mstatus_sum,
  input fill_valid,
  input [63:0] fill_va,
  input [43:0] fill_ppn,
  input [4:0] fill_perm,
  input [15:0] fill_asid,
  input [0:0] fill_g,
  input [1:0] fill_level,
  input sfence_valid,
  input [63:0] sfence_va,
  input [15:0] sfence_asid,
  output resp_valid,
  output [63:0] resp_pa,
  output resp_fault,
  output [3:0] resp_cause,
  output [3:0] resp_id,
  output [63:0] resp_tval,
  output hit
);

  wire [11:0] _tmp_w0;
  assign _tmp_w0 = s1_va[11:0];
  reg [26:0] vpn_w0 [0:15];
  reg [43:0] ppn_w0 [0:15];
  reg [0:0] valid_w0 [0:15];
  reg [4:0] perm_w0 [0:15];
  reg [15:0] asid_w0 [0:15];
  reg [0:0] g_w0 [0:15];
  reg [1:0] lvl_w0 [0:15];
  reg [26:0] vpn_w1 [0:15];
  reg [43:0] ppn_w1 [0:15];
  reg [0:0] valid_w1 [0:15];
  reg [4:0] perm_w1 [0:15];
  reg [15:0] asid_w1 [0:15];
  reg [0:0] g_w1 [0:15];
  reg [1:0] lvl_w1 [0:15];
  wire [3:0] idx;
  wire [3:0] fill_idx;
  reg [0:0] fill_way;
  reg [0:0] s1_valid;
  reg [63:0] s1_va;
  reg [3:0] s1_id;
  reg [0:0] s1_is_write;
  reg [26:0] s1_w0_vpn;
  reg [26:0] s1_w1_vpn;
  reg [43:0] s1_w0_ppn;
  reg [43:0] s1_w1_ppn;
  reg [0:0] s1_w0_valid;
  reg [0:0] s1_w1_valid;
  reg [4:0] s1_w0_perm;
  reg [4:0] s1_w1_perm;
  reg [15:0] s1_w0_asid;
  reg [15:0] s1_w1_asid;
  reg [0:0] s1_w0_g;
  reg [0:0] s1_w1_g;
  reg [1:0] s1_w0_lvl;
  reg [1:0] s1_w1_lvl;
  wire [26:0] va_vpn;
  wire [0:0] m0;
  wire [0:0] m1;
  wire [0:0] hit_int;
  wire [43:0] pa_base;
  wire [0:0] ok;
  wire [0:0] r;
  wire [0:0] w;
  wire [0:0] x;
  wire [0:0] u;
  wire [63:0] tval;
  wire [15:0] satp_asid;
  wire [26:0] sfvpn;
  wire [0:0] sfva0;
  wire [0:0] sfasid0;
  wire [43:0] ppn0_out;
  wire [43:0] ppn1_out;
  wire [26:0] r_w0_vpn;
  wire [26:0] r_w1_vpn;
  wire [43:0] r_w0_ppn;
  wire [43:0] r_w1_ppn;
  wire [0:0] r_w0_valid;
  wire [0:0] r_w1_valid;
  wire [4:0] r_w0_perm;
  wire [4:0] r_w1_perm;
  wire [15:0] r_w0_asid;
  wire [15:0] r_w1_asid;
  wire [0:0] r_w0_g;
  wire [0:0] r_w1_g;
  wire [1:0] r_w0_lvl;
  wire [1:0] r_w1_lvl;
  wire [0:0] vm0;
  wire [0:0] vm1;
  wire [0:0] am0;
  wire [0:0] am1;
  wire [63:0] pa_comb;
  assign idx = req_va[15:12];
  assign fill_idx = fill_va[15:12];
  assign satp_asid = satp[59:44];
  assign sfvpn = sfence_va[38:12];
  assign sfva0 = (sfence_va == 0);
  assign sfasid0 = (sfence_asid == 0);
  assign r_w0_vpn = vpn_w0[idx];
  assign r_w1_vpn = vpn_w1[idx];
  assign r_w0_ppn = ppn_w0[idx];
  assign r_w1_ppn = ppn_w1[idx];
  assign r_w0_valid = valid_w0[idx];
  assign r_w1_valid = valid_w1[idx];
  assign r_w0_perm = perm_w0[idx];
  assign r_w1_perm = perm_w1[idx];
  assign r_w0_asid = asid_w0[idx];
  assign r_w1_asid = asid_w1[idx];
  assign r_w0_g = g_w0[idx];
  assign r_w1_g = g_w1[idx];
  assign r_w0_lvl = lvl_w0[idx];
  assign r_w1_lvl = lvl_w1[idx];
  assign va_vpn = s1_va[38:12];
  assign vm0 = ((s1_w0_lvl == 0) ? (s1_w0_vpn == va_vpn) : ((s1_w0_lvl == 1) ? (s1_w0_vpn[26:9] == va_vpn[26:9]) : ((s1_w0_lvl == 2) ? (s1_w0_vpn[26:18] == va_vpn[26:18]) : 0)));
  assign vm1 = ((s1_w1_lvl == 0) ? (s1_w1_vpn == va_vpn) : ((s1_w1_lvl == 1) ? (s1_w1_vpn[26:9] == va_vpn[26:9]) : ((s1_w1_lvl == 2) ? (s1_w1_vpn[26:18] == va_vpn[26:18]) : 0)));
  assign am0 = ((s1_w0_asid == satp_asid) | s1_w0_g);
  assign am1 = ((s1_w1_asid == satp_asid) | s1_w1_g);
  assign m0 = ((s1_w0_valid & vm0) & am0);
  assign m1 = ((s1_w1_valid & vm1) & am1);
  assign hit_int = ((m0 | m1) & (satp[63:60] == 8));
  assign hit = hit_int;
  assign ppn0_out = ((s1_w0_lvl == 0) ? s1_w0_ppn : ((s1_w0_lvl == 1) ? {s1_w0_ppn[43:9], s1_va[20:12]} : ((s1_w0_lvl == 2) ? {s1_w0_ppn[43:18], s1_va[29:12]} : s1_w0_ppn)));
  assign ppn1_out = ((s1_w1_lvl == 0) ? s1_w1_ppn : ((s1_w1_lvl == 1) ? {s1_w1_ppn[43:9], s1_va[20:12]} : ((s1_w1_lvl == 2) ? {s1_w1_ppn[43:18], s1_va[29:12]} : s1_w1_ppn)));
  assign pa_base = (m0 ? ppn0_out : ppn1_out);
  assign pa_comb = (({{20{1'b0}}, pa_base} << 12) | {{52{1'b0}}, _tmp_w0});
  assign r = (m0 ? s1_w0_perm[0] : s1_w1_perm[0]);
  assign w = (m0 ? s1_w0_perm[1] : s1_w1_perm[1]);
  assign x = (m0 ? s1_w0_perm[2] : s1_w1_perm[2]);
  assign u = (m0 ? s1_w0_perm[3] : s1_w1_perm[3]);
  assign ok = (((priv == 0) ? u : ((priv == 1) ? (u ? (0 ? 0 : mstatus_sum) : 1) : ((priv == 3) ? 1 : 0))) & (0 ? x : (s1_is_write ? w : (r ? 1 : (mstatus_mxr ? x : 0)))));
  assign tval = (((!hit_int) | (!ok)) ? s1_va : 0);
  assign resp_valid = s1_valid;
  assign resp_id = s1_id;
  assign resp_pa = pa_comb;
  assign resp_fault = (s1_valid & ((!hit_int) | (!ok)));
  assign resp_cause = (s1_is_write ? 15 : 13);
  assign resp_tval = tval;

always @(posedge clk or posedge rst) begin
    if (rst) begin
      s1_valid <= 0;
      fill_way <= 0;
      valid_w0[0] <= 0;
      valid_w1[0] <= 0;
      valid_w0[1] <= 0;
      valid_w1[1] <= 0;
      valid_w0[2] <= 0;
      valid_w1[2] <= 0;
      valid_w0[3] <= 0;
      valid_w1[3] <= 0;
      valid_w0[4] <= 0;
      valid_w1[4] <= 0;
      valid_w0[5] <= 0;
      valid_w1[5] <= 0;
      valid_w0[6] <= 0;
      valid_w1[6] <= 0;
      valid_w0[7] <= 0;
      valid_w1[7] <= 0;
      valid_w0[8] <= 0;
      valid_w1[8] <= 0;
      valid_w0[9] <= 0;
      valid_w1[9] <= 0;
      valid_w0[10] <= 0;
      valid_w1[10] <= 0;
      valid_w0[11] <= 0;
      valid_w1[11] <= 0;
      valid_w0[12] <= 0;
      valid_w1[12] <= 0;
      valid_w0[13] <= 0;
      valid_w1[13] <= 0;
      valid_w0[14] <= 0;
      valid_w1[14] <= 0;
      valid_w0[15] <= 0;
      valid_w1[15] <= 0;
    end else begin
      if (sfence_valid) begin
        if (valid_w0[0] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[0] == sfence_asid) & (!g_w0[0]))) : (sfasid0 ? ((lvl_w0[0] == 0) ? (vpn_w0[0] == sfvpn) : ((lvl_w0[0] == 1) ? (vpn_w0[0][26:9] == sfvpn[26:9]) : ((lvl_w0[0] == 2) ? (vpn_w0[0][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[0] == 0) ? (vpn_w0[0] == sfvpn) : ((lvl_w0[0] == 1) ? (vpn_w0[0][26:9] == sfvpn[26:9]) : ((lvl_w0[0] == 2) ? (vpn_w0[0][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[0] == sfence_asid)) & (!g_w0[0]))))) begin
          valid_w0[0] <= 0;
        end
        if (valid_w1[0] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[0] == sfence_asid) & (!g_w1[0]))) : (sfasid0 ? ((lvl_w1[0] == 0) ? (vpn_w1[0] == sfvpn) : ((lvl_w1[0] == 1) ? (vpn_w1[0][26:9] == sfvpn[26:9]) : ((lvl_w1[0] == 2) ? (vpn_w1[0][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[0] == 0) ? (vpn_w1[0] == sfvpn) : ((lvl_w1[0] == 1) ? (vpn_w1[0][26:9] == sfvpn[26:9]) : ((lvl_w1[0] == 2) ? (vpn_w1[0][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[0] == sfence_asid)) & (!g_w1[0]))))) begin
          valid_w1[0] <= 0;
        end
        if (valid_w0[1] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[1] == sfence_asid) & (!g_w0[1]))) : (sfasid0 ? ((lvl_w0[1] == 0) ? (vpn_w0[1] == sfvpn) : ((lvl_w0[1] == 1) ? (vpn_w0[1][26:9] == sfvpn[26:9]) : ((lvl_w0[1] == 2) ? (vpn_w0[1][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[1] == 0) ? (vpn_w0[1] == sfvpn) : ((lvl_w0[1] == 1) ? (vpn_w0[1][26:9] == sfvpn[26:9]) : ((lvl_w0[1] == 2) ? (vpn_w0[1][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[1] == sfence_asid)) & (!g_w0[1]))))) begin
          valid_w0[1] <= 0;
        end
        if (valid_w1[1] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[1] == sfence_asid) & (!g_w1[1]))) : (sfasid0 ? ((lvl_w1[1] == 0) ? (vpn_w1[1] == sfvpn) : ((lvl_w1[1] == 1) ? (vpn_w1[1][26:9] == sfvpn[26:9]) : ((lvl_w1[1] == 2) ? (vpn_w1[1][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[1] == 0) ? (vpn_w1[1] == sfvpn) : ((lvl_w1[1] == 1) ? (vpn_w1[1][26:9] == sfvpn[26:9]) : ((lvl_w1[1] == 2) ? (vpn_w1[1][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[1] == sfence_asid)) & (!g_w1[1]))))) begin
          valid_w1[1] <= 0;
        end
        if (valid_w0[2] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[2] == sfence_asid) & (!g_w0[2]))) : (sfasid0 ? ((lvl_w0[2] == 0) ? (vpn_w0[2] == sfvpn) : ((lvl_w0[2] == 1) ? (vpn_w0[2][26:9] == sfvpn[26:9]) : ((lvl_w0[2] == 2) ? (vpn_w0[2][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[2] == 0) ? (vpn_w0[2] == sfvpn) : ((lvl_w0[2] == 1) ? (vpn_w0[2][26:9] == sfvpn[26:9]) : ((lvl_w0[2] == 2) ? (vpn_w0[2][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[2] == sfence_asid)) & (!g_w0[2]))))) begin
          valid_w0[2] <= 0;
        end
        if (valid_w1[2] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[2] == sfence_asid) & (!g_w1[2]))) : (sfasid0 ? ((lvl_w1[2] == 0) ? (vpn_w1[2] == sfvpn) : ((lvl_w1[2] == 1) ? (vpn_w1[2][26:9] == sfvpn[26:9]) : ((lvl_w1[2] == 2) ? (vpn_w1[2][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[2] == 0) ? (vpn_w1[2] == sfvpn) : ((lvl_w1[2] == 1) ? (vpn_w1[2][26:9] == sfvpn[26:9]) : ((lvl_w1[2] == 2) ? (vpn_w1[2][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[2] == sfence_asid)) & (!g_w1[2]))))) begin
          valid_w1[2] <= 0;
        end
        if (valid_w0[3] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[3] == sfence_asid) & (!g_w0[3]))) : (sfasid0 ? ((lvl_w0[3] == 0) ? (vpn_w0[3] == sfvpn) : ((lvl_w0[3] == 1) ? (vpn_w0[3][26:9] == sfvpn[26:9]) : ((lvl_w0[3] == 2) ? (vpn_w0[3][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[3] == 0) ? (vpn_w0[3] == sfvpn) : ((lvl_w0[3] == 1) ? (vpn_w0[3][26:9] == sfvpn[26:9]) : ((lvl_w0[3] == 2) ? (vpn_w0[3][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[3] == sfence_asid)) & (!g_w0[3]))))) begin
          valid_w0[3] <= 0;
        end
        if (valid_w1[3] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[3] == sfence_asid) & (!g_w1[3]))) : (sfasid0 ? ((lvl_w1[3] == 0) ? (vpn_w1[3] == sfvpn) : ((lvl_w1[3] == 1) ? (vpn_w1[3][26:9] == sfvpn[26:9]) : ((lvl_w1[3] == 2) ? (vpn_w1[3][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[3] == 0) ? (vpn_w1[3] == sfvpn) : ((lvl_w1[3] == 1) ? (vpn_w1[3][26:9] == sfvpn[26:9]) : ((lvl_w1[3] == 2) ? (vpn_w1[3][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[3] == sfence_asid)) & (!g_w1[3]))))) begin
          valid_w1[3] <= 0;
        end
        if (valid_w0[4] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[4] == sfence_asid) & (!g_w0[4]))) : (sfasid0 ? ((lvl_w0[4] == 0) ? (vpn_w0[4] == sfvpn) : ((lvl_w0[4] == 1) ? (vpn_w0[4][26:9] == sfvpn[26:9]) : ((lvl_w0[4] == 2) ? (vpn_w0[4][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[4] == 0) ? (vpn_w0[4] == sfvpn) : ((lvl_w0[4] == 1) ? (vpn_w0[4][26:9] == sfvpn[26:9]) : ((lvl_w0[4] == 2) ? (vpn_w0[4][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[4] == sfence_asid)) & (!g_w0[4]))))) begin
          valid_w0[4] <= 0;
        end
        if (valid_w1[4] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[4] == sfence_asid) & (!g_w1[4]))) : (sfasid0 ? ((lvl_w1[4] == 0) ? (vpn_w1[4] == sfvpn) : ((lvl_w1[4] == 1) ? (vpn_w1[4][26:9] == sfvpn[26:9]) : ((lvl_w1[4] == 2) ? (vpn_w1[4][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[4] == 0) ? (vpn_w1[4] == sfvpn) : ((lvl_w1[4] == 1) ? (vpn_w1[4][26:9] == sfvpn[26:9]) : ((lvl_w1[4] == 2) ? (vpn_w1[4][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[4] == sfence_asid)) & (!g_w1[4]))))) begin
          valid_w1[4] <= 0;
        end
        if (valid_w0[5] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[5] == sfence_asid) & (!g_w0[5]))) : (sfasid0 ? ((lvl_w0[5] == 0) ? (vpn_w0[5] == sfvpn) : ((lvl_w0[5] == 1) ? (vpn_w0[5][26:9] == sfvpn[26:9]) : ((lvl_w0[5] == 2) ? (vpn_w0[5][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[5] == 0) ? (vpn_w0[5] == sfvpn) : ((lvl_w0[5] == 1) ? (vpn_w0[5][26:9] == sfvpn[26:9]) : ((lvl_w0[5] == 2) ? (vpn_w0[5][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[5] == sfence_asid)) & (!g_w0[5]))))) begin
          valid_w0[5] <= 0;
        end
        if (valid_w1[5] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[5] == sfence_asid) & (!g_w1[5]))) : (sfasid0 ? ((lvl_w1[5] == 0) ? (vpn_w1[5] == sfvpn) : ((lvl_w1[5] == 1) ? (vpn_w1[5][26:9] == sfvpn[26:9]) : ((lvl_w1[5] == 2) ? (vpn_w1[5][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[5] == 0) ? (vpn_w1[5] == sfvpn) : ((lvl_w1[5] == 1) ? (vpn_w1[5][26:9] == sfvpn[26:9]) : ((lvl_w1[5] == 2) ? (vpn_w1[5][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[5] == sfence_asid)) & (!g_w1[5]))))) begin
          valid_w1[5] <= 0;
        end
        if (valid_w0[6] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[6] == sfence_asid) & (!g_w0[6]))) : (sfasid0 ? ((lvl_w0[6] == 0) ? (vpn_w0[6] == sfvpn) : ((lvl_w0[6] == 1) ? (vpn_w0[6][26:9] == sfvpn[26:9]) : ((lvl_w0[6] == 2) ? (vpn_w0[6][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[6] == 0) ? (vpn_w0[6] == sfvpn) : ((lvl_w0[6] == 1) ? (vpn_w0[6][26:9] == sfvpn[26:9]) : ((lvl_w0[6] == 2) ? (vpn_w0[6][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[6] == sfence_asid)) & (!g_w0[6]))))) begin
          valid_w0[6] <= 0;
        end
        if (valid_w1[6] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[6] == sfence_asid) & (!g_w1[6]))) : (sfasid0 ? ((lvl_w1[6] == 0) ? (vpn_w1[6] == sfvpn) : ((lvl_w1[6] == 1) ? (vpn_w1[6][26:9] == sfvpn[26:9]) : ((lvl_w1[6] == 2) ? (vpn_w1[6][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[6] == 0) ? (vpn_w1[6] == sfvpn) : ((lvl_w1[6] == 1) ? (vpn_w1[6][26:9] == sfvpn[26:9]) : ((lvl_w1[6] == 2) ? (vpn_w1[6][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[6] == sfence_asid)) & (!g_w1[6]))))) begin
          valid_w1[6] <= 0;
        end
        if (valid_w0[7] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[7] == sfence_asid) & (!g_w0[7]))) : (sfasid0 ? ((lvl_w0[7] == 0) ? (vpn_w0[7] == sfvpn) : ((lvl_w0[7] == 1) ? (vpn_w0[7][26:9] == sfvpn[26:9]) : ((lvl_w0[7] == 2) ? (vpn_w0[7][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[7] == 0) ? (vpn_w0[7] == sfvpn) : ((lvl_w0[7] == 1) ? (vpn_w0[7][26:9] == sfvpn[26:9]) : ((lvl_w0[7] == 2) ? (vpn_w0[7][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[7] == sfence_asid)) & (!g_w0[7]))))) begin
          valid_w0[7] <= 0;
        end
        if (valid_w1[7] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[7] == sfence_asid) & (!g_w1[7]))) : (sfasid0 ? ((lvl_w1[7] == 0) ? (vpn_w1[7] == sfvpn) : ((lvl_w1[7] == 1) ? (vpn_w1[7][26:9] == sfvpn[26:9]) : ((lvl_w1[7] == 2) ? (vpn_w1[7][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[7] == 0) ? (vpn_w1[7] == sfvpn) : ((lvl_w1[7] == 1) ? (vpn_w1[7][26:9] == sfvpn[26:9]) : ((lvl_w1[7] == 2) ? (vpn_w1[7][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[7] == sfence_asid)) & (!g_w1[7]))))) begin
          valid_w1[7] <= 0;
        end
        if (valid_w0[8] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[8] == sfence_asid) & (!g_w0[8]))) : (sfasid0 ? ((lvl_w0[8] == 0) ? (vpn_w0[8] == sfvpn) : ((lvl_w0[8] == 1) ? (vpn_w0[8][26:9] == sfvpn[26:9]) : ((lvl_w0[8] == 2) ? (vpn_w0[8][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[8] == 0) ? (vpn_w0[8] == sfvpn) : ((lvl_w0[8] == 1) ? (vpn_w0[8][26:9] == sfvpn[26:9]) : ((lvl_w0[8] == 2) ? (vpn_w0[8][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[8] == sfence_asid)) & (!g_w0[8]))))) begin
          valid_w0[8] <= 0;
        end
        if (valid_w1[8] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[8] == sfence_asid) & (!g_w1[8]))) : (sfasid0 ? ((lvl_w1[8] == 0) ? (vpn_w1[8] == sfvpn) : ((lvl_w1[8] == 1) ? (vpn_w1[8][26:9] == sfvpn[26:9]) : ((lvl_w1[8] == 2) ? (vpn_w1[8][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[8] == 0) ? (vpn_w1[8] == sfvpn) : ((lvl_w1[8] == 1) ? (vpn_w1[8][26:9] == sfvpn[26:9]) : ((lvl_w1[8] == 2) ? (vpn_w1[8][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[8] == sfence_asid)) & (!g_w1[8]))))) begin
          valid_w1[8] <= 0;
        end
        if (valid_w0[9] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[9] == sfence_asid) & (!g_w0[9]))) : (sfasid0 ? ((lvl_w0[9] == 0) ? (vpn_w0[9] == sfvpn) : ((lvl_w0[9] == 1) ? (vpn_w0[9][26:9] == sfvpn[26:9]) : ((lvl_w0[9] == 2) ? (vpn_w0[9][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[9] == 0) ? (vpn_w0[9] == sfvpn) : ((lvl_w0[9] == 1) ? (vpn_w0[9][26:9] == sfvpn[26:9]) : ((lvl_w0[9] == 2) ? (vpn_w0[9][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[9] == sfence_asid)) & (!g_w0[9]))))) begin
          valid_w0[9] <= 0;
        end
        if (valid_w1[9] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[9] == sfence_asid) & (!g_w1[9]))) : (sfasid0 ? ((lvl_w1[9] == 0) ? (vpn_w1[9] == sfvpn) : ((lvl_w1[9] == 1) ? (vpn_w1[9][26:9] == sfvpn[26:9]) : ((lvl_w1[9] == 2) ? (vpn_w1[9][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[9] == 0) ? (vpn_w1[9] == sfvpn) : ((lvl_w1[9] == 1) ? (vpn_w1[9][26:9] == sfvpn[26:9]) : ((lvl_w1[9] == 2) ? (vpn_w1[9][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[9] == sfence_asid)) & (!g_w1[9]))))) begin
          valid_w1[9] <= 0;
        end
        if (valid_w0[10] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[10] == sfence_asid) & (!g_w0[10]))) : (sfasid0 ? ((lvl_w0[10] == 0) ? (vpn_w0[10] == sfvpn) : ((lvl_w0[10] == 1) ? (vpn_w0[10][26:9] == sfvpn[26:9]) : ((lvl_w0[10] == 2) ? (vpn_w0[10][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[10] == 0) ? (vpn_w0[10] == sfvpn) : ((lvl_w0[10] == 1) ? (vpn_w0[10][26:9] == sfvpn[26:9]) : ((lvl_w0[10] == 2) ? (vpn_w0[10][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[10] == sfence_asid)) & (!g_w0[10]))))) begin
          valid_w0[10] <= 0;
        end
        if (valid_w1[10] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[10] == sfence_asid) & (!g_w1[10]))) : (sfasid0 ? ((lvl_w1[10] == 0) ? (vpn_w1[10] == sfvpn) : ((lvl_w1[10] == 1) ? (vpn_w1[10][26:9] == sfvpn[26:9]) : ((lvl_w1[10] == 2) ? (vpn_w1[10][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[10] == 0) ? (vpn_w1[10] == sfvpn) : ((lvl_w1[10] == 1) ? (vpn_w1[10][26:9] == sfvpn[26:9]) : ((lvl_w1[10] == 2) ? (vpn_w1[10][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[10] == sfence_asid)) & (!g_w1[10]))))) begin
          valid_w1[10] <= 0;
        end
        if (valid_w0[11] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[11] == sfence_asid) & (!g_w0[11]))) : (sfasid0 ? ((lvl_w0[11] == 0) ? (vpn_w0[11] == sfvpn) : ((lvl_w0[11] == 1) ? (vpn_w0[11][26:9] == sfvpn[26:9]) : ((lvl_w0[11] == 2) ? (vpn_w0[11][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[11] == 0) ? (vpn_w0[11] == sfvpn) : ((lvl_w0[11] == 1) ? (vpn_w0[11][26:9] == sfvpn[26:9]) : ((lvl_w0[11] == 2) ? (vpn_w0[11][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[11] == sfence_asid)) & (!g_w0[11]))))) begin
          valid_w0[11] <= 0;
        end
        if (valid_w1[11] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[11] == sfence_asid) & (!g_w1[11]))) : (sfasid0 ? ((lvl_w1[11] == 0) ? (vpn_w1[11] == sfvpn) : ((lvl_w1[11] == 1) ? (vpn_w1[11][26:9] == sfvpn[26:9]) : ((lvl_w1[11] == 2) ? (vpn_w1[11][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[11] == 0) ? (vpn_w1[11] == sfvpn) : ((lvl_w1[11] == 1) ? (vpn_w1[11][26:9] == sfvpn[26:9]) : ((lvl_w1[11] == 2) ? (vpn_w1[11][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[11] == sfence_asid)) & (!g_w1[11]))))) begin
          valid_w1[11] <= 0;
        end
        if (valid_w0[12] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[12] == sfence_asid) & (!g_w0[12]))) : (sfasid0 ? ((lvl_w0[12] == 0) ? (vpn_w0[12] == sfvpn) : ((lvl_w0[12] == 1) ? (vpn_w0[12][26:9] == sfvpn[26:9]) : ((lvl_w0[12] == 2) ? (vpn_w0[12][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[12] == 0) ? (vpn_w0[12] == sfvpn) : ((lvl_w0[12] == 1) ? (vpn_w0[12][26:9] == sfvpn[26:9]) : ((lvl_w0[12] == 2) ? (vpn_w0[12][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[12] == sfence_asid)) & (!g_w0[12]))))) begin
          valid_w0[12] <= 0;
        end
        if (valid_w1[12] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[12] == sfence_asid) & (!g_w1[12]))) : (sfasid0 ? ((lvl_w1[12] == 0) ? (vpn_w1[12] == sfvpn) : ((lvl_w1[12] == 1) ? (vpn_w1[12][26:9] == sfvpn[26:9]) : ((lvl_w1[12] == 2) ? (vpn_w1[12][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[12] == 0) ? (vpn_w1[12] == sfvpn) : ((lvl_w1[12] == 1) ? (vpn_w1[12][26:9] == sfvpn[26:9]) : ((lvl_w1[12] == 2) ? (vpn_w1[12][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[12] == sfence_asid)) & (!g_w1[12]))))) begin
          valid_w1[12] <= 0;
        end
        if (valid_w0[13] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[13] == sfence_asid) & (!g_w0[13]))) : (sfasid0 ? ((lvl_w0[13] == 0) ? (vpn_w0[13] == sfvpn) : ((lvl_w0[13] == 1) ? (vpn_w0[13][26:9] == sfvpn[26:9]) : ((lvl_w0[13] == 2) ? (vpn_w0[13][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[13] == 0) ? (vpn_w0[13] == sfvpn) : ((lvl_w0[13] == 1) ? (vpn_w0[13][26:9] == sfvpn[26:9]) : ((lvl_w0[13] == 2) ? (vpn_w0[13][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[13] == sfence_asid)) & (!g_w0[13]))))) begin
          valid_w0[13] <= 0;
        end
        if (valid_w1[13] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[13] == sfence_asid) & (!g_w1[13]))) : (sfasid0 ? ((lvl_w1[13] == 0) ? (vpn_w1[13] == sfvpn) : ((lvl_w1[13] == 1) ? (vpn_w1[13][26:9] == sfvpn[26:9]) : ((lvl_w1[13] == 2) ? (vpn_w1[13][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[13] == 0) ? (vpn_w1[13] == sfvpn) : ((lvl_w1[13] == 1) ? (vpn_w1[13][26:9] == sfvpn[26:9]) : ((lvl_w1[13] == 2) ? (vpn_w1[13][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[13] == sfence_asid)) & (!g_w1[13]))))) begin
          valid_w1[13] <= 0;
        end
        if (valid_w0[14] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[14] == sfence_asid) & (!g_w0[14]))) : (sfasid0 ? ((lvl_w0[14] == 0) ? (vpn_w0[14] == sfvpn) : ((lvl_w0[14] == 1) ? (vpn_w0[14][26:9] == sfvpn[26:9]) : ((lvl_w0[14] == 2) ? (vpn_w0[14][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[14] == 0) ? (vpn_w0[14] == sfvpn) : ((lvl_w0[14] == 1) ? (vpn_w0[14][26:9] == sfvpn[26:9]) : ((lvl_w0[14] == 2) ? (vpn_w0[14][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[14] == sfence_asid)) & (!g_w0[14]))))) begin
          valid_w0[14] <= 0;
        end
        if (valid_w1[14] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[14] == sfence_asid) & (!g_w1[14]))) : (sfasid0 ? ((lvl_w1[14] == 0) ? (vpn_w1[14] == sfvpn) : ((lvl_w1[14] == 1) ? (vpn_w1[14][26:9] == sfvpn[26:9]) : ((lvl_w1[14] == 2) ? (vpn_w1[14][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[14] == 0) ? (vpn_w1[14] == sfvpn) : ((lvl_w1[14] == 1) ? (vpn_w1[14][26:9] == sfvpn[26:9]) : ((lvl_w1[14] == 2) ? (vpn_w1[14][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[14] == sfence_asid)) & (!g_w1[14]))))) begin
          valid_w1[14] <= 0;
        end
        if (valid_w0[15] & (sfva0 ? (sfasid0 ? 1 : ((asid_w0[15] == sfence_asid) & (!g_w0[15]))) : (sfasid0 ? ((lvl_w0[15] == 0) ? (vpn_w0[15] == sfvpn) : ((lvl_w0[15] == 1) ? (vpn_w0[15][26:9] == sfvpn[26:9]) : ((lvl_w0[15] == 2) ? (vpn_w0[15][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w0[15] == 0) ? (vpn_w0[15] == sfvpn) : ((lvl_w0[15] == 1) ? (vpn_w0[15][26:9] == sfvpn[26:9]) : ((lvl_w0[15] == 2) ? (vpn_w0[15][26:18] == sfvpn[26:18]) : 0))) & (asid_w0[15] == sfence_asid)) & (!g_w0[15]))))) begin
          valid_w0[15] <= 0;
        end
        if (valid_w1[15] & (sfva0 ? (sfasid0 ? 1 : ((asid_w1[15] == sfence_asid) & (!g_w1[15]))) : (sfasid0 ? ((lvl_w1[15] == 0) ? (vpn_w1[15] == sfvpn) : ((lvl_w1[15] == 1) ? (vpn_w1[15][26:9] == sfvpn[26:9]) : ((lvl_w1[15] == 2) ? (vpn_w1[15][26:18] == sfvpn[26:18]) : 0))) : ((((lvl_w1[15] == 0) ? (vpn_w1[15] == sfvpn) : ((lvl_w1[15] == 1) ? (vpn_w1[15][26:9] == sfvpn[26:9]) : ((lvl_w1[15] == 2) ? (vpn_w1[15][26:18] == sfvpn[26:18]) : 0))) & (asid_w1[15] == sfence_asid)) & (!g_w1[15]))))) begin
          valid_w1[15] <= 0;
        end
      end
      if (fill_valid) begin
        if (fill_way == 0) begin
          vpn_w0[fill_idx] <= fill_va[38:12];
          ppn_w0[fill_idx] <= fill_ppn;
          perm_w0[fill_idx] <= fill_perm;
          asid_w0[fill_idx] <= fill_asid;
          g_w0[fill_idx] <= fill_g;
          lvl_w0[fill_idx] <= fill_level;
          valid_w0[fill_idx] <= 1;
        end else begin
          vpn_w1[fill_idx] <= fill_va[38:12];
          ppn_w1[fill_idx] <= fill_ppn;
          perm_w1[fill_idx] <= fill_perm;
          asid_w1[fill_idx] <= fill_asid;
          g_w1[fill_idx] <= fill_g;
          lvl_w1[fill_idx] <= fill_level;
          valid_w1[fill_idx] <= 1;
        end
        fill_way <= (!fill_way);
      end
      s1_valid <= req_valid;
      s1_va <= req_va;
      s1_id <= req_id;
      s1_is_write <= req_is_write;
      s1_w0_vpn <= r_w0_vpn;
      s1_w1_vpn <= r_w1_vpn;
      s1_w0_ppn <= r_w0_ppn;
      s1_w1_ppn <= r_w1_ppn;
      s1_w0_valid <= r_w0_valid;
      s1_w1_valid <= r_w1_valid;
      s1_w0_perm <= r_w0_perm;
      s1_w1_perm <= r_w1_perm;
      s1_w0_asid <= r_w0_asid;
      s1_w1_asid <= r_w1_asid;
      s1_w0_g <= r_w0_g;
      s1_w1_g <= r_w1_g;
      s1_w0_lvl <= r_w0_lvl;
      s1_w1_lvl <= r_w1_lvl;
    end
end

endmodule

module pwc (
  input clk,
  input rst,
  input [8:0] l2_lookup_vpn,
  input [17:0] l1_lookup_vpn,
  input l2_fill_valid,
  input [8:0] l2_fill_vpn,
  input [43:0] l2_fill_ppn,
  input l2_fill_g,
  input l1_fill_valid,
  input [17:0] l1_fill_vpn,
  input [43:0] l1_fill_ppn,
  input l1_fill_g,
  input flush,
  output l2_hit,
  output [43:0] l2_ppn,
  output l2_g,
  output l1_hit,
  output [43:0] l1_ppn,
  output l1_g
);

  reg [0:0] l2_valid [0:3];
  reg [8:0] l2_vpn_arr [0:3];
  reg [43:0] l2_ppn_arr [0:3];
  reg [0:0] l2_g_arr [0:3];
  reg [0:0] l1_valid [0:3];
  reg [17:0] l1_vpn_arr [0:3];
  reg [43:0] l1_ppn_arr [0:3];
  reg [0:0] l1_g_arr [0:3];
  reg [1:0] l2_rr;
  reg [1:0] l1_rr;
  wire [43:0] l2_ppn_sel;
  wire [43:0] l1_ppn_sel;
  reg [0:0] l2_m0_r;
  reg [0:0] l2_m1_r;
  reg [0:0] l2_m2_r;
  reg [0:0] l2_m3_r;
  reg [0:0] l1_m0_r;
  reg [0:0] l1_m1_r;
  reg [0:0] l1_m2_r;
  reg [0:0] l1_m3_r;
  wire [0:0] l2_m0;
  wire [0:0] l2_m1;
  wire [0:0] l2_m2;
  wire [0:0] l2_m3;
  wire [0:0] l1_m0;
  wire [0:0] l1_m1;
  wire [0:0] l1_m2;
  wire [0:0] l1_m3;
  assign l2_m0 = (l2_valid[0] & (l2_vpn_arr[0] == l2_lookup_vpn));
  assign l2_m1 = (l2_valid[1] & (l2_vpn_arr[1] == l2_lookup_vpn));
  assign l2_m2 = (l2_valid[2] & (l2_vpn_arr[2] == l2_lookup_vpn));
  assign l2_m3 = (l2_valid[3] & (l2_vpn_arr[3] == l2_lookup_vpn));
  assign l1_m0 = (l1_valid[0] & (l1_vpn_arr[0] == l1_lookup_vpn));
  assign l1_m1 = (l1_valid[1] & (l1_vpn_arr[1] == l1_lookup_vpn));
  assign l1_m2 = (l1_valid[2] & (l1_vpn_arr[2] == l1_lookup_vpn));
  assign l1_m3 = (l1_valid[3] & (l1_vpn_arr[3] == l1_lookup_vpn));
  assign l2_hit = (((l2_m0_r | l2_m1_r) | l2_m2_r) | l2_m3_r);
  assign l2_ppn_sel = (l2_m0_r ? l2_ppn_arr[0] : (l2_m1_r ? l2_ppn_arr[1] : (l2_m2_r ? l2_ppn_arr[2] : l2_ppn_arr[3])));
  assign l2_ppn = l2_ppn_sel;
  assign l2_g = (l2_m0_r ? l2_g_arr[0] : (l2_m1_r ? l2_g_arr[1] : (l2_m2_r ? l2_g_arr[2] : l2_g_arr[3])));
  assign l1_hit = (((l1_m0_r | l1_m1_r) | l1_m2_r) | l1_m3_r);
  assign l1_ppn_sel = (l1_m0_r ? l1_ppn_arr[0] : (l1_m1_r ? l1_ppn_arr[1] : (l1_m2_r ? l1_ppn_arr[2] : l1_ppn_arr[3])));
  assign l1_ppn = l1_ppn_sel;
  assign l1_g = (l1_m0_r ? l1_g_arr[0] : (l1_m1_r ? l1_g_arr[1] : (l1_m2_r ? l1_g_arr[2] : l1_g_arr[3])));

always @(posedge clk or posedge rst) begin
    if (rst) begin
      l2_rr <= {1'd0, 0};
      l1_rr <= {1'd0, 0};
      l2_valid[0] <= 0;
      l2_valid[1] <= 0;
      l2_valid[2] <= 0;
      l2_valid[3] <= 0;
      l1_valid[0] <= 0;
      l1_valid[1] <= 0;
      l1_valid[2] <= 0;
      l1_valid[3] <= 0;
    end else begin
      l2_m0_r <= l2_m0;
      l2_m1_r <= l2_m1;
      l2_m2_r <= l2_m2;
      l2_m3_r <= l2_m3;
      l1_m0_r <= l1_m0;
      l1_m1_r <= l1_m1;
      l1_m2_r <= l1_m2;
      l1_m3_r <= l1_m3;
      if (flush) begin
        l2_valid[0] <= 0;
        l2_valid[1] <= 0;
        l2_valid[2] <= 0;
        l2_valid[3] <= 0;
        l1_valid[0] <= 0;
        l1_valid[1] <= 0;
        l1_valid[2] <= 0;
        l1_valid[3] <= 0;
      end
      if (l2_fill_valid) begin
        l2_valid[l2_rr] <= 1;
        l2_vpn_arr[l2_rr] <= l2_fill_vpn;
        l2_ppn_arr[l2_rr] <= l2_fill_ppn;
        l2_g_arr[l2_rr] <= l2_fill_g;
        l2_rr <= ((l2_rr + 1) & 3);
      end
      if (l1_fill_valid) begin
        l1_valid[l1_rr] <= 1;
        l1_vpn_arr[l1_rr] <= l1_fill_vpn;
        l1_ppn_arr[l1_rr] <= l1_fill_ppn;
        l1_g_arr[l1_rr] <= l1_fill_g;
        l1_rr <= ((l1_rr + 1) & 3);
      end
    end
end

endmodule

module mmu_p170 (
  input mmu_clk,
  input mmu_rst,
  input [63:0] satp,
  input [1:0] priv,
  input mstatus_mxr,
  input mstatus_sum,
  input d_req_valid,
  input [63:0] d_req_va,
  input d_req_is_write,
  input [3:0] d_req_id,
  input i_req_valid,
  input [63:0] i_req_va,
  input [3:0] i_req_id,
  input ptw_req_ready,
  input ptw_resp_valid,
  input ptw_resp_error,
  input [63:0] ptw_resp_data,
  input sfence_valid,
  input [63:0] sfence_va,
  input [15:0] sfence_asid,
  output d_req_ready,
  output d_resp_valid,
  output [63:0] d_resp_pa,
  output d_resp_fault,
  output [3:0] d_resp_cause,
  output [3:0] d_resp_id,
  output [63:0] d_resp_tval,
  output i_req_ready,
  output i_resp_valid,
  output [63:0] i_resp_pa,
  output i_resp_fault,
  output [3:0] i_resp_cause,
  output [3:0] i_resp_id,
  output [63:0] i_resp_tval,
  output ptw_req_valid,
  output [63:0] ptw_req_addr,
  output ptw_req_we,
  output [63:0] ptw_req_wdata
);

  localparam ST_IDLE = 4'd0;
  localparam ST_L1_WAIT = 4'd1;
  localparam ST_PWC_L2_WAIT = 4'd2;
  localparam ST_WALK_L2 = 4'd3;
  localparam ST_PROCESS_L2 = 4'd4;
  localparam ST_PWC_L1_WAIT = 4'd5;
  localparam ST_WALK_L1 = 4'd6;
  localparam ST_PROCESS_L1 = 4'd7;
  localparam ST_WALK_L0 = 4'd8;
  localparam ST_PROCESS_L0 = 4'd9;

  wire [43:0] _tmp_w0;
  assign _tmp_w0 = satp[43:0];
  wire [8:0] _tmp_w1;
  assign _tmp_w1 = fsm_va[38:30];
  wire [8:0] _tmp_w2;
  assign _tmp_w2 = fsm_va[29:21];
  wire [8:0] _tmp_w3;
  assign _tmp_w3 = fsm_va[20:12];
  wire [11:0] _tmp_w4;
  assign _tmp_w4 = fsm_va[11:0];
  wire [11:0] _tmp_w5;
  assign _tmp_w5 = fsm_va[11:0];
  wire [11:0] _tmp_w6;
  assign _tmp_w6 = fsm_va[11:0];
  wire [11:0] _tmp_w7;
  assign _tmp_w7 = fsm_va[11:0];
  wire [55:0] _tmp_w8;
  assign _tmp_w8 = {pte_ppn, fsm_va[11:0]};
  wire [55:0] _tmp_w9;
  assign _tmp_w9 = {pte_ppn, fsm_va[11:0]};
  reg [3:0] state;
  reg [63:0] fsm_va;
  reg [0:0] fsm_is_write;
  reg [3:0] fsm_id;
  reg [0:0] fsm_is_i;
  reg [0:0] fsm_fetch;
  reg [43:0] fsm_ppn2;
  reg [43:0] fsm_ppn1;
  reg [0:0] fsm_g2;
  reg [0:0] fsm_g1;
  reg [63:0] fsm_pte;
  reg [1:0] fsm_level;
  wire [0:0] l0_d_hit;
  wire [63:0] l0_d_pa;
  wire [0:0] l0_d_fault;
  wire [3:0] l0_d_cause;
  wire [0:0] l0_i_hit;
  wire [63:0] l0_i_pa;
  wire [0:0] l0_i_fault;
  wire [3:0] l0_i_cause;
  wire [0:0] l1_d_resp_valid;
  wire [63:0] l1_d_resp_pa;
  wire [0:0] l1_d_resp_fault;
  wire [3:0] l1_d_resp_cause;
  wire [3:0] l1_d_resp_id;
  wire [63:0] l1_d_resp_tval;
  wire [0:0] l1_d_hit;
  wire [0:0] l1_i_resp_valid;
  wire [63:0] l1_i_resp_pa;
  wire [0:0] l1_i_resp_fault;
  wire [3:0] l1_i_resp_cause;
  wire [3:0] l1_i_resp_id;
  wire [63:0] l1_i_resp_tval;
  wire [0:0] l1_i_hit;
  reg [0:0] d_l1_req;
  reg [0:0] i_l1_req;
  wire [0:0] pwc_l2_hit;
  wire [43:0] pwc_l2_ppn;
  wire [0:0] pwc_l2_g;
  wire [0:0] pwc_l1_hit;
  wire [43:0] pwc_l1_ppn;
  wire [0:0] pwc_l1_g;
  wire [0:0] pwc_l2_fill_valid;
  wire [8:0] pwc_l2_fill_vpn;
  wire [43:0] pwc_l2_fill_ppn;
  wire [0:0] pwc_l2_fill_g;
  wire [0:0] pwc_l1_fill_valid;
  wire [17:0] pwc_l1_fill_vpn;
  wire [43:0] pwc_l1_fill_ppn;
  wire [0:0] pwc_l1_fill_g;
  wire [0:0] fill_valid;
  wire [63:0] fill_va;
  wire [43:0] fill_ppn;
  wire [4:0] fill_perm;
  wire [15:0] fill_asid;
  wire [0:0] fill_g;
  wire [1:0] fill_level;
  wire [0:0] m_mode;
  wire [0:0] va_canonical;
  wire [0:0] satp_enabled;
  wire [0:0] bypass;
  wire [0:0] pte_v;
  wire [0:0] pte_r;
  wire [0:0] pte_w;
  wire [0:0] pte_x;
  wire [0:0] pte_a;
  wire [0:0] pte_d;
  wire [0:0] pte_g;
  wire [0:0] pte_leaf;
  wire [0:0] pte_bad_w;
  wire [0:0] pte_rsvd;
  wire [0:0] pte_ad_ok;
  wire [0:0] pte_fault;
  wire [0:0] superpage_ok;
  wire [63:0] walk_l2_addr;
  wire [63:0] walk_l1_addr;
  wire [63:0] walk_l0_addr;
  wire [63:0] walk_cur_addr;
  wire [8:0] va_vpn0;
  wire [8:0] va_vpn1;
  wire [43:0] pte_ppn;
  wire [43:0] pa_l2_ppn;
  wire [43:0] pa_l1_ppn;
  wire [0:0] align_ok_l1;
  wire [0:0] align_ok_l2;
  wire [0:0] pte_r_bit;
  wire [0:0] pte_w_bit;
  wire [0:0] pte_x_bit;
  wire [0:0] pte_u_bit;
  wire [0:0] perm_ok_full;
  reg [0:0] d_req_ready_reg;
  reg [0:0] d_resp_valid_reg;
  reg [63:0] d_resp_pa_reg;
  reg [0:0] d_resp_fault_reg;
  reg [3:0] d_resp_cause_reg;
  reg [3:0] d_resp_id_reg;
  reg [63:0] d_resp_tval_reg;
  reg [0:0] i_req_ready_reg;
  reg [0:0] i_resp_valid_reg;
  reg [63:0] i_resp_pa_reg;
  reg [0:0] i_resp_fault_reg;
  reg [3:0] i_resp_cause_reg;
  reg [3:0] i_resp_id_reg;
  reg [63:0] i_resp_tval_reg;
  wire [0:0] l1_resp_v;
  wire [63:0] l1_resp_pa;
  wire [0:0] l1_resp_f;
  wire [3:0] l1_resp_c;
  wire [3:0] l1_resp_id;
  wire [63:0] l1_resp_tv;
  wire [0:0] l1_hit_sel;
  reg [63:0] ptw_resp_data_r;
  reg [0:0] ptw_resp_error_r;
  (* keep *) wire [63:0] fsm_va_r0;
  (* keep *) wire [63:0] fsm_va_r1;
  (* keep *) wire [63:0] fsm_va_r2;
  (* keep *) wire [63:0] fsm_va_r3;
  (* keep *) wire [63:0] fsm_va_r4;
  (* keep *) wire [63:0] fsm_va_r5;
  wire [0:0] d_va_bit38;
  wire [24:0] d_va_upper;
  wire [0:0] i_va_bit38;
  wire [24:0] i_va_upper;
  wire [0:0] d_va_canon;
  wire [0:0] i_va_canon;
  wire [25:0] pte_ppn_hi_l2;
  wire [34:0] pte_ppn_hi_l1;
  wire [0:0] priv_ok_int;
  wire [0:0] rwx_ok_int;
  wire [0:0] sp_l1_ok;
  wire [0:0] sp_l2_ok;
  assign fsm_va_r0 = fsm_va;
  assign fsm_va_r1 = fsm_va;
  assign fsm_va_r2 = fsm_va;
  assign fsm_va_r3 = fsm_va;
  assign fsm_va_r4 = fsm_va;
  assign fsm_va_r5 = fsm_va;
  assign m_mode = (priv == 3);
  assign satp_enabled = (satp[63:60] == 8);
  assign bypass = (m_mode | (!satp_enabled));
  assign d_va_bit38 = d_req_va[38];
  assign d_va_upper = d_req_va[63:39];
  assign i_va_bit38 = i_req_va[38];
  assign i_va_upper = i_req_va[63:39];
  assign d_va_canon = (d_va_bit38 ? (d_va_upper == 33554431) : (d_va_upper == 0));
  assign i_va_canon = (i_va_bit38 ? (i_va_upper == 33554431) : (i_va_upper == 0));
  assign walk_l2_addr = (({{20{1'b0}}, _tmp_w0} << 12) | ({{55{1'b0}}, _tmp_w1} << 3));
  assign walk_l1_addr = (({{20{1'b0}}, fsm_ppn2} << 12) | ({{55{1'b0}}, _tmp_w2} << 3));
  assign walk_l0_addr = (({{20{1'b0}}, fsm_ppn1} << 12) | ({{55{1'b0}}, _tmp_w3} << 3));
  assign walk_cur_addr = ((state == ST_WALK_L2) ? walk_l2_addr : ((state == ST_WALK_L1) ? walk_l1_addr : walk_l0_addr));
  assign va_vpn0 = fsm_va[20:12];
  assign va_vpn1 = fsm_va[29:21];
  assign pte_ppn = ptw_resp_data[53:10];
  assign pte_ppn_hi_l2 = ptw_resp_data[53:28];
  assign pa_l2_ppn = {pte_ppn_hi_l2, va_vpn1, va_vpn0};
  assign pte_ppn_hi_l1 = ptw_resp_data[53:19];
  assign pa_l1_ppn = {pte_ppn_hi_l1, va_vpn0};
  assign align_ok_l2 = (ptw_resp_data[27:10] == 0);
  assign align_ok_l1 = (ptw_resp_data[18:10] == 0);
  assign pte_r_bit = ptw_resp_data[1];
  assign pte_w_bit = ptw_resp_data[2];
  assign pte_x_bit = ptw_resp_data[3];
  assign pte_u_bit = ptw_resp_data[4];
  assign priv_ok_int = ((priv == 0) ? pte_u_bit : ((priv == 1) ? (pte_u_bit ? (fsm_fetch ? 0 : mstatus_sum) : 1) : ((priv == 3) ? 1 : 0)));
  assign rwx_ok_int = (fsm_fetch ? pte_x_bit : (fsm_is_write ? pte_w_bit : (pte_r_bit ? 1 : (mstatus_mxr ? pte_x_bit : 0))));
  assign perm_ok_full = (priv_ok_int & rwx_ok_int);
  assign pwc_l2_fill_valid = (((((state == ST_PROCESS_L2) & (!ptw_resp_error)) & ptw_resp_data[0]) & (!ptw_resp_data[7])) & (ptw_resp_data[3:1] == 0));
  assign pwc_l2_fill_vpn = fsm_va[38:30];
  assign pwc_l2_fill_ppn = ptw_resp_data[53:10];
  assign pwc_l2_fill_g = ptw_resp_data[5];
  assign pwc_l1_fill_valid = (((((state == ST_PROCESS_L1) & (!ptw_resp_error)) & ptw_resp_data[0]) & (!ptw_resp_data[7])) & (ptw_resp_data[3:1] == 0));
  assign pwc_l1_fill_vpn = fsm_va[38:21];
  assign pwc_l1_fill_ppn = ptw_resp_data[53:10];
  assign pwc_l1_fill_g = (fsm_g2 | ptw_resp_data[5]);
  assign fill_valid = (((((((((((state == ST_PROCESS_L2) & (!ptw_resp_error)) & pte_leaf) & align_ok_l2) & pte_v) & (!pte_rsvd)) & (!pte_bad_w)) & pte_ad_ok) & perm_ok_full) | (((((((((state == ST_PROCESS_L1) & (!ptw_resp_error)) & pte_leaf) & align_ok_l1) & pte_v) & (!pte_rsvd)) & (!pte_bad_w)) & pte_ad_ok) & perm_ok_full)) | ((((((((state == ST_PROCESS_L0) & (!ptw_resp_error)) & pte_leaf) & pte_v) & (!pte_rsvd)) & (!pte_bad_w)) & pte_ad_ok) & perm_ok_full));
  assign fill_va = fsm_va;
  assign fill_ppn = pte_ppn;
  assign fill_perm = ptw_resp_data[5:1];
  assign fill_asid = satp[59:44];
  assign fill_g = ((state == ST_WALK_L2) ? ptw_resp_data[5] : ((state == ST_WALK_L1) ? (fsm_g2 | ptw_resp_data[5]) : ((fsm_g2 | fsm_g1) | ptw_resp_data[5])));
  assign fill_level = ((state == ST_WALK_L2) ? 2 : ((state == ST_WALK_L1) ? 1 : 0));
  assign pte_v = ptw_resp_data[0];
  assign pte_r = ptw_resp_data[1];
  assign pte_w = ptw_resp_data[2];
  assign pte_x = ptw_resp_data[3];
  assign pte_g = ptw_resp_data[5];
  assign pte_a = ptw_resp_data[6];
  assign pte_d = ptw_resp_data[7];
  assign pte_leaf = (pte_r | pte_x);
  assign pte_bad_w = ((!pte_r) & pte_w);
  assign pte_rsvd = (ptw_resp_data[63:54] != 0);
  assign pte_ad_ok = (pte_a & (fsm_is_write ? pte_d : 1));
  assign sp_l1_ok = ((fsm_level == 1) ? (ptw_resp_data[18:10] == 0) : 1);
  assign sp_l2_ok = ((fsm_level == 2) ? (ptw_resp_data[27:10] == 0) : 1);
  assign superpage_ok = (sp_l1_ok & sp_l2_ok);
  assign pte_fault = (((((((!pte_v) | pte_rsvd) | pte_bad_w) | (!pte_leaf)) | (!pte_ad_ok)) | (!superpage_ok)) | (!perm_ok_full));
  assign l1_resp_v = (fsm_is_i ? l1_i_resp_valid : l1_d_resp_valid);
  assign l1_resp_pa = (fsm_is_i ? l1_i_resp_pa : l1_d_resp_pa);
  assign l1_resp_f = (fsm_is_i ? l1_i_resp_fault : l1_d_resp_fault);
  assign l1_resp_c = (fsm_is_i ? l1_i_resp_cause : l1_d_resp_cause);
  assign l1_resp_id = (fsm_is_i ? l1_i_resp_id : l1_d_resp_id);
  assign l1_resp_tv = (fsm_is_i ? l1_i_resp_tval : l1_d_resp_tval);
  assign l1_hit_sel = (fsm_is_i ? l1_i_hit : l1_d_hit);
  assign d_req_ready = d_req_ready_reg;
  assign d_resp_valid = d_resp_valid_reg;
  assign d_resp_pa = d_resp_pa_reg;
  assign d_resp_fault = d_resp_fault_reg;
  assign d_resp_cause = d_resp_cause_reg;
  assign d_resp_id = d_resp_id_reg;
  assign d_resp_tval = d_resp_tval_reg;
  assign i_req_ready = i_req_ready_reg;
  assign i_resp_valid = i_resp_valid_reg;
  assign i_resp_pa = i_resp_pa_reg;
  assign i_resp_fault = i_resp_fault_reg;
  assign i_resp_cause = i_resp_cause_reg;
  assign i_resp_id = i_resp_id_reg;
  assign i_resp_tval = i_resp_tval_reg;
  assign ptw_req_valid = (((state == ST_WALK_L2) | (state == ST_WALK_L1)) | (state == ST_WALK_L0));
  assign ptw_req_addr = walk_cur_addr;
  assign ptw_req_we = 0;
  assign ptw_req_wdata = {63'd0, 0};
  pwc u_pwc (
    .clk(mmu_clk),
    .rst(mmu_rst),
    .l2_lookup_vpn(fsm_va[38:30]),
    .l1_lookup_vpn(fsm_va[38:21]),
    .l2_fill_valid(pwc_l2_fill_valid),
    .l2_fill_vpn(pwc_l2_fill_vpn),
    .l2_fill_ppn(pwc_l2_fill_ppn),
    .l2_fill_g(pwc_l2_fill_g),
    .l1_fill_valid(pwc_l1_fill_valid),
    .l1_fill_vpn(pwc_l1_fill_vpn),
    .l1_fill_ppn(pwc_l1_fill_ppn),
    .l1_fill_g(pwc_l1_fill_g),
    .flush(((sfence_valid & (sfence_va == 0)) & (sfence_asid == 0))),
    .l2_hit(pwc_l2_hit),
    .l2_ppn(pwc_l2_ppn),
    .l2_g(pwc_l2_g),
    .l1_hit(pwc_l1_hit),
    .l1_ppn(pwc_l1_ppn),
    .l1_g(pwc_l1_g)
  );
  l0_tlb l0_d (
    .clk(mmu_clk),
    .rst(mmu_rst),
    .req_valid(d_req_valid),
    .req_va(d_req_va),
    .req_is_write(d_req_is_write),
    .req_is_fetch(0),
    .satp(satp),
    .priv(priv),
    .mstatus_mxr(mstatus_mxr),
    .mstatus_sum(mstatus_sum),
    .fill_valid((fill_valid & (!fsm_is_i))),
    .fill_va(fsm_va_r2),
    .fill_ppn(fill_ppn),
    .fill_perm(fill_perm),
    .fill_asid(fill_asid),
    .fill_g(fill_g),
    .fill_level(fill_level),
    .sfence_valid(sfence_valid),
    .sfence_va(sfence_va),
    .sfence_asid(sfence_asid),
    .hit(l0_d_hit),
    .pa(l0_d_pa),
    .fault(l0_d_fault),
    .cause(l0_d_cause)
  );
  l0_tlb l0_i (
    .clk(mmu_clk),
    .rst(mmu_rst),
    .req_valid(i_req_valid),
    .req_va(i_req_va),
    .req_is_write(0),
    .req_is_fetch(1),
    .satp(satp),
    .priv(priv),
    .mstatus_mxr(mstatus_mxr),
    .mstatus_sum(mstatus_sum),
    .fill_valid((fill_valid & fsm_is_i)),
    .fill_va(fsm_va_r3),
    .fill_ppn(fill_ppn),
    .fill_perm(fill_perm),
    .fill_asid(fill_asid),
    .fill_g(fill_g),
    .fill_level(fill_level),
    .sfence_valid(sfence_valid),
    .sfence_va(sfence_va),
    .sfence_asid(sfence_asid),
    .hit(l0_i_hit),
    .pa(l0_i_pa),
    .fault(l0_i_fault),
    .cause(l0_i_cause)
  );
  l1_tlb l1_d (
    .clk(mmu_clk),
    .rst(mmu_rst),
    .req_valid(d_l1_req),
    .req_va(fsm_va_r0),
    .req_is_write(fsm_is_write),
    .req_is_fetch(0),
    .req_id(fsm_id),
    .satp(satp),
    .priv(priv),
    .mstatus_mxr(mstatus_mxr),
    .mstatus_sum(mstatus_sum),
    .fill_valid((fill_valid & (!fsm_is_i))),
    .fill_va(fsm_va_r4),
    .fill_ppn(fill_ppn),
    .fill_perm(fill_perm),
    .fill_asid(fill_asid),
    .fill_g(fill_g),
    .fill_level(fill_level),
    .sfence_valid(sfence_valid),
    .sfence_va(sfence_va),
    .sfence_asid(sfence_asid),
    .resp_valid(l1_d_resp_valid),
    .resp_pa(l1_d_resp_pa),
    .resp_fault(l1_d_resp_fault),
    .resp_cause(l1_d_resp_cause),
    .resp_id(l1_d_resp_id),
    .resp_tval(l1_d_resp_tval),
    .hit(l1_d_hit)
  );
  l1_tlb l1_i (
    .clk(mmu_clk),
    .rst(mmu_rst),
    .req_valid(i_l1_req),
    .req_va(fsm_va_r1),
    .req_is_write(0),
    .req_is_fetch(1),
    .req_id(fsm_id),
    .satp(satp),
    .priv(priv),
    .mstatus_mxr(mstatus_mxr),
    .mstatus_sum(mstatus_sum),
    .fill_valid((fill_valid & fsm_is_i)),
    .fill_va(fsm_va_r5),
    .fill_ppn(fill_ppn),
    .fill_perm(fill_perm),
    .fill_asid(fill_asid),
    .fill_g(fill_g),
    .fill_level(fill_level),
    .sfence_valid(sfence_valid),
    .sfence_va(sfence_va),
    .sfence_asid(sfence_asid),
    .resp_valid(l1_i_resp_valid),
    .resp_pa(l1_i_resp_pa),
    .resp_fault(l1_i_resp_fault),
    .resp_cause(l1_i_resp_cause),
    .resp_id(l1_i_resp_id),
    .resp_tval(l1_i_resp_tval),
    .hit(l1_i_hit)
  );

always @(posedge mmu_clk or posedge mmu_rst) begin
    if (mmu_rst) begin
      state <= ST_IDLE;
      d_req_ready_reg <= 1;
      i_req_ready_reg <= 1;
      d_resp_valid_reg <= 0;
      i_resp_valid_reg <= 0;
      d_l1_req <= 0;
      i_l1_req <= 0;
      fsm_is_i <= 0;
      fsm_fetch <= 0;
    end else begin
      d_resp_valid_reg <= 0;
      i_resp_valid_reg <= 0;
      d_l1_req <= 0;
      i_l1_req <= 0;
      case (state)
        ST_IDLE: begin
          d_req_ready_reg <= 1;
          i_req_ready_reg <= 1;
          if (bypass) begin
            if (d_req_valid) begin
              d_resp_valid_reg <= 1;
              d_resp_pa_reg <= d_req_va;
              d_resp_fault_reg <= 0;
              d_resp_cause_reg <= {3'd0, 0};
              d_resp_id_reg <= d_req_id;
              d_resp_tval_reg <= {63'd0, 0};
            end
            if (i_req_valid) begin
              i_resp_valid_reg <= 1;
              i_resp_pa_reg <= i_req_va;
              i_resp_fault_reg <= 0;
              i_resp_cause_reg <= {3'd0, 0};
              i_resp_id_reg <= i_req_id;
              i_resp_tval_reg <= {63'd0, 0};
            end
          end else if (d_req_valid) begin
            if ((!d_va_canon) & (!bypass)) begin
              d_resp_valid_reg <= 1;
              d_resp_pa_reg <= {63'd0, 0};
              d_resp_fault_reg <= 1;
              d_resp_cause_reg <= (d_req_is_write ? 15 : 13);
              d_resp_id_reg <= d_req_id;
              d_resp_tval_reg <= d_req_va;
            end else if (l0_d_hit) begin
              d_resp_valid_reg <= 1;
              d_resp_pa_reg <= l0_d_pa;
              d_resp_fault_reg <= l0_d_fault;
              d_resp_cause_reg <= l0_d_cause;
              d_resp_id_reg <= d_req_id;
              d_resp_tval_reg <= (l0_d_fault ? d_req_va : 0);
            end else begin
              fsm_va <= d_req_va;
              fsm_is_write <= d_req_is_write;
              fsm_id <= d_req_id;
              fsm_is_i <= 0;
              fsm_fetch <= 0;
              d_l1_req <= 1;
              state <= ST_L1_WAIT;
            end
          end else if (i_req_valid) begin
            if ((!i_va_canon) & (!bypass)) begin
              i_resp_valid_reg <= 1;
              i_resp_pa_reg <= {63'd0, 0};
              i_resp_fault_reg <= 1;
              i_resp_cause_reg <= 12;
              i_resp_id_reg <= i_req_id;
              i_resp_tval_reg <= i_req_va;
            end else if (l0_i_hit) begin
              i_resp_valid_reg <= 1;
              i_resp_pa_reg <= l0_i_pa;
              i_resp_fault_reg <= l0_i_fault;
              i_resp_cause_reg <= l0_i_cause;
              i_resp_id_reg <= i_req_id;
              i_resp_tval_reg <= (l0_i_fault ? i_req_va : 0);
            end else begin
              fsm_va <= i_req_va;
              fsm_is_write <= 0;
              fsm_id <= i_req_id;
              fsm_is_i <= 1;
              fsm_fetch <= 1;
              i_l1_req <= 1;
              state <= ST_L1_WAIT;
            end
          end
        end
        ST_L1_WAIT: begin
          d_req_ready_reg <= 0;
          i_req_ready_reg <= 0;
          if (l1_resp_v) begin
            if (l1_hit_sel) begin
              d_resp_valid_reg <= (!fsm_is_i);
              i_resp_valid_reg <= fsm_is_i;
              d_resp_pa_reg <= l1_resp_pa;
              i_resp_pa_reg <= l1_resp_pa;
              d_resp_fault_reg <= ((!fsm_is_i) & l1_resp_f);
              i_resp_fault_reg <= (fsm_is_i & l1_resp_f);
              d_resp_cause_reg <= l1_resp_c;
              i_resp_cause_reg <= l1_resp_c;
              d_resp_id_reg <= l1_resp_id;
              i_resp_id_reg <= l1_resp_id;
              d_resp_tval_reg <= ((!fsm_is_i) & l1_resp_tv);
              i_resp_tval_reg <= (fsm_is_i & l1_resp_tv);
              state <= ST_IDLE;
            end else begin
              state <= ST_PWC_L2_WAIT;
            end
          end
        end
        ST_PWC_L2_WAIT: begin
          state <= ST_WALK_L2;
        end
        ST_WALK_L2: begin
          if (pwc_l2_hit) begin
            fsm_ppn2 <= pwc_l2_ppn;
            fsm_g2 <= pwc_l2_g;
            state <= ST_PWC_L1_WAIT;
          end else begin
            if (ptw_resp_valid) begin
              ptw_resp_data_r <= ptw_resp_data;
              ptw_resp_error_r <= ptw_resp_error;
              state <= ST_PROCESS_L2;
            end
          end
        end
        ST_PROCESS_L2: begin
          fsm_pte <= ptw_resp_data_r;
          if (ptw_resp_error_r) begin
            d_resp_valid_reg <= (!fsm_is_i);
            i_resp_valid_reg <= fsm_is_i;
            d_resp_fault_reg <= (!fsm_is_i);
            i_resp_fault_reg <= fsm_is_i;
            d_resp_cause_reg <= {1'd0, (fsm_fetch ? 1 : (fsm_is_write ? 7 : 5))};
            i_resp_cause_reg <= {1'd0, (fsm_fetch ? 1 : (fsm_is_write ? 7 : 5))};
            d_resp_tval_reg <= ((!fsm_is_i) & fsm_va);
            i_resp_tval_reg <= (fsm_is_i & fsm_va);
            state <= ST_IDLE;
          end else if (((!pte_v) | pte_rsvd) | pte_bad_w) begin
            d_resp_valid_reg <= (!fsm_is_i);
            i_resp_valid_reg <= fsm_is_i;
            d_resp_fault_reg <= (!fsm_is_i);
            i_resp_fault_reg <= fsm_is_i;
            d_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
            i_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
            d_resp_tval_reg <= ((!fsm_is_i) & fsm_va);
            i_resp_tval_reg <= (fsm_is_i & fsm_va);
            state <= ST_IDLE;
          end else if (pte_leaf) begin
            if (((!align_ok_l2) | (!pte_ad_ok)) | (!perm_ok_full)) begin
              d_resp_valid_reg <= (!fsm_is_i);
              i_resp_valid_reg <= fsm_is_i;
              d_resp_fault_reg <= (!fsm_is_i);
              i_resp_fault_reg <= fsm_is_i;
              d_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
              i_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
              d_resp_tval_reg <= ((!fsm_is_i) & fsm_va);
              i_resp_tval_reg <= (fsm_is_i & fsm_va);
              state <= ST_IDLE;
            end else begin
              d_resp_valid_reg <= (!fsm_is_i);
              i_resp_valid_reg <= fsm_is_i;
              d_resp_pa_reg <= (({{20{1'b0}}, pa_l2_ppn} << 12) | {{52{1'b0}}, _tmp_w4});
              i_resp_pa_reg <= (({{20{1'b0}}, pa_l2_ppn} << 12) | {{52{1'b0}}, _tmp_w5});
              d_resp_fault_reg <= 0;
              i_resp_fault_reg <= 0;
              d_resp_cause_reg <= {3'd0, 0};
              i_resp_cause_reg <= {3'd0, 0};
              d_resp_id_reg <= fsm_id;
              i_resp_id_reg <= fsm_id;
              d_resp_tval_reg <= {63'd0, 0};
              i_resp_tval_reg <= {63'd0, 0};
              state <= ST_IDLE;
            end
          end else begin
            fsm_ppn2 <= pte_ppn;
            fsm_g2 <= ptw_resp_data_r[5];
            state <= ST_PWC_L1_WAIT;
          end
        end
        ST_PWC_L1_WAIT: begin
          state <= ST_WALK_L1;
        end
        ST_WALK_L1: begin
          if (pwc_l1_hit) begin
            fsm_ppn1 <= pwc_l1_ppn;
            fsm_g1 <= pwc_l1_g;
            state <= ST_WALK_L0;
          end else begin
            if (ptw_resp_valid) begin
              ptw_resp_data_r <= ptw_resp_data;
              ptw_resp_error_r <= ptw_resp_error;
              state <= ST_PROCESS_L1;
            end
          end
        end
        ST_PROCESS_L1: begin
          fsm_pte <= ptw_resp_data_r;
          if (ptw_resp_error_r) begin
            d_resp_valid_reg <= (!fsm_is_i);
            i_resp_valid_reg <= fsm_is_i;
            d_resp_fault_reg <= (!fsm_is_i);
            i_resp_fault_reg <= fsm_is_i;
            d_resp_cause_reg <= {1'd0, (fsm_fetch ? 1 : (fsm_is_write ? 7 : 5))};
            i_resp_cause_reg <= {1'd0, (fsm_fetch ? 1 : (fsm_is_write ? 7 : 5))};
            d_resp_tval_reg <= ((!fsm_is_i) & fsm_va);
            i_resp_tval_reg <= (fsm_is_i & fsm_va);
            state <= ST_IDLE;
          end else if (((!pte_v) | pte_rsvd) | pte_bad_w) begin
            d_resp_valid_reg <= (!fsm_is_i);
            i_resp_valid_reg <= fsm_is_i;
            d_resp_fault_reg <= (!fsm_is_i);
            i_resp_fault_reg <= fsm_is_i;
            d_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
            i_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
            d_resp_tval_reg <= ((!fsm_is_i) & fsm_va);
            i_resp_tval_reg <= (fsm_is_i & fsm_va);
            state <= ST_IDLE;
          end else if (pte_leaf) begin
            if (((!align_ok_l1) | (!pte_ad_ok)) | (!perm_ok_full)) begin
              d_resp_valid_reg <= (!fsm_is_i);
              i_resp_valid_reg <= fsm_is_i;
              d_resp_fault_reg <= (!fsm_is_i);
              i_resp_fault_reg <= fsm_is_i;
              d_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
              i_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
              d_resp_tval_reg <= ((!fsm_is_i) & fsm_va);
              i_resp_tval_reg <= (fsm_is_i & fsm_va);
              state <= ST_IDLE;
            end else begin
              d_resp_valid_reg <= (!fsm_is_i);
              i_resp_valid_reg <= fsm_is_i;
              d_resp_pa_reg <= (({{20{1'b0}}, pa_l1_ppn} << 12) | {{52{1'b0}}, _tmp_w6});
              i_resp_pa_reg <= (({{20{1'b0}}, pa_l1_ppn} << 12) | {{52{1'b0}}, _tmp_w7});
              d_resp_fault_reg <= 0;
              i_resp_fault_reg <= 0;
              d_resp_cause_reg <= {3'd0, 0};
              i_resp_cause_reg <= {3'd0, 0};
              d_resp_id_reg <= fsm_id;
              i_resp_id_reg <= fsm_id;
              d_resp_tval_reg <= {63'd0, 0};
              i_resp_tval_reg <= {63'd0, 0};
              state <= ST_IDLE;
            end
          end else begin
            fsm_ppn1 <= pte_ppn;
            fsm_g1 <= (fsm_g2 | ptw_resp_data_r[5]);
            state <= ST_WALK_L0;
          end
        end
        ST_WALK_L0: begin
          d_req_ready_reg <= 0;
          i_req_ready_reg <= 0;
          if (ptw_resp_valid) begin
            ptw_resp_data_r <= ptw_resp_data;
            ptw_resp_error_r <= ptw_resp_error;
            state <= ST_PROCESS_L0;
          end
        end
        ST_PROCESS_L0: begin
          d_req_ready_reg <= 0;
          i_req_ready_reg <= 0;
          fsm_pte <= ptw_resp_data_r;
          fsm_level <= {1'd0, 0};
          if (ptw_resp_error_r) begin
            d_resp_valid_reg <= (!fsm_is_i);
            i_resp_valid_reg <= fsm_is_i;
            d_resp_fault_reg <= (!fsm_is_i);
            i_resp_fault_reg <= fsm_is_i;
            d_resp_cause_reg <= {1'd0, (fsm_is_write ? 7 : 5)};
            i_resp_cause_reg <= {3'd0, 1};
            d_resp_tval_reg <= ((!fsm_is_i) & fsm_va);
            i_resp_tval_reg <= (fsm_is_i & fsm_va);
            state <= ST_IDLE;
          end else if (pte_fault) begin
            d_resp_valid_reg <= (!fsm_is_i);
            i_resp_valid_reg <= fsm_is_i;
            d_resp_fault_reg <= (!fsm_is_i);
            i_resp_fault_reg <= fsm_is_i;
            d_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
            i_resp_cause_reg <= (fsm_fetch ? 12 : (fsm_is_write ? 15 : 13));
            d_resp_tval_reg <= ((!fsm_is_i) & fsm_va);
            i_resp_tval_reg <= (fsm_is_i & fsm_va);
            state <= ST_IDLE;
          end else begin
            d_resp_valid_reg <= (!fsm_is_i);
            i_resp_valid_reg <= fsm_is_i;
            d_resp_pa_reg <= {{8{1'b0}}, _tmp_w8};
            i_resp_pa_reg <= {{8{1'b0}}, _tmp_w9};
            d_resp_fault_reg <= 0;
            i_resp_fault_reg <= 0;
            d_resp_cause_reg <= {3'd0, 0};
            i_resp_cause_reg <= {3'd0, 0};
            d_resp_id_reg <= fsm_id;
            i_resp_id_reg <= fsm_id;
            d_resp_tval_reg <= {63'd0, 0};
            i_resp_tval_reg <= {63'd0, 0};
            state <= ST_IDLE;
          end
        end
        default: begin
          state <= ST_IDLE;
        end
      endcase
    end
end

endmodule

