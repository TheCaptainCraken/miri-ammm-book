"""Run every verification script of the book and report which pass.

    cd verify && python3 run_all.py

Each script asserts the numbers printed in the book (exact rational arithmetic,
CPLEX through docplex, or brute force).  A failing assertion stops that script
and is reported here as FAIL.  CPLEX Community Edition (pip install cplex docplex)
is enough: all models are small.
"""
import pathlib
import subprocess
import sys
import time

here = pathlib.Path(__file__).parent
scripts = sorted(p for p in here.glob("v*.py"))
failed = []
for p in scripts:
    t = time.time()
    r = subprocess.run([sys.executable, p.name], cwd=here, capture_output=True, text=True)
    status = "ok  " if r.returncode == 0 else "FAIL"
    print(f"{status} {p.name:28s} {time.time() - t:6.1f} s")
    if r.returncode != 0:
        failed.append(p.name)
        print("     " + "\n     ".join((r.stdout + r.stderr).strip().splitlines()[-8:]))
print()
print("all checks passed" if not failed else f"{len(failed)} script(s) failed: {', '.join(failed)}")
sys.exit(1 if failed else 0)
