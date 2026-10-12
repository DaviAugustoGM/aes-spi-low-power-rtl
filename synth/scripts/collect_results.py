#!/usr/bin/env python3
"""Coleta QoR de síntese e gera CSV comparável entre runs.

Lê os reports crus do Design Compiler depois que a licença já pode ter sido
liberada. Consolida timing (setup/hold), área, power e runtime.
"""

from __future__ import annotations

import argparse
import csv
import math
import re
from pathlib import Path
from typing import Dict, Iterable, Optional, Tuple

FLOAT = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"


def read_text(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def first_float(pattern: str, text: str) -> Optional[float]:
    m = re.search(pattern, text, flags=re.IGNORECASE | re.MULTILINE)
    if not m:
        return None
    try:
        return float(m.group(1))
    except (TypeError, ValueError):
        return None


def first_int(pattern: str, text: str) -> Optional[int]:
    value = first_float(pattern, text)
    return None if value is None else int(round(value))


def parse_metadata(run_dir: Path) -> Dict[str, str]:
    data: Dict[str, str] = {}
    for line in read_text(run_dir / "run_metadata.txt").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            data[key.strip()] = value.strip()
    return data


def infer_metadata_from_name(run_dir: Path) -> Dict[str, str]:
    m = re.fullmatch(r"P(?P<period>[0-9p.]+)_(?P<mode>.+)", run_dir.name)
    if not m:
        return {}
    period = m.group("period").replace("p", ".")
    try:
        frequency = 1000.0 / float(period)
    except ValueError:
        frequency = math.nan
    return {
        "period_ns": period,
        "frequency_mhz": "" if math.isnan(frequency) else str(frequency),
        "mode": m.group("mode"),
    }


def power_value_uw(label: str, text: str) -> Optional[float]:
    m = re.search(
        rf"^\s*{re.escape(label)}\s*=\s*({FLOAT})\s*(pW|nW|uW|mW|W)\b",
        text,
        flags=re.IGNORECASE | re.MULTILINE,
    )
    if not m:
        return None
    value = float(m.group(1))
    unit = m.group(2).lower()
    factors = {"pw": 1e-6, "nw": 1e-3, "uw": 1.0, "mw": 1e3, "w": 1e6}
    return value * factors[unit]


def parse_run(run_dir: Path) -> Dict[str, object]:
    reports = run_dir / "reports"
    qor = read_text(reports / "qor.rpt")
    area = read_text(reports / "area.rpt")
    power = read_text(reports / "power.rpt")
    timing_setup = read_text(reports / "timing_setup.rpt")
    timing_hold = read_text(reports / "timing_hold.rpt")

    metadata = infer_metadata_from_name(run_dir)
    metadata.update(parse_metadata(run_dir))

    setup_wns = first_float(r"Critical\s+Path\s+Slack:\s*(%s)" % FLOAT, qor)
    setup_tns = first_float(r"Total\s+Negative\s+Slack:\s*(%s)" % FLOAT, qor)
    setup_vpaths = first_int(r"No\.\s+of\s+Violating\s+Paths:\s*(%s)" % FLOAT, qor)

    hold_wns = first_float(r"Worst\s+Hold\s+Violation:\s*(%s)" % FLOAT, qor)
    hold_tns = first_float(r"Total\s+Hold\s+Violation:\s*(%s)" % FLOAT, qor)
    hold_vpaths = first_int(r"No\.\s+of\s+Hold\s+Violations:\s*(%s)" % FLOAT, qor)

    if setup_wns is None:
        setup_wns = first_float(r"^\s*slack\s+\((?:MET|VIOLATED)\)\s*(%s)" % FLOAT, timing_setup)
    if hold_wns is None:
        hold_wns = first_float(r"^\s*slack\s+\((?:MET|VIOLATED)\)\s*(%s)" % FLOAT, timing_hold)

    drv_violating_nets = first_int(r"Nets\s+With\s+Violations:\s*(%s)" % FLOAT, qor)
    cell_area = first_float(r"^\s*Cell\s+Area:\s*(%s)" % FLOAT, qor)
    design_area = first_float(r"^\s*Design\s+Area:\s*(%s)" % FLOAT, qor)
    if cell_area is None:
        cell_area = first_float(r"^\s*Total\s+cell\s+area:\s*(%s)" % FLOAT, area)
    if design_area is None:
        design_area = first_float(r"^\s*Total\s+area:\s*(%s)" % FLOAT, area)

    dynamic_uw = power_value_uw("Total Dynamic Power", power)
    leakage_uw = power_value_uw("Cell Leakage Power", power)
    total_power_uw = None
    if dynamic_uw is not None and leakage_uw is not None:
        total_power_uw = round(dynamic_uw + leakage_uw, 9)

    compile_wall_s = first_float(r"Overall\s+Compile\s+Wall\s+Clock\s+Time:\s*(%s)" % FLOAT, qor)
    compile_cpu_s = first_float(r"Overall\s+Compile\s+Time:\s*(%s)" % FLOAT, qor)

    setup_status = "UNKNOWN" if setup_wns is None else ("PASS" if setup_wns >= 0.0 else "VIOLATED")
    hold_status = "UNKNOWN" if hold_wns is None else ("PASS" if hold_wns >= 0.0 else "VIOLATED")
    if "UNKNOWN" in (setup_status, hold_status):
        timing_status = "UNKNOWN"
    elif setup_status == "PASS" and hold_status == "PASS":
        timing_status = "PASS"
    else:
        timing_status = "VIOLATED"

    if timing_status == "UNKNOWN" or drv_violating_nets is None:
        qor_status = "UNKNOWN"
    elif timing_status == "PASS" and drv_violating_nets == 0:
        qor_status = "PASS"
    else:
        qor_status = "VIOLATED"

    return {
        "run": run_dir.name,
        "project": metadata.get("project", ""),
        "top": metadata.get("top", ""),
        "technology": metadata.get("technology", ""),
        "period_ns": metadata.get("period_ns", ""),
        "frequency_mhz": metadata.get("frequency_mhz", ""),
        "mode": metadata.get("mode", ""),
        "preset": metadata.get("preset", ""),
        "input_source": metadata.get("input_source", ""),
        "retiming_pass": metadata.get("retiming_pass", ""),
        "power_activity": metadata.get("power_activity", ""),
        "max_opcond": metadata.get("max_operating_condition", ""),
        "min_opcond": metadata.get("min_operating_condition", ""),
        "saif_file": metadata.get("saif_file", ""),
        "setup_status": setup_status,
        "setup_wns_ns": setup_wns,
        "setup_tns_ns": setup_tns,
        "setup_violating_paths": setup_vpaths,
        "hold_status": hold_status,
        "hold_wns_ns": hold_wns,
        "hold_tns_ns": hold_tns,
        "hold_violating_paths": hold_vpaths,
        "cell_area": cell_area,
        "design_area": design_area,
        "dynamic_power_uw": dynamic_uw,
        "leakage_power_uw": leakage_uw,
        "total_power_uw": total_power_uw,
        "compile_cpu_s": compile_cpu_s,
        "compile_wall_s": compile_wall_s,
        "drv_violating_nets": drv_violating_nets,
        "timing_status": timing_status,
        "qor_status": qor_status,
    }


def discover_runs(input_dir: Path) -> Iterable[Path]:
    single_reports = input_dir / "reports"
    if (input_dir / "run_metadata.txt").exists() or (
        single_reports.is_dir() and any(single_reports.glob("*.rpt"))
    ):
        yield input_dir
        return

    if not input_dir.exists():
        return

    found = set()
    for metadata_file in input_dir.rglob("run_metadata.txt"):
        run_dir = metadata_file.parent
        if run_dir not in found:
            found.add(run_dir)
            yield run_dir

    for reports in input_dir.rglob("reports"):
        if not reports.is_dir() or not any(reports.glob("*.rpt")):
            continue
        run_dir = reports.parent
        if run_dir not in found:
            found.add(run_dir)
            yield run_dir


def sort_key(row: Dict[str, object]):
    try:
        period = float(row.get("period_ns") or math.inf)
    except (TypeError, ValueError):
        period = math.inf
    return (str(row.get("preset", "")), str(row.get("mode", "")), -period, str(row.get("run", "")))


def csv_value(value: object) -> object:
    return "" if value is None else value


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()

    runs = list(discover_runs(args.input))
    if not runs:
        raise SystemExit(f"Nenhum run/report de síntese encontrado sob: {args.input}")

    rows = [parse_run(run) for run in runs]
    rows.sort(key=sort_key)

    fieldnames = [
        "run", "project", "top", "technology", "period_ns", "frequency_mhz",
        "mode", "preset", "input_source", "retiming_pass", "power_activity",
        "max_opcond", "min_opcond", "saif_file",
        "setup_status", "setup_wns_ns", "setup_tns_ns", "setup_violating_paths",
        "hold_status", "hold_wns_ns", "hold_tns_ns", "hold_violating_paths",
        "cell_area", "design_area", "dynamic_power_uw", "leakage_power_uw",
        "total_power_uw", "compile_cpu_s", "compile_wall_s",
        "drv_violating_nets", "timing_status", "qor_status",
    ]

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", newline="", encoding="utf-8") as fp:
        writer = csv.DictWriter(fp, fieldnames=fieldnames)
        writer.writeheader()
        for row in rows:
            writer.writerow({key: csv_value(row.get(key)) for key in fieldnames})

    passed = sum(row["qor_status"] == "PASS" for row in rows)
    violated = sum(row["qor_status"] == "VIOLATED" for row in rows)
    unknown = len(rows) - passed - violated
    print(f"Resumo gerado: {args.output}")
    print(f"Runs: {len(rows)} | QoR PASS: {passed} | VIOLATED: {violated} | UNKNOWN: {unknown}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
