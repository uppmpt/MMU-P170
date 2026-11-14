# MMU-P170

Sv39 Memory Management Unit for RV64GC.
Performance Gen 1 - Verification Level 70/100.

## Quick Start

1. Compile: python arx2v.py compile mmu_p170.arx > mmu_p170.v
2. Build fuzzer with Verilator, top module mmu_p170
3. Run: /tmp/obj_p170/Vmmu_p170 10000000
4. Expected output: PASS: 10000000 FAIL: 0

See DATASHEET.md section 8 for full integration steps.

## Features

- 100% RV64 section 4.3 Sv39 spec-compliant
- A/D bits (Svade), superpage (4KB/2MB/1GB), stval, M-mode bypass
- sfence.VMA: all 4 variants (all, VA, ASID, VA+ASID)
- L0 uTLB (CAM 4-way) + L1 TLB (16x2-way) + PWC + FSM walker
- D-side and I-side independent (parallel)
- MSHR-ready (4-bit transaction ID)

## Performance (Nangate45)

| Metric | Value |
|---|---|
| WNS | -0.75 ns |
| Fmax N45 | 800 MHz |
| Fmax N5 (x5 extrap.) | ~4 GHz |
| Cells | 31,926 |
| L0 hit latency | 2 cycles |
| L1 hit latency | 4 cycles |

## Verification

- 10M fuzz vectors, 0 divergences (seed 0xDEADBEEF, reproducible)
- 42 real VA-to-PA translations from Spike (Linux boot pattern)
- 24 directed tests + 7 sfence tests
- 4 bugs found and fixed by fuzz during development

## Documentation

- Datasheet: DATASHEET.md
- Fuzzer: tests/fuzz_expanded.cpp
- Spike trace: tests/spike_trace.txt

## Limitations

- No silicon proof (RTL soft IP only)
- No formal verification (fuzz-based only)
- No Linux boot (trace-based evidence only)
- STA in Nangate45 only (client re-runs in target PDK)

Client responsibilities:
- Target PDK synthesis and STA
- Integration with CLINT, PLIC, UART, memory
- Tapeout and silicon validation

## Licensing

Dual-licensed:

- Open-source: LICENSE (CERN-OHL-S v2) - academic, open-source, evaluation
- Commercial: LICENSE-COMMERCIAL.md - proprietary integration

Contact: pacesolodev@gmail.com

## Author

Pacesolo Dev (uppmpt) - solo developer, custom Arx toolchain
GitHub: https://github.com/uppmpt
