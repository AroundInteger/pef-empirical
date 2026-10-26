"""Run the complete PEF numerical programme, then write results/SUMMARY.md.

    python run_all.py --quick      # smoke test, a few minutes: checks the pipeline only
    python run_all.py              # full run (see README for timings)
    python run_all.py --only E3 E4b summary
    python run_all.py --force      # rerun phases already marked done

Resumable: each finished phase is recorded in results/logs/status.json and
skipped on the next call. E4b is also resumable within the phase.
Quick-mode results go to results_quick/, so they never overwrite a full run.
Logs: <results dir>/logs/<phase>.log
"""
import argparse
import json
import os
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.abspath(__file__))
PY = sys.executable


def phases(quick):
    e1rep_n = "100000" if quick else "4000000"
    return [
        ("tests", [PY, "-m", "pytest", "-q", os.path.join(ROOT, "tests")], {}),
        ("E0", [PY, "experiments/E0_symbolic.py"], {}),
        ("E1", [PY, "experiments/E1_population_mc.py"], {}),
        ("E1rep", [PY, "experiments/E1_population_mc.py"],
         {"PEF_NMC": e1rep_n, "PEF_SEED": "777000", "PEF_OUT": "results/E1_replication_4M.csv"}),
        ("E2", [PY, "experiments/E2_inference.py"], {}),
        ("E2e", [PY, "experiments/E2e_smallsample.py"], {}),
        ("E3", [PY, "experiments/E3_finite_sample.py"], {}),
        ("E4", [PY, "experiments/E4_model_classes.py"], {}),
        ("E4b", [PY, "experiments/E4b_tuned_trees.py"], {}),
        ("summary", [PY, "analysis/summarise.py"], {}),
    ]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true")
    ap.add_argument("--only", nargs="*")
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()

    # Experiments write to ./results relative to the working directory, so
    # quick mode runs inside a separate folder that has its own results/.
    work = os.path.join(ROOT, "results_quick") if a.quick else ROOT
    res = os.path.join(work, "results")
    logs = os.path.join(res, "logs")
    os.makedirs(logs, exist_ok=True)
    if a.quick:
        for sub in ("experiments", "analysis", "pef", "tests"):
            link = os.path.join(work, sub)
            if not os.path.exists(link):
                os.symlink(os.path.join(ROOT, sub), link)
    status_path = os.path.join(logs, "status.json")
    status = json.load(open(status_path)) if os.path.exists(status_path) else {}

    env0 = dict(os.environ, PYTHONWARNINGS="ignore")
    if a.quick:
        env0["PEF_QUICK"] = "1"

    for name, cmd, extra in phases(a.quick):
        if a.only and name not in a.only:
            continue
        if status.get(name, {}).get("ok") and not a.force:
            print(f"-- {name}: done previously ({status[name]['minutes']} min), skipping")
            continue
        print(f">> {name} ...", flush=True)
        t = time.time()
        with open(os.path.join(logs, f"{name}.log"), "w") as log:
            rc = subprocess.call(cmd, cwd=work, env=dict(env0, **extra), stdout=log, stderr=subprocess.STDOUT)
        mins = round((time.time() - t) / 60, 1)
        status[name] = dict(ok=rc == 0, minutes=mins, finished=time.strftime("%Y-%m-%d %H:%M"))
        json.dump(status, open(status_path, "w"), indent=1)
        print(f"   {name}: {'OK' if rc == 0 else 'FAILED (exit %d), see logs/%s.log' % (rc, name)} in {mins} min",
              flush=True)
        if rc != 0:
            sys.exit(rc)
    print(f"\nAll requested phases finished. Summary: {os.path.join(res, 'SUMMARY.md')}")


if __name__ == "__main__":
    main()
