#!/usr/bin/env python3
"""Ring Meter statusline for Claude Code."""
import json
import os
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
    proc_blocks = subprocess.Popen(
        ["npx", "ccusage", "blocks", "--json", "--active"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    proc_monthly = subprocess.Popen(
        ["npx", "ccusage", "monthly", "--json"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

    blocks_out, blocks_err = proc_blocks.communicate(timeout=15)
    if proc_blocks.returncode != 0:
        sys.stderr.write(f"ERROR: ccusage blocks failed: {blocks_err.decode()}\n")
        sys.exit(1)

    monthly_out, monthly_err = proc_monthly.communicate(timeout=15)
    if proc_monthly.returncode != 0:
        sys.stderr.write(f"ERROR: ccusage monthly failed: {monthly_err.decode()}\n")
        sys.exit(1)

    blocks_data = json.loads(blocks_out)
    monthly_data = json.loads(monthly_out)

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
    parts.append(f"{BOLD}{model}{R}")

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
