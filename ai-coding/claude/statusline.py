#!/usr/bin/env python3
"""Ring Meter statusline for Claude Code."""
import json
import os
import shutil
import subprocess
import sys
import time

R = "\033[0m"
DIM = "\033[2m"
BOLD = "\033[1m"
RINGS = ["○", "◔", "◑", "◕", "●"]


def gradient(pct):
    if pct < 50:
        r = int(pct * 5.1)
        return f"\033[38;2;{r};200;80m"
    g = int(200 - (pct - 50) * 4)
    return f"\033[38;2;255;{max(g, 0)};60m"


def ring(pct):
    return RINGS[min(int(pct / 25), 4)]


def fmt(label, pct):
    p = round(pct)
    return f"{label} {gradient(pct)}{ring(pct)} {p}%{R}"


def fmt_reset(resets_at):
    remaining = int(resets_at - time.time())
    if remaining <= 0:
        return None
    h, rem = divmod(remaining, 3600)
    m = rem // 60
    local_time = time.strftime("%H:%M", time.localtime(resets_at))
    return f"~{h}h{m:02d}m({local_time})"


def fetch_ccusage():
    blocks_data = run_ccusage_json(["blocks", "--json", "--active"])
    monthly_data = run_ccusage_json(["monthly", "--json"])

    active = None
    for block in blocks_data.get("blocks", []):
        if block.get("isActive"):
            active = block
            break
    if active is None:
        sys.stderr.write("ERROR: No active ccusage block found\n")
        sys.exit(1)

    session_cost = active.get("costUSD", 0)

    current_month = time.strftime("%Y-%m")
    monthly_cost = 0
    for entry in monthly_data.get("monthly", []):
        if entry.get("month") == current_month:
            monthly_cost = entry.get("totalCost", 0)
            break

    return session_cost, monthly_cost


def run_ccusage_json(args):
    npx = shutil.which("npx")
    if npx is None:
        sys.stderr.write("ERROR: npx not found. Install Node.js/npm or ensure npx is on PATH.\n")
        sys.exit(1)

    command = [npx, "ccusage", *args]
    label = " ".join(args)
    try:
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=15,
            check=False,
        )
    except FileNotFoundError as exc:
        sys.stderr.write(f"ERROR: failed to start npx: {exc}\n")
        sys.exit(1)
    except subprocess.TimeoutExpired:
        sys.stderr.write(f"ERROR: ccusage {label} timed out\n")
        sys.exit(1)

    if result.returncode != 0:
        stderr = result.stderr.decode(errors="replace").strip()
        stdout = result.stdout.decode(errors="replace").strip()
        detail = stderr or stdout or f"exit code {result.returncode}"
        sys.stderr.write(f"ERROR: ccusage {label} failed: {detail}\n")
        sys.exit(1)

    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        sys.stderr.write(f"ERROR: ccusage {label} returned invalid JSON: {exc}\n")
        sys.exit(1)


def main():
    if sys.platform == "win32":
        sys.stdout.reconfigure(encoding="utf-8")

    data = json.load(sys.stdin)

    # Project + branch
    project_dir = data.get("workspace", {}).get("project_dir") or data.get("cwd", "")
    project_name = os.path.basename(project_dir) if project_dir else "unknown"
    try:
        branch = subprocess.check_output(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        branch = ""
    if branch:
        parts = [f"📁 {project_name}({branch})"]
    else:
        parts = [f"📁 {project_name}"]

    model = data.get("model", {}).get("display_name", "Claude")
    parts.append(f"🤖 {BOLD}{model}{R}")

    # Cost
    session_cost, monthly_cost = fetch_ccusage()
    parts.append(f"💵 ${session_cost:.2f}/${monthly_cost:.2f}")

    # Context window
    ctx_pct = data.get("context_window", {}).get("used_percentage")
    if ctx_pct is not None:
        parts.append(fmt("ctx", ctx_pct))

    # Rate limits
    rate_limits = data.get("rate_limits", {})

    five_hour = rate_limits.get("five_hour", {})
    five_pct = five_hour.get("used_percentage")
    if five_pct is not None:
        parts.append(fmt("5h", five_pct))

    seven_day = rate_limits.get("seven_day", {})
    week_pct = seven_day.get("used_percentage")
    if week_pct is not None:
        parts.append(fmt("7d", week_pct))

    # Reset time
    resets_at = five_hour.get("resets_at")
    if resets_at is not None:
        reset_str = fmt_reset(resets_at)
        if reset_str:
            parts.append(f"⏱️  {reset_str}")

    SEP = " │ "
    print(SEP.join(parts), end="")


if __name__ == "__main__":
    main()
