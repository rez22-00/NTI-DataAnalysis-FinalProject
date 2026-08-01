"""
make_dirty_data.py
-------------------
Takes the CLEAN workout_session CSV and produces a controlled "dirty"
version for the Data Cleaning phase (Phase 2 -> Phase 3 of the project flow).

The clean source file is never modified. All issues are injected with a
fixed random seed so the process is 100% reproducible and documentable.

Usage:
    python make_dirty_data.py
"""

import pandas as pd
import numpy as np
import random

# ---- reproducibility ----
SEED = 42
random.seed(SEED)
np.random.seed(SEED)

SRC = "workout_session_clean.csv"
OUT = "workout_session_dirty.csv"
LOG = "dirtying_log.md"

df = pd.read_csv(SRC)
n = len(df)
log_lines = [f"# Data Dirtying Log\n", f"Source rows: {n}\n", f"Random seed: {SEED}\n"]

# ----------------------------------------------------------------------
# 1) Missing values (NULLs)
# ----------------------------------------------------------------------
pct_missing_calories = 0.03
pct_missing_checkout = 0.02

idx_cal = df.sample(frac=pct_missing_calories, random_state=SEED).index
df.loc[idx_cal, "calories_burned"] = np.nan
log_lines.append(f"- Set {len(idx_cal)} rows ({pct_missing_calories:.0%}) of `calories_burned` to NULL")

idx_checkout = df.sample(frac=pct_missing_checkout, random_state=SEED + 1).index
df.loc[idx_checkout, "checkout_time"] = np.nan
log_lines.append(f"- Set {len(idx_checkout)} rows ({pct_missing_checkout:.0%}) of `checkout_time` to NULL")

# ----------------------------------------------------------------------
# 2) Duplicate rows
# ----------------------------------------------------------------------
pct_duplicates = 0.015
dup_rows = df.sample(frac=pct_duplicates, random_state=SEED + 2)
df = pd.concat([df, dup_rows], ignore_index=True)
log_lines.append(f"- Duplicated {len(dup_rows)} rows ({pct_duplicates:.0%}) and appended them back")

# ----------------------------------------------------------------------
# 3) Inconsistent casing / whitespace in workout_type
# ----------------------------------------------------------------------
pct_case_issues = 0.05
idx_case = df.sample(frac=pct_case_issues, random_state=SEED + 3).index

def mess_case(v):
    choice = random.choice(["upper", "lower", "pad", "leadspace"])
    if choice == "upper":
        return v.upper()
    elif choice == "lower":
        return v.lower()
    elif choice == "pad":
        return f" {v} "
    else:
        return f"  {v}"

df.loc[idx_case, "workout_type"] = df.loc[idx_case, "workout_type"].apply(mess_case)
log_lines.append(f"- Randomized casing/whitespace on {len(idx_case)} rows ({pct_case_issues:.0%}) of `workout_type`")

# ----------------------------------------------------------------------
# 4) Misspelled workout_type values
# ----------------------------------------------------------------------
pct_typos = 0.02
typo_map = {
    "Yoga": "Yogaa",
    "Cardio": "Cardo",
    "Weightlifting": "Wieghtlifting",
    "CrossFit": "Crosfit",
    "Swimming": "Swiming",
    "Pilates": "Pilattes",
}
idx_typo = df.sample(frac=pct_typos, random_state=SEED + 4).index
df.loc[idx_typo, "workout_type"] = df.loc[idx_typo, "workout_type"].map(
    lambda v: typo_map.get(v.strip(), v)
)
log_lines.append(f"- Injected spelling typos on {len(idx_typo)} rows ({pct_typos:.0%}) of `workout_type`")

# ----------------------------------------------------------------------
# 5) Inconsistent date format in checkin_time (MM/DD/YYYY instead of YYYY-MM-DD)
# ----------------------------------------------------------------------
pct_date_format = 0.03
idx_dates = df.sample(frac=pct_date_format, random_state=SEED + 5).index

def reformat_date(v):
    try:
        dt = pd.to_datetime(v)
        return dt.strftime("%m/%d/%Y %H:%M:%S")
    except Exception:
        return v

df.loc[idx_dates, "checkin_time"] = df.loc[idx_dates, "checkin_time"].apply(reformat_date)
log_lines.append(f"- Reformatted {len(idx_dates)} rows ({pct_date_format:.0%}) of `checkin_time` to MM/DD/YYYY")

# ----------------------------------------------------------------------
# 6) Outlier / invalid calories_burned values
# ----------------------------------------------------------------------
pct_outliers = 0.01
idx_out = df.sample(frac=pct_outliers, random_state=SEED + 6).index
outlier_vals = np.random.choice([-50, -1, 0, 9999, 15000], size=len(idx_out))
df.loc[idx_out, "calories_burned"] = outlier_vals
log_lines.append(f"- Set {len(idx_out)} rows ({pct_outliers:.0%}) of `calories_burned` to invalid/outlier values (e.g. negative, 9999+)")

# ----------------------------------------------------------------------
# 7) Logical errors: checkout_time before checkin_time
# ----------------------------------------------------------------------
pct_logic = 0.01
idx_logic = df.sample(frac=pct_logic, random_state=SEED + 7).index
mask = idx_logic.intersection(df.dropna(subset=["checkin_time", "checkout_time"]).index)
for i in mask:
    try:
        ci = pd.to_datetime(df.loc[i, "checkin_time"])
        df.loc[i, "checkout_time"] = (ci - pd.Timedelta(minutes=random.randint(10, 60))).strftime("%Y-%m-%d %H:%M:%S")
    except Exception:
        pass
log_lines.append(f"- Swapped {len(mask)} rows ({pct_logic:.0%}) so `checkout_time` is BEFORE `checkin_time`")

# ----------------------------------------------------------------------
# 8) Extra whitespace around user_id / gym_id
# ----------------------------------------------------------------------
pct_id_space = 0.02
idx_id = df.sample(frac=pct_id_space, random_state=SEED + 8).index
df.loc[idx_id, "user_id"] = df.loc[idx_id, "user_id"].apply(lambda v: f" {v} ")
log_lines.append(f"- Added leading/trailing whitespace to {len(idx_id)} rows ({pct_id_space:.0%}) of `user_id`")

# ----------------------------------------------------------------------
# Shuffle final rows so injected duplicates aren't all at the bottom
# ----------------------------------------------------------------------
df = df.sample(frac=1, random_state=SEED + 9).reset_index(drop=True)

df.to_csv(OUT, index=False)

log_lines.append(f"\n**Final row count:** {len(df)} (original {n} + {len(dup_rows)} injected duplicates)")
log_lines.append(f"\nOutput file: `{OUT}`")

with open(LOG, "w", encoding="utf-8") as f:
    f.write("\n".join(log_lines))

print("\n".join(log_lines))
