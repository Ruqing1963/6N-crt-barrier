# 6N-crt-barrier

**Designing Anti-Tautological Probes on the 6N Skeleton: A Negative Case Study with Elliptic-Curve Ranks and the CRT Information Barrier**

R. Chen · GUT Geoservice Inc., Montréal · *6N Arithmetic Geodynamics* series · Methodological Note · 2026

---

## What this is

This repository accompanies a **methodological note**, not a claim of new arithmetic. Within the heuristic "6N" framework (every prime > 3 lies on the residue classes 6N ± 1, here the *right wing* 6N+1 and *left wing* 6N−1), it asks a single, honestly-posed question:

> Does the 6N wing of a prime *p* exert any control over a high-dimensional arithmetic invariant attached to *p* — the Mordell–Weil rank of the elliptic curve **E_p : y² = x³ − p** — beyond what is already fixed by standard congruence data?

The answer is a clean **negative**, and the value of the work is the *discipline* used to reach it, plus an honest report of why the negative is structurally inevitable.

## The two contributions

1. **An anti-tautology discipline for 6N probes.** A probe is admissible only if its observable cannot be computed from primality alone. This rejects the common family of probes built from the von Mangoldt function Λ (which is positive *exactly* on prime powers): placing Λ in a "seismic" ratio and then "discovering" that primes coincide with large values of it proves only the definition of Λ. The rank of E_p passes the criterion — knowing "*p* is prime" does not determine the rank — while retaining a natural 6N bridge (*p* mod 6).

2. **A worked, honestly-negative example.** Using certified true ranks for the 1116 of 1227 primes 3 < *p* < 10⁴ whose rank is computable to certainty (SageMath), a three-layer analysis finds **no wing control of rank**:
   - **Layer 1** (raw wing effect): Cohen's *d* = +0.022 — already negligible.
   - **Layer 2** (within each root-number class): Cohen's *d* ≈ +0.02 in both classes.
   - **Layer 3** (within-class wing-label shuffle): observed |*d*| = 0.023 sits at the 9th percentile of the null; *p* = 0.913.

   Rank is organised entirely by the **root number** (a function of *p* mod 24). Since 6 | 24, the wing (mod 6) is the coarse quotient of the mod-24 datum and is **absorbed** by it via the Chinese Remainder Theorem — a concrete instance of what we call the **CRT information barrier**: the explanatory reach of the 6N wing stops at the *location* of primes and does not penetrate to the deep invariants of objects built from them.

**This barrier restates, rather than extends, known structure.** That the root number depends on *p* mod 24 and controls rank parity is classical (BSD / parity); that mod 6 is a quotient of mod 24 is elementary. The contribution is the falsification method and the honest negative — not a theorem.

## Repository layout

```
6N-crt-barrier/
├── paper/
│   ├── 6N_CRT_Barrier_MethodologicalNote.pdf   ← the note (read this first)
│   └── 6N_CRT_Barrier_MethodologicalNote.docx
├── code/
│   ├── Ep_rank.sage                  ← SageMath: certified true-rank well-log
│   ├── Ep_three_layer_analysis.py    ← pure Python: the three-layer analysis
│   └── make_figs.py                  ← pure Python: figures
├── data/
│   └── Ep_Rank_Log.csv               ← 1227 curves: p, wing, mod 24, root number, true rank, status
├── figures/
│   ├── fig_rank_by_wing.png
│   └── fig_rank_by_mod24.png
├── README.md
├── LICENSE
└── CITATION.cff
```

## Running the code

> **Important:** `Ep_rank.sage` requires **SageMath** and will **not** run under plain Python — it uses Sage built-ins (`EllipticCurve`, `primes`, `E.rank()`, `E.rank_bounds()`). The other two scripts are pure Python.

```bash
# 1. Generate the certified true-rank well-log (SageMath required).
#    Resumable: appends row-by-row to Ep_Rank_Log.csv and skips primes already done.
sage code/Ep_rank.sage

# 2. Run the three-layer analysis on the CSV (pure Python + numpy).
python3 code/Ep_three_layer_analysis.py

# 3. Reproduce the figures (pure Python + numpy + matplotlib).
python3 code/make_figs.py
```

The Λ-tautology control discussed in §2 of the note is reproducible on *n* ∈ [10⁵, 1.1×10⁵] with the same independence test (observed correlation +0.061; falls to −0.005 when Λ is replaced by a random sparse indicator of equal support).

## Data dictionary — `Ep_Rank_Log.csv`

| Column | Meaning |
|---|---|
| `Prime_p` | the prime *p* (3 < *p* < 10⁴) |
| `6N_Wing` | +1 for 6N+1 (right), −1 for 6N−1 (left) |
| `Mod_24` | *p* mod 24 |
| `Root_Number` | global root number *w*(E_p) ∈ {+1, −1} |
| `True_Rank` | certified rank (blank if only bounded) |
| `Rank_Lo`, `Rank_Hi` | provable bounds (equal when certified) |
| `Computation_Status` | `certified` \| `bounded` \| `timeout` \| `error` |

Only `certified` rows (1116 of 1227) are used in the analysis. As a data-integrity check, root number and rank parity agree in **1116/1116** certified curves (zero violations), consistent with BSD.

## Honesty statement

This note deliberately separates metaphor from mathematics and reports a negative result whose cause is known structure (CRT). It does not claim a new theorem, a new prime pattern, or predictive power. External references were checked against primary bibliographic sources; none was accepted on the basis of an unverified secondary suggestion.

## License

MIT — see [LICENSE](LICENSE).
