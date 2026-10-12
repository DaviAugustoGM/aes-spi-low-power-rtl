#!/usr/bin/env python3
"""Portable entry point. Run from any directory; outputs stay under build/."""
import argparse
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def files(manifest):
    result = []
    for line in (ROOT / manifest).read_text().splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        if line.startswith('-f '):
            result.extend(files(line[3:]))
        else:
            path = ROOT / line
            if not path.is_file():
                raise SystemExit(f'Missing source: {path}')
            result.append(str(path))
    return result

def run(command, directory):
    print('Running:', ' '.join(map(str, command)), flush=True)
    subprocess.run(command, cwd=directory, check=True)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['check', 'lint', 'sim', 'smoke'])
    parser.add_argument('--simulator', choices=['auto', 'iverilog', 'vcs'], default='auto')
    args = parser.parse_args()
    rtl = files('rtl/files.f')
    sources = files('sim/files.f')
    if args.action == 'check':
        print(f'File lists OK: {len(rtl)} RTL sources, {len(sources)} simulation sources.')
        return
    build = ROOT / 'build' / 'sim'
    build.mkdir(parents=True, exist_ok=True)
    if args.action in ('lint', 'smoke'):
        if not shutil.which('verilator'):
            raise SystemExit('Install Verilator and add it to PATH for lint/smoke.')
        run(['verilator', '--lint-only', '--top-module', 'aes_spi_top', '-Wall', *rtl], build)
    if args.action in ('sim', 'smoke'):
        simulator = args.simulator
        if simulator == 'auto':
            simulator = next((s for s in ('iverilog', 'vcs') if shutil.which(s)), None)
        if simulator is None or not shutil.which(simulator):
            raise SystemExit('Install Icarus Verilog or configure VCS in PATH.')
        if simulator == 'iverilog':
            if not shutil.which('vvp'):
                raise SystemExit('vvp is required with Icarus Verilog.')
            run(['iverilog', '-g2012', '-Wall', '-s', 'tb_smoke', '-o', 'simv', *sources], build)
            run(['vvp', 'simv'], build)
        else:
            run(['vcs', '-full64', '-sverilog', '-timescale=1ns/1ps', '-top', 'tb_smoke', '-o', 'simv', *sources], build)
            run([str(build / 'simv')], build)

if __name__ == '__main__':
    main()
