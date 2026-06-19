#!/usr/bin/env sage
# -*- coding: sage -*-
"""
Ep True-Rank Well-Log  ----  for SageMath 9.3  (run:  sage Ep_rank.sage)

Curve family:  E_p : y^2 = x^3 - p   for primes p on the 6N corridors (p>3).
For each p record:  6N wing, p mod 24, root number w(E_p), and the TRUE rank.

Design notes (read before running):
  * E.rank() can be SLOW or non-certifiable when Sha is nontrivial. We therefore
    use a tiered strategy and ALWAYS record how certain the rank is:
       - try E.rank(only_use_mwrank=False) with a per-curve time budget;
       - if that is not certified, fall back to E.rank_bounds() and record the
         lower/upper bounds and whether they coincide (certain) or not.
    The analysis downstream MUST distinguish certified ranks from bounded ones.
  * Per-curve timeout uses a signal alarm (Unix). If a curve blows the budget it
    is logged as 'Timeout' and skipped -- the platform never crashes.
  * CHECKPOINTING: the CSV is appended row-by-row and flushed; rerunning the
    script skips primes already in the CSV, so you can stop/resume freely.

Tunables are at the top of main().
"""

import csv, os, signal, time

# ---------- per-curve timeout via SIGALRM ----------
class _Timeout(Exception): pass
def _alarm_handler(signum, frame): raise _Timeout()
signal.signal(signal.SIGALRM, _alarm_handler)

def wing_of(p):
    # p mod 6 is 1 or 5 for all primes >3 ; map 5 -> -1 (the 6N-1 wing), 1 -> +1
    return +1 if p % 6 == 1 else -1

def root_number_of(E):
    # Sage: global root number (analytic). Cheap and reliable.
    try:
        return int(E.root_number())
    except Exception:
        return None

def true_rank(E, budget_seconds):
    """
    Returns (rank_value_or_None, status, rank_lo, rank_hi).
    status in {'certified','bounded','timeout','error'}.
      certified : exact rank known
      bounded   : only lo<=rank<=hi known and lo!=hi  (rank_value=None)
      timeout   : exceeded time budget
      error     : Sage raised
    """
    signal.alarm(int(budget_seconds))
    try:
        # First attempt: a certified rank.
        try:
            r = E.rank()                      # may raise if not certified
            signal.alarm(0)
            return (int(r), 'certified', int(r), int(r))
        except Exception:
            # Fall back to provable bounds (uses 2-descent + analytic info).
            lo, hi = E.rank_bounds()
            signal.alarm(0)
            lo, hi = int(lo), int(hi)
            if lo == hi:
                return (lo, 'certified', lo, hi)
            return (None, 'bounded', lo, hi)
    except _Timeout:
        return (None, 'timeout', None, None)
    except Exception:
        signal.alarm(0)
        return (None, 'error', None, None)
    finally:
        signal.alarm(0)

def load_done(path):
    done = set()
    if os.path.exists(path):
        with open(path, newline='') as f:
            for row in csv.DictReader(f):
                try: done.add(int(row['Prime_p']))
                except Exception: pass
    return done

def main():
    # -------- tunables --------
    P_MAX            = 10000     # upper limit on p (start here; raise later)
    PER_CURVE_BUDGET = 60        # seconds per curve before we give up
    OUT              = 'Ep_Rank_Log.csv'
    # --------------------------

    header = ['Prime_p','6N_Wing','Mod_24','Root_Number',
              'True_Rank','Rank_Lo','Rank_Hi','Computation_Status']
    done = load_done(OUT)
    new_file = not os.path.exists(OUT)
    fout = open(OUT, 'a', newline='')
    writer = csv.writer(fout)
    if new_file:
        writer.writerow(header); fout.flush()

    ps = [p for p in primes(5, P_MAX) ]   # primes >3 are automatically on 6N+-1
    print("Total target primes (p>3, p<%d): %d ; already done: %d"
          % (P_MAX, len(ps), len(done)))

    t0 = time.time(); n_ok = 0
    for i, p in enumerate(ps):
        if p in done:
            continue
        E = EllipticCurve([0, 0, 0, 0, -p])   # y^2 = x^3 - p
        w = root_number_of(E)
        rank_val, status, lo, hi = true_rank(E, PER_CURVE_BUDGET)
        writer.writerow([p, wing_of(p), p % 24, w,
                         '' if rank_val is None else rank_val,
                         '' if lo is None else lo,
                         '' if hi is None else hi,
                         status])
        fout.flush()                          # checkpoint every curve
        n_ok += 1
        if n_ok % 25 == 0:
            el = time.time() - t0
            print("  ...%d new curves done (p=%d), %.1fs elapsed, status=%s"
                  % (n_ok, p, el, status))
    fout.close()
    print("DONE. wrote/updated %s" % OUT)

if __name__ == '__main__':
    main()
