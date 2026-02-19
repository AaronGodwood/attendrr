#!/usr/bin/env python3
"""
Augment Dart lcov files with synthetic FN/FNDA/FNF/FNH entries.

Flutter's default coverage output usually contains only DA (line) records.
genhtml then shows function coverage as blank. This script derives function
entries from Dart source declarations and line hits so function summaries render.
"""

from __future__ import annotations

import argparse
import os
import re
from typing import Dict, List, Tuple

FUNC_DECL_RE = re.compile(
    r"""
    ^\s*
    (?:[\w<>\[\]\?,\s]+\s+)?            # optional return type / modifiers
    (?P<name>[A-Za-z_]\w*)              # function/method name
    \s*\([^;]*\)\s*                     # parameter list
    (?:(?:async|sync)(?:\*)?\s*)?       # optional async/sync
    (?:=>|\{)\s*$                       # body opener
    """,
    re.VERBOSE,
)

GETTER_RE = re.compile(
    r"^\s*(?:[\w<>\[\]\?,\s]+\s+)?get\s+(?P<name>[A-Za-z_]\w*)\s*(?:=>|\{)\s*$"
)

CTOR_RE = re.compile(
    r"^\s*(?P<name>[A-Z][A-Za-z0-9_]*)\s*\([^;]*\)\s*(?::[^{]*)?\{\s*$"
)

SKIP_NAMES = {
    "if",
    "for",
    "while",
    "switch",
    "catch",
    "return",
    "assert",
}


def read_lines(path: str) -> List[str]:
    with open(path, "r", encoding="utf-8") as f:
        return f.read().splitlines()


def parse_da(lines: List[str]) -> Dict[int, int]:
    da: Dict[int, int] = {}
    for line in lines:
        if line.startswith("DA:"):
            parts = line[3:].split(",")
            if len(parts) >= 2:
                try:
                    ln = int(parts[0])
                    hit = int(parts[1])
                    da[ln] = hit
                except ValueError:
                    pass
    return da


def detect_functions(source_path: str) -> List[Tuple[int, str]]:
    if not source_path.endswith(".dart") or not os.path.exists(source_path):
        return []
    source = read_lines(source_path)
    funcs: List[Tuple[int, str]] = []
    for i, raw in enumerate(source, start=1):
        line = raw.strip()
        if (
            not line
            or line.startswith("//")
            or line.startswith("*")
            or line.startswith("@")
        ):
            continue

        m = GETTER_RE.match(raw) or FUNC_DECL_RE.match(raw) or CTOR_RE.match(raw)
        if not m:
            continue
        name = m.group("name")
        if name in SKIP_NAMES:
            continue
        funcs.append((i, name))
    return funcs


def function_hits(
    funcs: List[Tuple[int, str]], da: Dict[int, int], max_line: int
) -> List[Tuple[int, str, int]]:
    if not funcs:
        return []
    funcs_sorted = sorted(funcs, key=lambda x: x[0])
    out: List[Tuple[int, str, int]] = []
    for idx, (start, name) in enumerate(funcs_sorted):
        end = funcs_sorted[idx + 1][0] - 1 if idx + 1 < len(funcs_sorted) else max_line
        hit = 0
        for ln in range(start, end + 1):
            if da.get(ln, 0) > 0:
                hit = 1
                break
        out.append((start, f"{name}_L{start}", hit))
    return out


def augment_record(sf: str, record_lines: List[str], root: str) -> List[str]:
    has_fn = any(l.startswith("FN:") for l in record_lines)
    if has_fn:
        return record_lines

    da = parse_da(record_lines)
    if not da:
        return record_lines

    source_path = sf
    if not os.path.isabs(source_path):
        source_path = os.path.join(root, source_path)

    funcs = detect_functions(source_path)
    if not funcs:
        return record_lines

    max_line = max(da.keys())
    fn_hits = function_hits(funcs, da, max_line)
    if not fn_hits:
        return record_lines

    output: List[str] = []
    inserted = False
    fnf = len(fn_hits)
    fnh = sum(1 for _, _, h in fn_hits if h > 0)

    for line in record_lines:
        if not inserted and (line.startswith("DA:") or line.startswith("LH:")):
            for ln, name, hit in fn_hits:
                output.append(f"FN:{ln},{name}")
                output.append(f"FNDA:{hit},{name}")
            output.append(f"FNF:{fnf}")
            output.append(f"FNH:{fnh}")
            inserted = True
        output.append(line)

    if not inserted:
        for ln, name, hit in fn_hits:
            output.append(f"FN:{ln},{name}")
            output.append(f"FNDA:{hit},{name}")
        output.append(f"FNF:{fnf}")
        output.append(f"FNH:{fnh}")
    return output


def augment_lcov(in_path: str, out_path: str, root: str) -> None:
    lines = read_lines(in_path)
    out: List[str] = []

    sf = None
    record: List[str] = []
    in_record = False

    for line in lines:
        if line.startswith("SF:"):
            if in_record and sf is not None:
                out.extend(augment_record(sf, record, root))
                out.append("end_of_record")
            sf = line[3:]
            record = [line]
            in_record = True
        elif line == "end_of_record":
            if in_record and sf is not None:
                out.extend(augment_record(sf, record, root))
                out.append("end_of_record")
            sf = None
            record = []
            in_record = False
        else:
            if in_record:
                record.append(line)
            else:
                out.append(line)

    if in_record and sf is not None:
        out.extend(augment_record(sf, record, root))
        out.append("end_of_record")

    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(out) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--in", dest="in_path", required=True, help="Input lcov.info")
    parser.add_argument(
        "--out", dest="out_path", required=True, help="Output lcov.info"
    )
    parser.add_argument(
        "--root", default=".", help="Project root for resolving SF paths"
    )
    args = parser.parse_args()
    augment_lcov(args.in_path, args.out_path, args.root)


if __name__ == "__main__":
    main()
