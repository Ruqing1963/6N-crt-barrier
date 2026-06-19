import csv, numpy as np
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
rows=[r for r in csv.DictReader(open('Ep_Rank_Log.csv')) if r['Computation_Status']=='certified']
wing=np.array([int(r['6N_Wing']) for r in rows]); w=np.array([int(r['Root_Number']) for r in rows])
m24=np.array([int(r['Mod_24']) for r in rows]); rank=np.array([int(r['True_Rank']) for r in rows])

# Fig 1: rank distribution by wing (show they overlap)
fig,ax=plt.subplots(figsize=(7,4.2))
vals=sorted(set(rank)); x=np.arange(len(vals)); width_=0.38
for i,(wg,lab,c) in enumerate([(1,'6N+1 (right wing)','#C0392B'),(-1,'6N-1 (left wing)','#2471A3')]):
    counts=[np.sum((rank==v)&(wing==wg)) for v in vals]
    ax.bar(x+(i-0.5)*width_, counts, width_, label=lab, color=c, edgecolor='k', linewidth=0.5)
ax.set_xticks(x); ax.set_xticklabels(vals); ax.set_xlabel('True rank of $E_p$'); ax.set_ylabel('count')
ax.set_title('Rank distribution by 6N wing (Cohen $d$ = +0.022, indistinguishable)')
ax.legend(); fig.tight_layout(); fig.savefig('fig_rank_by_wing.png',dpi=150,bbox_inches='tight')

# Fig 2: mean rank by mod-24 class, colored by root number
fig,ax=plt.subplots(figsize=(8,4.4))
classes=sorted(set(m24))
means=[rank[m24==c].mean() for c in classes]
roots=[w[m24==c][0] for c in classes]
wings=[wing[m24==c][0] for c in classes]
colors=['#C0392B' if r==-1 else '#27AE60' for r in roots]
bars=ax.bar([str(c) for c in classes], means, color=colors, edgecolor='k')
ax.set_xlabel('p mod 24'); ax.set_ylabel('mean rank')
ax.set_title('Mean rank is organized by root number (mod 24), not by 6N wing')
for i,(c,wg) in enumerate(zip(classes,wings)):
    ax.text(i, means[i]+0.03, f'{"+1" if wg==1 else "-1"}', ha='center', fontsize=8, color='#444')
from matplotlib.patches import Patch
ax.legend(handles=[Patch(color='#C0392B',label='root number $-1$ (odd rank)'),
                   Patch(color='#27AE60',label='root number $+1$ (even rank)')],fontsize=9)
ax.text(0.5,-0.22,'wing label (+1/-1) shown above each bar — wings of both signs appear in both root-number groups',
        transform=ax.transAxes,ha='center',fontsize=8,color='#666')
fig.tight_layout(); fig.savefig('fig_rank_by_mod24.png',dpi=150,bbox_inches='tight')
print("figures done")
