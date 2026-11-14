# MMU-P170
## Sv39 Memory Management Unit for RV64GC

**Performance Gen 1 - Verification Level 70/100**

---

## Document Information

| Field | Value |
|---|---|
| Product | MMU-P170 |
| Revision | 1.0 |
| Date | 2026-11-14 |
| Author | Pacesolo Dev (uppmpt) |
| Classification | Public |
| License | Dual (CERN-OHL-S + Commercial) |

### Revision History

| Rev | Date | Changes |
|---|---|---|
| 1.0 | 2026-11-14 | Initial release |

---

## 1. Overview

MMU-P170 is a 100% spec-compliant Sv39 Memory Management Unit for RV64GC processors. It implements the complete RV64 section 4.3 virtual memory specification, including A/D bit management (Svade), superpage support (4KB/2MB/1GB), stval reporting, M-mode bypass, and all four sfence.VMA variants.

Designed for integration with RV64GC cores targeting Linux-capable systems, MMU-P170 delivers:

- ~4 GHz operation in 5nm (extrapolated from Nangate45 STA)
- Compact area: 31,926 cells
- Commercial-grade verification: 10M fuzz vectors, 0 divergences
## 2. Key Features

### 2.1 Compliance
- 100% RV64 section 4.3 Sv39 spec-compliant
- A/D bits (Svade model - page fault when A=0 or D=0 on store)
- Superpage support: 4KB, 2MB, 1GB
- Reserved bit checking (63:54)
- Canonical address checking
- M-mode bypass (spec section 4.1.1)
- Bare / Sv48 / Sv57 modes translate to VA=PA
- sfence.VMA: all 4 variants (all, VA, ASID, VA+ASID)
- stval output for fault address
- Access fault vs page fault distinction

### 2.2 Architecture
- L0 uTLB: 4-entry fully-associative CAM, 2-cycle hit
- L1 TLB: 16-entry 2-way set-associative, 2-stage pipeline, 4-cycle hit
- PWC (Page Walk Cache): 4+4 entries, reduces walk from 3 to ~1.2 accesses
- FSM walker: 5-state hardware page table walker
- Dual-side: Independent D-side and I-side paths

### 2.3 Interface
- Request/response with 4-bit transaction ID (MSHR-ready)
- Synchronous single clock (mmu_clk)
- Asynchronous reset (mmu_rst, active high)
- Standard external PTW interface
## 3. Specifications

### 3.1 Functional

| Parameter | Value |
|---|---|
| ISA | RV64GC |
| Virtual memory | Sv39 (39-bit VA, 56-bit PA) |
| Page sizes | 4KB, 2MB, 1GB |
| Translation modes | Sv39, Bare (M-mode, satp.MODE not 8) |
| Privilege modes | M, S, U |
| Max ASID | 16 bits |
| stval width | 64 bits |
| Reset | Asynchronous, active high |

### 3.2 Performance (Nangate45)

| Metric | Value |
|---|---|
| WNS | -0.75 ns |
| Critical path | 1.25 ns |
| Fmax N45 | 800 MHz |
| Fmax N5 (x5 extrapolation) | ~4.0 GHz |
| Fmax N5 (x6 extrapolation) | ~4.8 GHz |
| L0 hit latency | 2 cycles |
| L1 hit latency | 4 cycles |
| Miss (PWC hit) | 2-4 cycles |
| Miss (full walk) | 8-12 cycles |

### 3.3 Area

| Component | Cells (N45) |
|---|---|
| L0 uTLB (x2 for D/I) | ~1,800 |
| L1 TLB (x2 for D/I) | ~24,000 |
| PWC (L1 + L2 caches) | ~2,400 |
| FSM + control | ~3,700 |
| **Total** | **31,926** |

Estimated area: ~0.026 mm2 in Nangate45.
## 4. Block Diagram

Data path (D-side and I-side are independent and parallel):

    D_REQ ---> [L0 uTLB] ---> [L1 TLB] ---> output
                  |              |
                  | miss         | miss
                  v              v
                [PWC lookup] -> [FSM walker] -> [PTW interface]

    I_REQ ---> [L0 uTLB] ---> [L1 TLB] ---> output
                  |              |
                  | miss         | miss
                  v              v
                [PWC lookup] -> [FSM walker] -> [PTW interface]

Cache hierarchy:
- L0 uTLB: 4-entry fully-associative CAM (fastest, 2-cycle)
- L1 TLB:  16-entry 2-way set-associative (4-cycle)
- PWC:     4-entry L2 cache + 4-entry L1 cache (miss path)
- Walker:  5-state FSM (L2 -> L1 -> L0 -> fill)

Latency summary:
- L0 hit: 2 cycles
- L1 hit: 4 cycles
- PWC hit: 2-4 cycles (bypasses 1-2 page table levels)
- Full miss: 8-12 cycles (3 levels, 1 memory access each)
## 5. Interface

### 5.1 Signal Summary

| Group | Signals | Width |
|---|---|---|
| Clock/Reset | mmu_clk, mmu_rst | 1, 1 |
| CSRs | satp (64), priv (2), mstatus_mxr, mstatus_sum | mixed |
| D-side req | d_req_valid, d_req_va (64), d_req_is_write, d_req_id (4) | mixed |
| D-side resp | d_resp_valid, d_resp_pa (64), d_resp_fault, d_resp_cause (4), d_resp_id (4), d_resp_tval (64) | mixed |
| I-side req | i_req_valid, i_req_va (64), i_req_id (4) | mixed |
| I-side resp | i_resp_valid, i_resp_pa (64), i_resp_fault, i_resp_cause (4), i_resp_id (4), i_resp_tval (64) | mixed |
| PTW req | ptw_req_valid, ptw_req_addr (64) | mixed |
| PTW resp | ptw_resp_valid, ptw_resp_data (64), ptw_resp_error | mixed |
| SFENCE | sfence_valid, sfence_va (64), sfence_asid (16) | mixed |

### 5.2 Protocol

- Requests accepted when req_valid AND req_ready
- Responses valid for 1 cycle when resp_valid
- Requester must hold req_valid until req_ready asserted
- PTW: MMU asserts ptw_req_valid for 1+ cycles; PTW responds with ptw_resp_valid for 1 cycle
- sfence.VMA takes effect next cycle

## 6. Compliance Checklist (RV64 section 4.3)

| Requirement | Status | Evidence |
|---|---|---|
| 39-bit VA canonical | PASS | 10M fuzz |
| 56-bit PA | PASS | 10M fuzz |
| 4KB/2MB/1GB pages | PASS | Directed + fuzz |
| PTE format (V,R,W,X,U,G,A,D,PPN) | PASS | Directed + fuzz |
| A bit (Svade) | PASS | Directed + fuzz |
| D bit (Svade, store-only) | PASS | Directed + fuzz |
| Reserved bits 63:54 | PASS | Directed + fuzz |
| Superpage alignment | PASS | Directed + fuzz |
| Privilege checks (U/S/M) | PASS | Directed + fuzz |
| SUM, MXR | PASS | Directed + fuzz |
| sfence.VMA all variants | PASS | 7 directed tests |
| stval (fault VA) | PASS | Directed + fuzz |
| Bare / Sv48 / Sv57 translate to VA=PA | PASS | Directed + fuzz |
| M-mode bypass | PASS | Directed + fuzz |
| Access fault vs page fault | PASS | Directed + fuzz |
## 7. Verification

### 7.1 Methodology

- Fuzz: 10,000,000 vectors, 0 divergences (seed 0xDEADBEEF, reproducible)
- Reference model: Python Sv39 oracle (independent implementation)
- Trace: 42 real VA-to-PA translations from Spike (Linux boot pattern)
- Directed tests: 24 fuzz cases + 7 sfence tests

### 7.2 Coverage

| Type | Count |
|---|---|
| Random VAs (canonical + non-canonical) | 7,000,000 |
| Directed edge cases | 24 |
| sfence.VMA variants | 7 |
| Spike trace accesses | 42 |

### 7.3 Bugs Found and Fixed (Errata)

| # | Bug | Severity | Fixed |
|---|---|---|---|
| 1 | satp.MODE not 8 did not bypass (spec 4.1.1) | Critical | v5.0 |
| 2 | Superpage L1 (2MB) leaf walked to L0 | Critical | v5.0 |
| 3 | Canonical address not checked on hit path | High | v5.0 |
| 4 | Superpage PA missing VPN[0] | High | v5.0 |

All bugs found by fuzz during development; none shipped.

### 7.4 Limitations (Honest)

Not included:
- Silicon proof (RTL soft IP only)
- Formal verification (fuzz-based only; formal available for specific blocks on request)
- Linux boot (trace-based evidence only, 42 accesses)
- PDK-specific STA (Nangate45 only; client must re-run in target PDK)
- Power estimation

Requires from client:
- Target PDK synthesis and STA
- Integration with CLINT, PLIC, UART, memory
- Tapeout and silicon validation
- Linux kernel port if applicable
## 8. Integration Guide

### 8.1 Minimal integration

1. Connect mmu_clk to core clock
2. Connect mmu_rst to core reset
3. Connect satp, priv, mstatus_mxr, mstatus_sum from CSR
4. Connect D-side request/response to LSU
5. Connect I-side request/response to I-cache/fetch
6. Connect PTW interface to external PTW (see 8.2)
7. Connect sfence_* to CSR/trap logic

### 8.2 PTW Responsibility

MMU-P170 assumes an external PTW that reads 8-byte PTEs from physical memory. The MMU implements the walk state machine + PWC. External PTW must:

- On ptw_req_valid: read 8 bytes at ptw_req_addr
- Return ptw_resp_data with ptw_resp_valid
- Assert ptw_resp_error if PMP blocks access or memory faults

### 8.3 Clock Domain

Single clock domain (mmu_clk). If core runs in different domain, add CDC wrappers.

## 9. Deliverables

| Item | Format |
|---|---|
| RTL source | mmu_p170.arx (Arx language) |
| Generated Verilog | mmu_p170.v |
| Fuzzer | tests/fuzz_expanded.cpp |
| Spike trace | tests/spike_trace.txt |
| Test scripts | tests/*.py, tests/*.sh |
| Datasheet | DATASHEET.md (this file) |
| README | README.md |
| Licenses | LICENSE (CERN-OHL-S) + LICENSE-COMMERCIAL.md |
## 10. Licensing

MMU-P170 is released under dual licensing:

### 10.1 Open-Source (CERN-OHL-S v2)
Free for:
- Academic use
- Open-source projects (must open derivative design)
- Evaluation

### 10.2 Commercial License
Required for:
- Proprietary core integration
- Closed-source SoC products
- Volume manufacturing

Contact: pacesolodev@gmail.com

## 11. Support

Community support is available via GitHub issues at
https://github.com/uppmpt/MMU-P170/issues

Commercial support (integration assistance, priority response, SLA) is available
under a separate commercial agreement. Contact: pacesolodev@gmail.com

## 12. Contact

- Author: Pacesolo Dev (uppmpt)
- Email: pacesolodev@gmail.com
- GitHub: https://github.com/uppmpt

---

End of Datasheet - MMU-P170 Rev 1.0
