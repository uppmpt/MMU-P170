#include <iostream>
#include <map>
#include <random>
#include <vector>
#include <cstdint>
#include "Vmmu_p170.h"
#include "verilated.h"

std::map<uint64_t, uint64_t> mem;
std::mt19937_64 rng(0xDEADBEEF);
uint64_t rand64() { return rng(); }
uint32_t randn(uint32_t n) { return rng() % n; }
uint64_t read64(uint64_t addr) { auto it = mem.find(addr & ~0x7ULL); return (it!=mem.end())?it->second:0; }
void tick(Vmmu_p170* d) { d->mmu_clk=0; d->eval(); d->mmu_clk=1; d->eval(); }

struct WalkResult { uint64_t pa; bool fault; uint32_t cause; };
struct TraceEntry { uint64_t va; uint64_t pa; uint32_t type; };
std::vector<TraceEntry> trace_seed;
void load_trace(const char* path) {
    FILE* f = fopen(path, "r");
    if (!f) { std::cout << "WARN: trace " << path << " not found" << std::endl; return; }
    char line[256];
    while (fgets(line, sizeof(line), f)) {
        uint64_t va, pa; uint32_t t;
        if (sscanf(line, "%lx %lx %u", &va, &pa, &t) == 3)
            trace_seed.push_back({va, pa, t});
    }
    fclose(f);
    std::cout << "Loaded " << trace_seed.size() << " trace entries" << std::endl;
}


void setup_pt_full() {
    mem.clear();
    mem[0x80001000] = (0x80401ULL << 10) | (1<<7) | (1<<6) | (1<<3) | (1<<2) | (1<<1) | 1;
    mem[0x80001008] = (0x80002ULL << 10) | 1;
    mem[0x80001010] = (0x80003ULL << 10) | 1;
    mem[0x80002000] = (0x80400ULL << 10) | (1<<7) | (1<<6) | (1<<3) | (1<<2) | (1<<1) | 1;
    mem[0x80003000 + 8*0] = (0x100ULL << 10) | (1<<7) | (1<<6) | (1<<3) | (1<<2) | (1<<1) | 1;
    mem[0x80003000 + 8*1] = (0x101ULL << 10) | (1<<7) | (1<<3) | (1<<2) | (1<<1) | 1;
    mem[0x80003000 + 8*2] = (0x102ULL << 10) | (1<<6) | (1<<3) | (1<<2) | (1<<1) | 1;
    mem[0x80003000 + 8*3] = 0;
    mem[0x80003000 + 8*4] = (0x104ULL << 10) | (1<<7) | (1<<6) | (1<<2) | 1;
    mem[0x80003000 + 8*5] = (1ULL << 63) | (0x105ULL << 10) | (1<<7) | (1<<6) | (1<<3) | (1<<2) | (1<<1) | 1;
    mem[0x80003000 + 8*6] = (1ULL << 62) | (0x106ULL << 10) | (1<<7) | (1<<6) | (1<<3) | (1<<2) | (1<<1) | 1;
    mem[0x80003000 + 8*7] = (0x80040ULL << 10) | 1;
    mem[0x80003000 + 8*8] = (0x108ULL << 10) | (1<<7) | (1<<6) | (1<<3) | 1;
    mem[0x80003000 + 8*9] = (0x109ULL << 10) | (1<<7) | (1<<6) | (1<<4) | (1<<3) | (1<<2) | (1<<1) | 1;
    mem[0x80003000 + 8*10] = (0x10AULL << 10) | (1<<7) | (1<<6) | (1<<4) | (1<<3) | 1;
    mem[0x80003000 + 8*11] = (0x10BULL << 10) | (1<<7) | (1<<6) | (1<<1) | 1;
    mem[0x80003000 + 8*12] = (0x10CULL << 10) | (1<<7) | (1<<6) | (1<<5) | (1<<3) | (1<<2) | (1<<1) | 1;
    for (int i = 13; i < 16; i++) mem[0x80003000 + 8*i] = ((0x100ULL + i) << 10) | (1<<7) | (1<<6) | (1<<3) | (1<<2) | (1<<1) | 1;
    mem[0x80004000 + 8*0] = (0x100ULL << 10) | (1<<7) | (1<<6) | (1<<3) | (1<<2) | (1<<1) | 1;
}

WalkResult do_translate(uint64_t va, uint64_t satp, bool is_write, uint32_t priv, bool mxr, bool sum) {
    WalkResult r = {0, false, 0};
    if (priv == 3) { r.pa = va; return r; }
    uint32_t mode = (satp >> 60) & 0xF;
    if (mode != 8) { r.pa = va; return r; }
    uint64_t upper = va >> 39;
    uint32_t bit38 = (va >> 38) & 1;
    bool canon = bit38 ? (upper == ((1ULL<<25)-1)) : (upper == 0);
    if (!canon) { r.fault=true; r.cause=is_write?15:13; return r; }
    uint64_t ppn = satp & 0xFFFFFFFFFFFULL;
    uint64_t a = ppn << 12;
    for (int level = 2; level >= 0; level--) {
        uint64_t pte_addr = a + (((va >> (12 + 9 * level)) & 0x1FF) << 3);
        uint64_t pte = read64(pte_addr);
        uint32_t v=pte&1, r_bit=(pte>>1)&1, w_bit=(pte>>2)&1, x_bit=(pte>>3)&1;
        uint32_t u_bit=(pte>>4)&1, a_bit=(pte>>6)&1, d_bit=(pte>>7)&1;
        uint64_t reserved=(pte>>54);
        if (!v || reserved || (!r_bit && w_bit)) { r.fault=true; r.cause=is_write?15:13; return r; }
        if (r_bit || x_bit) {
            if (level==2 && ((pte>>10)&((1ULL<<18)-1))!=0) { r.fault=true; r.cause=is_write?15:13; return r; }
            if (level==1 && ((pte>>10)&((1ULL<<9)-1))!=0) { r.fault=true; r.cause=is_write?15:13; return r; }
            if (!a_bit) { r.fault=true; r.cause=is_write?15:13; return r; }
            if (is_write && !d_bit) { r.fault=true; r.cause=15; return r; }
            bool priv_ok = (priv==0) ? u_bit : (priv==1) ? true : false;
            bool rwx_ok = is_write ? w_bit : (r_bit || (mxr && x_bit));
            if (!priv_ok || !rwx_ok) { r.fault=true; r.cause=is_write?15:13; return r; }
            uint64_t pa_ppn = (pte>>10)&0xFFFFFFFFFFFULL;
            uint64_t ppn_lo = (pa_ppn >> (9*level)) << (9*level);
            uint64_t va_lo = (va>>12) & ((1ULL<<(9*level))-1);
            r.pa = ((ppn_lo|va_lo)<<12) | (va&0xFFF);
            return r;
        }
        a = ((pte>>10)&0xFFFFFFFFFFFULL) << 12;
    }
    r.fault=true; r.cause=is_write?15:13;
    return r;
}

int run_one(uint64_t va, uint64_t satp, bool is_write, uint32_t priv, bool mxr, bool sum,
            WalkResult exp, Vmmu_p170* d, uint64_t* rtl_pa, bool* rtl_fault, uint32_t* rtl_cause) {
    d->sfence_valid = 1; d->sfence_va = 0; d->sfence_asid = 0;
    tick(d); d->sfence_valid = 0; tick(d);
    d->satp = satp; d->priv = priv; d->mstatus_mxr = mxr; d->mstatus_sum = sum;
    d->d_req_valid = 1; d->d_req_va = va; d->d_req_is_write = is_write; d->d_req_id = 0;
    for (int i = 0; i < 200; i++) {
        d->ptw_req_ready = 1;
        d->ptw_resp_valid = 0;
        d->ptw_resp_error = 0;
        if (d->ptw_req_valid) {
            d->ptw_resp_valid = 1;
            d->ptw_resp_data = read64(d->ptw_req_addr);
        }
        tick(d);
        if (d->d_req_ready) d->d_req_valid = 0;
        if (d->d_resp_valid) {
            *rtl_pa = d->d_resp_pa; *rtl_fault = d->d_resp_fault; *rtl_cause = d->d_resp_cause;
            bool ok = (exp.fault == (bool)d->d_resp_fault)
                   && (exp.fault ? exp.cause == d->d_resp_cause : exp.pa == d->d_resp_pa);
            tick(d);
            return ok ? 0 : 1;
        }
    }
    return 2;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vmmu_p170* d = new Vmmu_p170;
    d->mmu_rst = 1; tick(d);
    d->mmu_rst = 0; tick(d);
    uint64_t N = (argc > 1) ? atoll(argv[1]) : 1000;
    std::cout << "Rodando " << std::dec << N << " vetores (com PWC)..." << std::endl;
    setup_pt_full();
    load_trace("tests/spike_trace.txt");
    std::vector<uint64_t> va_pool;
    for (uint64_t v = 0; v < 0x10000; v += 0x1000) va_pool.push_back(v);
    for (uint64_t v = 0x10000; v < 0x200000; v += 0x1000) va_pool.push_back(v);
    va_pool.push_back(0x200000); va_pool.push_back(0x40000000);
    va_pool.push_back(0x400000000ULL); va_pool.push_back(0x800000000ULL);
    va_pool.push_back(0xFFFFFF8000000000ULL); va_pool.push_back(0xFFFFFFFFFFFFF000ULL);
    va_pool.push_back(0x8); va_pool.push_back(0xFF8); va_pool.push_back(0x1008);
    int pass=0, fail=0, timeout=0, shown=0;
    for (uint64_t i = 0; i < N; i++) {
        uint64_t va;
        uint32_t r = randn(100);
        if (r < 10 && !trace_seed.empty()) {
            va = trace_seed[randn(trace_seed.size())].va;
        } else if (r < 60) {
            va = va_pool[randn(va_pool.size())];
        } else {
            va = rand64() & 0xFFFFFFFFFFFFF000ULL;
        }
        bool is_write = randn(2);
        uint32_t priv = (randn(10) < 8) ? 1 : randn(4);
        bool mxr = randn(2), sum = randn(2);
        uint64_t satp;
        uint32_t sm = randn(10);
        if (sm < 8) satp = (8ULL<<60)|0x80001ULL;
        else if (sm < 9) satp = 0;
        else satp = ((uint64_t)randn(16) << 60) | 0x80001ULL;
        WalkResult exp = do_translate(va, satp, is_write, priv, mxr, sum);
        uint64_t rtl_pa=0; bool rtl_fault=false; uint32_t rtl_cause=0;
        int rc = run_one(va, satp, is_write, priv, mxr, sum, exp, d, &rtl_pa, &rtl_fault, &rtl_cause);
        if (rc==0) pass++;
        else if (rc==1) {
            fail++;
            if (shown < 10) {
                shown++;
                std::cout << "\n--- FAIL #" << std::dec << shown << " ---" << std::endl;
                std::cout << "VA=0x" << std::hex << va << " satp=0x" << satp << " wr=" << std::dec << is_write
                          << " priv=" << priv << " mxr=" << mxr << " sum=" << sum << std::endl;
                std::cout << "  ORACULO: fault=" << exp.fault << " cause=" << exp.cause << " pa=0x" << std::hex << exp.pa << std::endl;
                std::cout << "  RTL:     fault=" << rtl_fault << " cause=" << rtl_cause << " pa=0x" << std::hex << rtl_pa << std::endl;
            }
        } else timeout++;
        if ((i+1) % 1000 == 0) std::cout << "  [" << std::dec << (i+1) << "/" << N << "] pass=" << pass << " fail=" << fail << " timeout=" << timeout << std::endl;
    }
    std::cout << "\n=== PASS: " << std::dec << pass << "  FAIL: " << fail << "  TIMEOUT: " << timeout << " ===" << std::endl;
    return fail == 0 ? 0 : 1;
}
