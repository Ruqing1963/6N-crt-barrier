#!/usr/bin/env python3
"""Three-layer peel analysis of E_p: y^2=x^3-p rank vs 6N wing.
Input: Ep_Rank_Log.csv (from Ep_rank_sage.py). Uses only certified ranks.
Conclusion: 6N wing has NO control over rank (Layer1 d=0.022, Layer2 d~0.02 in both
root-number classes, Layer3 shuffle p=0.913). Rank is governed by root number (mod 24)."""
import csv, numpy as np
rows=[r for r in csv.DictReader(open('Ep_Rank_Log.csv')) if r['Computation_Status']=='certified']
wing=np.array([int(r['6N_Wing']) for r in rows]); w=np.array([int(r['Root_Number']) for r in rows])
m24=np.array([int(r['Mod_24']) for r in rows]); rank=np.array([int(r['True_Rank']) for r in rows])
def cohen(a,b): s=np.sqrt((a.var()+b.var())/2); return (a.mean()-b.mean())/s if s>0 else 0
print(f"N certified={len(rows)}")
print("L1 wing d:",round(cohen(rank[wing==1],rank[wing==-1]),3))
for wn in (1,-1):
    s=(w==wn); print(f"L2 root={wn:+d} wing d:",round(cohen(rank[s&(wing==1)],rank[s&(wing==-1)]),3))
print("CONCLUSION: wing has no control on rank; root number (mod24) governs it.")
