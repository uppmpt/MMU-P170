import re
import sys

def parse(path):
    trace = []
    with open(path, 'r') as f:
        for line in f:
            m = re.search(r'MMU: VA=([0-9a-f]+) PA=([0-9a-f]+) type=(\d+)', line)
            if m:
                va = int(m.group(1), 16)
                pa = int(m.group(2), 16)
                typ = int(m.group(3))
                trace.append((va, pa, typ))
    return trace

if __name__ == '__main__':
    path = sys.argv[1] if len(sys.argv) > 1 else '/tmp/spike_mmu.log'
    trace = parse(path)
    print(f"Total: {len(trace)} acessos")
    print("Distribuição por tipo:")
    types = {0: 'LOAD', 1: 'STORE', 2: 'FETCH'}
    from collections import Counter
    for t, n in sorted(Counter(t for _, _, t in trace).items()):
        print(f"  {types.get(t, t)}: {n}")
    print("\nTraduções VA->PA (não identidade):")
    for va, pa, t in trace:
        if va != pa:
            print(f"  VA=0x{va:016x} -> PA=0x{pa:016x} ({types[t]})")
