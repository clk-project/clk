#!/usr/bin/env python3
"""Analyze per-test coverage from coverage.py JSON with contexts.

Reads coverage JSON with --show-contexts and generates:
- Test overlap matrix (HTML and Markdown)
- Line heat map (HTML and Markdown)
"""

import argparse
import json
import sys
from collections import defaultdict
from pathlib import Path


def load_coverage_json(json_path):
    """Load coverage JSON and extract per-test coverage data.

    Returns:
        test_coverages: {test_name: {filename: set(lines)}}
        line_tests: {filename: {line: [test_names]}}
    """
    with open(json_path) as f:
        data = json.load(f)

    test_coverages = defaultdict(lambda: defaultdict(set))
    line_tests = defaultdict(lambda: defaultdict(list))

    for filename, file_data in data.get("files", {}).items():
        contexts = file_data.get("contexts", {})
        for line_str, test_names in contexts.items():
            line = int(line_str)
            for test_name in test_names:
                # Skip empty context (global coverage)
                if not test_name:
                    continue
                test_coverages[test_name][filename].add(line)
                line_tests[filename][line].append(test_name)

    # Convert defaultdicts to regular dicts
    test_coverages = {k: dict(v) for k, v in test_coverages.items()}
    line_tests = {k: dict(v) for k, v in line_tests.items()}

    return test_coverages, line_tests


def coverage_size(cov):
    """Return total number of covered lines."""
    return sum(len(lines) for lines in cov.values())


def coverage_intersection_size(cov_a, cov_b):
    """Return number of lines covered by both."""
    total = 0
    for filename, lines_a in cov_a.items():
        lines_b = cov_b.get(filename, set())
        total += len(lines_a & lines_b)
    return total


def compute_overlap_data(test_coverages):
    """Compute overlap statistics between tests."""
    test_names = sorted(test_coverages.keys())
    sizes = {}
    overlaps = []

    for test_a in test_names:
        cov_a = test_coverages[test_a]
        size_a = coverage_size(cov_a)
        sizes[test_a] = size_a

        for test_b in test_names:
            if test_a >= test_b:
                continue
            cov_b = test_coverages[test_b]
            size_b = coverage_size(cov_b)
            intersection = coverage_intersection_size(cov_a, cov_b)

            if size_a > 0:
                overlap_a = round((intersection / size_a) * 100, 1)
            else:
                overlap_a = 0
            if size_b > 0:
                overlap_b = round((intersection / size_b) * 100, 1)
            else:
                overlap_b = 0

            max_overlap = max(overlap_a, overlap_b)
            if max_overlap >= 50:
                overlaps.append((test_a, test_b, overlap_a, overlap_b, size_a, size_b))

    overlaps.sort(key=lambda x: max(x[2], x[3]), reverse=True)
    return sizes, overlaps


def generate_overlap_markdown(test_coverages, output_path):
    """Generate markdown overlap report."""
    test_names = sorted(test_coverages.keys())
    sizes, overlaps = compute_overlap_data(test_coverages)

    full_subsets = sum(1 for o in overlaps if o[2] >= 100 or o[3] >= 100)
    high_overlaps = sum(1 for o in overlaps if max(o[2], o[3]) >= 75)

    lines = [
        "# Test Coverage Overlap Report",
        "",
        "## Summary",
        "",
        f"- **Total tests:** {len(test_names)}",
        f"- **Full subsets (100%):** {full_subsets}",
        f"- **High overlap (≥75%):** {high_overlaps}",
        f"- **Significant overlap (≥50%):** {len(overlaps)}",
        "",
        "## Full Subsets (100% overlap)",
        "",
        "These tests have coverage completely contained within another test:",
        "",
    ]

    subsets = [
        (a, b, oa, ob, sa, sb)
        for a, b, oa, ob, sa, sb in overlaps
        if oa >= 100 or ob >= 100
    ]
    if subsets:
        lines.append("| Test | Contained In | Lines |")
        lines.append("|------|--------------|-------|")
        for test_a, test_b, overlap_a, overlap_b, size_a, size_b in subsets:
            if overlap_a >= 100:
                lines.append(f"| {test_a} | {test_b} | {size_a} |")
            if overlap_b >= 100:
                lines.append(f"| {test_b} | {test_a} | {size_b} |")
    else:
        lines.append("*None found*")

    lines.extend(
        [
            "",
            "## High Overlap (≥75%)",
            "",
            "| Test A | Test B | A→B % | B→A % | Lines A | Lines B |",
            "|--------|--------|-------|-------|---------|---------|",
        ]
    )

    high = [
        (a, b, oa, ob, sa, sb)
        for a, b, oa, ob, sa, sb in overlaps
        if max(oa, ob) >= 75 and max(oa, ob) < 100
    ]
    for test_a, test_b, overlap_a, overlap_b, size_a, size_b in high[:30]:
        lines.append(
            f"| {test_a} | {test_b} | {overlap_a}% | {overlap_b}% | {size_a} | {size_b} |"
        )

    if len(high) > 30:
        lines.append(f"| ... | *{len(high) - 30} more* | | | | |")

    lines.extend(
        [
            "",
            "## Test Sizes",
            "",
            "| Test | Lines Covered |",
            "|------|---------------|",
        ]
    )

    for test_name in sorted(test_names, key=lambda t: sizes[t], reverse=True)[:20]:
        lines.append(f"| {test_name} | {sizes[test_name]} |")

    if len(test_names) > 20:
        lines.append(f"| ... | *{len(test_names) - 20} more tests* |")

    lines.append("")
    output_path.write_text("\n".join(lines))
    print(f"Generated overlap report: {output_path}")


def generate_overlap_html(test_coverages, output_path):
    """Generate interactive HTML overlap matrix."""
    test_names = sorted(test_coverages.keys())

    # Compute matrix
    matrix_data = []
    sizes = {}
    for test_a in test_names:
        cov_a = test_coverages[test_a]
        size_a = coverage_size(cov_a)
        sizes[test_a] = size_a
        row = []
        for test_b in test_names:
            if test_a == test_b:
                row.append(100.0)
            elif size_a == 0:
                row.append(0.0)
            else:
                cov_b = test_coverages[test_b]
                intersection = coverage_intersection_size(cov_a, cov_b)
                row.append(round((intersection / size_a) * 100, 1))
        matrix_data.append(row)

    html_content = f"""<!DOCTYPE html>
<html>
<head>
    <title>Test Coverage Overlap Matrix</title>
    <style>
        body {{ font-family: monospace; margin: 20px; background: #1a1a2e; color: #eee; }}
        h1 {{ color: #00d4ff; }}
        .controls {{ margin-bottom: 20px; padding: 15px; background: #16213e; border-radius: 8px; }}
        .controls label {{ margin-right: 20px; }}
        .controls select, .controls input {{ padding: 5px; border-radius: 4px; border: 1px solid #444; background: #0f0f23; color: #eee; }}
        #matrix-container {{ overflow: auto; max-height: 80vh; }}
        table {{ border-collapse: collapse; font-size: 10px; }}
        th, td {{ padding: 2px 4px; text-align: center; border: 1px solid #333; min-width: 25px; }}
        th {{ background: #16213e; position: sticky; top: 0; z-index: 10; }}
        th.row-header {{ position: sticky; left: 0; z-index: 5; text-align: right; padding-right: 8px; max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }}
        th.corner {{ position: sticky; top: 0; left: 0; z-index: 15; }}
        .cell {{ cursor: pointer; }}
        .cell:hover {{ outline: 2px solid #fff; }}
        .highlight-row {{ background: rgba(0, 212, 255, 0.15) !important; }}
        .highlight-col {{ background: rgba(0, 212, 255, 0.15) !important; }}
        th.highlight-row, th.highlight-col {{ background: #1e5a7e !important; }}
        .highlight-row.highlight-col {{ background: rgba(0, 212, 255, 0.3) !important; }}
        #tooltip {{ position: fixed; background: #16213e; border: 1px solid #00d4ff; padding: 10px; border-radius: 4px; pointer-events: none; display: none; z-index: 1000; max-width: 400px; }}
        .legend {{ display: flex; align-items: center; gap: 10px; margin-top: 10px; }}
        .legend-gradient {{ width: 200px; height: 20px; background: linear-gradient(to right, #1e3a5f, #2e8b57, #b8860b, #c41e3a); border-radius: 4px; }}
        .stats {{ margin-top: 20px; padding: 15px; background: #16213e; border-radius: 8px; }}
    </style>
</head>
<body>
    <h1>Test Coverage Overlap Matrix</h1>
    <div class="controls">
        <label>Sort rows/columns by: <select id="sort-select">
            <option value="name">Name</option>
            <option value="size">Coverage Size</option>
            <option value="overlap" selected>Total Overlap</option>
        </select></label>
        <label>Min overlap %: <input type="number" id="min-overlap" value="0" min="0" max="100" step="10"></label>
        <div class="legend">
            <span>0%</span><div class="legend-gradient"></div><span>100%</span>
            <span style="margin-left: 20px;">Cell = % of row's lines also covered by column</span>
            <span style="margin-left: 20px; color: #00d4ff;">Click a cell to highlight its row and column</span>
        </div>
    </div>
    <div id="matrix-container"><table id="matrix"></table></div>
    <div id="tooltip"></div>
    <div class="stats"><h3>Statistics</h3><div id="stats-content"></div></div>
    <script>
    const testNames = {json.dumps(test_names)};
    const matrixData = {json.dumps(matrix_data)};
    const sizes = {json.dumps(sizes)};
    let currentOrder = [...Array(testNames.length).keys()];

    function getColor(value) {{
        if (value >= 100) return '#c41e3a';
        if (value >= 75) return '#b8860b';
        if (value >= 50) return '#2e8b57';
        if (value >= 25) return '#1e3a5f';
        return '#0f0f23';
    }}

    function renderMatrix() {{
        const table = document.getElementById('matrix');
        const minOverlap = parseFloat(document.getElementById('min-overlap').value) || 0;
        let html = '<tr><th class="corner"></th>';
        for (const i of currentOrder) html += `<th title="${{testNames[i]}}">${{testNames[i].split(':')[1] || testNames[i]}}</th>`;
        html += '</tr>';
        for (const i of currentOrder) {{
            html += `<tr><th class="row-header" title="${{testNames[i]}}">${{testNames[i]}}</th>`;
            for (const j of currentOrder) {{
                const val = matrixData[i][j];
                const belowThreshold = val < minOverlap && i !== j;
                const color = belowThreshold ? '#333' : getColor(val);
                const display = belowThreshold ? '' : val.toFixed(0);
                html += `<td class="cell" style="background:${{color}}" data-i="${{i}}" data-j="${{j}}">${{display}}</td>`;
            }}
            html += '</tr>';
        }}
        table.innerHTML = html;
        let totalPairs = 0, highOverlap = 0, fullSubsets = 0;
        for (const i of currentOrder) for (const j of currentOrder) if (i !== j) {{
            totalPairs++;
            if (matrixData[i][j] >= 75) highOverlap++;
            if (matrixData[i][j] >= 100) fullSubsets++;
        }}
        document.getElementById('stats-content').innerHTML = `<p>Tests: ${{currentOrder.length}}</p><p>High overlap (&ge;75%): ${{highOverlap}}</p><p>Full subsets (100%): ${{fullSubsets}}</p>`;
    }}

    function clusterByOverlap() {{
        const remaining = new Set(currentOrder);
        const result = [];
        let best = null, bestTotal = -1;
        for (const idx of remaining) {{
            let total = 0;
            for (let j = 0; j < testNames.length; j++) if (idx !== j) total += matrixData[idx][j];
            if (total > bestTotal) {{ bestTotal = total; best = idx; }}
        }}
        result.push(best); remaining.delete(best);
        while (remaining.size > 0) {{
            const last = result[result.length - 1];
            let bestNext = null, bestSim = -1;
            for (const idx of remaining) {{
                const sim = (matrixData[last][idx] + matrixData[idx][last]) / 2;
                if (sim > bestSim) {{ bestSim = sim; bestNext = idx; }}
            }}
            result.push(bestNext); remaining.delete(bestNext);
        }}
        return result;
    }}

    function sortBy(criterion) {{
        if (criterion === 'name') currentOrder.sort((a, b) => testNames[a].localeCompare(testNames[b]));
        else if (criterion === 'size') currentOrder.sort((a, b) => sizes[testNames[b]] - sizes[testNames[a]]);
        else if (criterion === 'overlap') currentOrder = clusterByOverlap();
        renderMatrix();
    }}

    document.getElementById('sort-select').addEventListener('change', e => sortBy(e.target.value));
    document.getElementById('min-overlap').addEventListener('change', renderMatrix);

    const tooltip = document.getElementById('tooltip');
    document.getElementById('matrix').addEventListener('mousemove', e => {{
        if (e.target.classList.contains('cell')) {{
            const i = parseInt(e.target.dataset.i), j = parseInt(e.target.dataset.j);
            tooltip.innerHTML = `<strong>${{testNames[i]}}</strong><br>covered by <strong>${{testNames[j]}}</strong><br><br>Overlap: ${{matrixData[i][j].toFixed(1)}}%<br>Row: ${{sizes[testNames[i]]}} lines<br>Col: ${{sizes[testNames[j]]}} lines`;
            tooltip.style.display = 'block';
            tooltip.style.left = (e.clientX + 15) + 'px';
            tooltip.style.top = (e.clientY + 15) + 'px';
        }}
    }});
    document.getElementById('matrix').addEventListener('mouseout', e => {{ if (e.target.classList.contains('cell')) tooltip.style.display = 'none'; }});

    let highlightedRow = null;
    let highlightedCol = null;

    function clearHighlights() {{
        document.querySelectorAll('.highlight-row, .highlight-col').forEach(el => {{
            el.classList.remove('highlight-row', 'highlight-col');
        }});
        highlightedRow = null;
        highlightedCol = null;
    }}

    function highlightRowCol(rowIdx, colIdx) {{
        clearHighlights();
        if (rowIdx === null && colIdx === null) return;

        highlightedRow = rowIdx;
        highlightedCol = colIdx;

        const table = document.getElementById('matrix');
        const rows = table.querySelectorAll('tr');

        // Find position of rowIdx and colIdx in currentOrder
        const rowPos = currentOrder.indexOf(rowIdx);
        const colPos = currentOrder.indexOf(colIdx);

        rows.forEach((row, rIndex) => {{
            if (rIndex === 0) {{
                // Header row - highlight column header
                const ths = row.querySelectorAll('th');
                if (colPos >= 0 && colPos + 1 < ths.length) {{
                    ths[colPos + 1].classList.add('highlight-col');
                }}
            }} else {{
                const cells = row.querySelectorAll('th, td');
                // Highlight row header if this is the selected row
                if (rIndex === rowPos + 1) {{
                    cells[0].classList.add('highlight-row');
                    // Highlight all cells in this row
                    cells.forEach((cell, cIndex) => {{
                        if (cIndex > 0) cell.classList.add('highlight-row');
                    }});
                }}
                // Highlight column cells
                if (colPos >= 0 && colPos + 1 < cells.length) {{
                    cells[colPos + 1].classList.add('highlight-col');
                }}
            }}
        }});
    }}

    document.getElementById('matrix').addEventListener('click', e => {{
        if (e.target.classList.contains('cell')) {{
            const i = parseInt(e.target.dataset.i), j = parseInt(e.target.dataset.j);
            // Toggle: if clicking same cell, clear; otherwise highlight new
            if (highlightedRow === i && highlightedCol === j) {{
                clearHighlights();
            }} else {{
                highlightRowCol(i, j);
            }}
        }}
    }});

    sortBy('overlap');
    </script>
</body>
</html>
"""
    output_path.write_text(html_content)
    print(f"Generated overlap matrix: {output_path}")


def generate_line_heat_markdown(line_tests, total_tests, output_path):
    """Generate markdown line heat map."""
    file_stats = []
    total_hot_lines = 0
    total_lines = 0

    for filename, lines in sorted(line_tests.items()):
        hot_lines = 0
        for line_num, tests in lines.items():
            total_lines += 1
            if len(tests) == total_tests:
                hot_lines += 1
                total_hot_lines += 1
        file_stats.append((filename, len(lines), hot_lines))

    file_stats.sort(key=lambda x: x[2], reverse=True)

    md_lines = [
        "# Line Heat Map",
        "",
        "## Summary",
        "",
        f"- **Total tests:** {total_tests}",
        f"- **Total covered lines:** {total_lines}",
        f"- **Hot lines (covered by all tests):** {total_hot_lines}",
        "",
        'Lines covered by all tests are "hot" - likely core/init code.',
        "",
        "## Files by Hot Lines",
        "",
        "| File | Lines | Hot Lines | Hot % |",
        "|------|-------|-----------|-------|",
    ]

    for filename, num_lines, hot_lines in file_stats[:30]:
        if hot_lines > 0:
            hot_pct = round(hot_lines / num_lines * 100, 1)
            md_lines.append(f"| {filename} | {num_lines} | {hot_lines} | {hot_pct}% |")

    md_lines.extend(
        [
            "",
            "## Hot Lines Detail",
            "",
            "Lines covered by every test (top 5 files):",
            "",
        ]
    )

    shown = 0
    for filename, lines in sorted(line_tests.items()):
        hot_line_nums = []
        for line_num, tests in sorted(lines.items()):
            if len(tests) == total_tests:
                hot_line_nums.append(line_num)

        if hot_line_nums and shown < 5:
            md_lines.append(f"### {filename}")
            md_lines.append("")
            ranges = []
            start = hot_line_nums[0]
            end = start
            for ln in hot_line_nums[1:]:
                if ln == end + 1:
                    end = ln
                else:
                    ranges.append(f"{start}-{end}" if start != end else str(start))
                    start = end = ln
            ranges.append(f"{start}-{end}" if start != end else str(start))
            md_lines.append(
                f"Lines: {', '.join(ranges[:20])}"
                + (" ..." if len(ranges) > 20 else "")
            )
            md_lines.append("")
            shown += 1

    md_lines.append("")
    output_path.write_text("\n".join(md_lines))
    print(f"Generated line heat map: {output_path}")


def read_source_file(filename, source_root=None):
    """Read source file, trying path mappings if needed."""
    # Try direct path first
    path = Path(filename)
    if path.exists():
        return path.read_text().splitlines()

    # Try mapping /app/clk/ to source_root/clk/
    if source_root and filename.startswith("/app/"):
        mapped = source_root / filename[5:]  # Remove "/app/"
        if mapped.exists():
            return mapped.read_text().splitlines()

    # Try relative to current directory
    if filename.startswith("/app/"):
        relative = filename[5:]  # Remove "/app/"
        if Path(relative).exists():
            return Path(relative).read_text().splitlines()

    return None


def generate_line_heat_html(line_tests, total_tests, output_path, source_root=None):
    """Generate interactive HTML line heat map with source code."""
    files_data = []

    for filename, lines in sorted(line_tests.items()):
        # Try to read source file
        source_lines = read_source_file(filename, source_root)

        lines_data = []
        for line_num, tests in sorted(lines.items()):
            heat = len(tests)
            pct = round(heat / total_tests * 100, 1)

            # Get source code for this line if available
            source_code = ""
            if source_lines and 1 <= line_num <= len(source_lines):
                source_code = source_lines[line_num - 1]

            lines_data.append(
                {
                    "num": line_num,
                    "heat": heat,
                    "pct": pct,
                    "tests": sorted(set(tests)),
                    "code": source_code,
                }
            )

        hot_lines = sum(1 for line in lines_data if line["pct"] == 100)
        files_data.append(
            {
                "name": filename,
                "lines": lines_data,
                "hot_lines": hot_lines,
                "has_source": source_lines is not None,
            }
        )

    # Escape for JSON embedding
    files_json = json.dumps(files_data)

    html_content = f"""<!DOCTYPE html>
<html>
<head>
    <title>Line Heat Map</title>
    <style>
        body {{ font-family: monospace; margin: 20px; background: #1a1a2e; color: #eee; }}
        h1 {{ color: #00d4ff; }}
        .controls {{ margin-bottom: 20px; padding: 15px; background: #16213e; border-radius: 8px; position: sticky; top: 0; z-index: 100; }}
        .controls label {{ margin-right: 20px; }}
        .controls select, .controls input {{ padding: 5px; border-radius: 4px; border: 1px solid #444; background: #0f0f23; color: #eee; }}
        .controls button {{ padding: 5px 10px; border-radius: 4px; border: 1px solid #444; background: #0f0f23; color: #eee; cursor: pointer; margin-left: 10px; }}
        .controls button:hover {{ background: #1e3a5f; }}
        .file-section {{ margin-bottom: 30px; background: #16213e; border-radius: 8px; overflow: hidden; }}
        .file-header {{ padding: 10px 15px; background: #0f0f23; cursor: pointer; display: flex; justify-content: space-between; }}
        .file-header:hover {{ background: #1e3a5f; }}
        .file-name {{ font-weight: bold; color: #00d4ff; }}
        .file-stats {{ color: #888; font-size: 12px; }}
        .file-content {{ display: none; overflow-x: auto; }}
        .file-content.expanded {{ display: block; }}
        table {{ width: 100%; border-collapse: collapse; font-size: 12px; }}
        tr {{ border-bottom: 1px solid #333; }}
        tr:hover {{ background: rgba(255,255,255,0.1); }}
        td {{ padding: 2px 8px; vertical-align: top; white-space: pre; }}
        .line-num {{ color: #666; text-align: right; width: 50px; user-select: none; }}
        .heat {{ text-align: center; width: 90px; font-weight: bold; }}
        .code {{ color: #ccc; font-family: 'Consolas', 'Monaco', monospace; overflow-x: auto; }}
        .tests-preview {{ font-size: 10px; color: #888; max-width: 300px; overflow: hidden; text-overflow: ellipsis; }}
        #tooltip {{ position: fixed; background: #16213e; border: 1px solid #00d4ff; padding: 10px; border-radius: 4px; pointer-events: none; display: none; z-index: 1000; max-width: 500px; max-height: 400px; overflow-y: auto; font-size: 11px; }}
        .legend {{ display: flex; align-items: center; gap: 10px; }}
        .legend-gradient {{ width: 200px; height: 20px; background: linear-gradient(to right, #1e3a5f, #2e8b57, #b8860b, #c41e3a); border-radius: 4px; }}
        .summary {{ margin-bottom: 20px; padding: 15px; background: #16213e; border-radius: 8px; }}
        .no-source {{ color: #888; font-style: italic; }}
    </style>
</head>
<body>
    <h1>Line Heat Map</h1>
    <div class="summary">
        <p>Total tests: {total_tests} | Heat = % of tests covering this line | Hover for test list</p>
    </div>
    <div class="controls">
        <label>Min heat %: <input type="number" id="min-heat" value="0" min="0" max="100" step="10"></label>
        <label>File filter: <input type="text" id="file-filter" placeholder="e.g. core"></label>
        <label><input type="checkbox" id="only-hot"> Only ≥80% lines</label>
        <button onclick="expandAll()">Expand All</button>
        <button onclick="collapseAll()">Collapse All</button>
        <div class="legend" style="margin-top:10px"><span>0%</span><div class="legend-gradient"></div><span>100%</span></div>
    </div>
    <div id="files-container"></div>
    <div id="tooltip"></div>
    <script>
    const filesData = {files_json};

    function escapeHtml(text) {{
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }}

    function getColor(pct) {{
        if (pct >= 100) return '#c41e3a';
        if (pct >= 75) return '#b8860b';
        if (pct >= 50) return '#2e8b57';
        if (pct >= 25) return '#1e3a5f';
        return '#0f0f23';
    }}

    function renderFiles() {{
        const container = document.getElementById('files-container');
        const minHeat = parseFloat(document.getElementById('min-heat').value) || 0;
        const fileFilter = document.getElementById('file-filter').value.toLowerCase();
        const onlyHot = document.getElementById('only-hot').checked;
        const hotThreshold = onlyHot ? 80 : 0;
        let html = '';
        for (const file of filesData) {{
            if (fileFilter && !file.name.toLowerCase().includes(fileFilter)) continue;
            const filteredLines = file.lines.filter(l => l.pct >= Math.max(minHeat, hotThreshold));
            if (filteredLines.length === 0) continue;
            const hotCount = file.lines.filter(l => l.pct >= 80).length;
            html += `<div class="file-section"><div class="file-header" onclick="this.nextElementSibling.classList.toggle('expanded')"><span class="file-name">${{file.name}}</span><span class="file-stats">${{filteredLines.length}} lines shown, ${{hotCount}} hot (≥80%)</span></div><div class="file-content"><table>`;
            for (const line of filteredLines) {{
                const codeHtml = line.code ? escapeHtml(line.code) : '<span class="no-source">(source not available)</span>';
                const preview = line.tests.slice(0, 2).join(', ') + (line.tests.length > 2 ? ` +${{line.tests.length-2}}` : '');
                html += `<tr data-tests='${{JSON.stringify(line.tests)}}'><td class="line-num">${{line.num}}</td><td class="heat" style="background:${{getColor(line.pct)}}">${{line.heat}}/${{filesData.length > 0 ? line.tests.length : '?'}} (${{line.pct}}%)</td><td class="code">${{codeHtml}}</td><td class="tests-preview">${{preview}}</td></tr>`;
            }}
            html += '</table></div></div>';
        }}
        container.innerHTML = html || '<p>No matching lines.</p>';
    }}

    function expandAll() {{ document.querySelectorAll('.file-content').forEach(el => el.classList.add('expanded')); }}
    function collapseAll() {{ document.querySelectorAll('.file-content').forEach(el => el.classList.remove('expanded')); }}

    const tooltip = document.getElementById('tooltip');
    document.getElementById('files-container').addEventListener('mousemove', e => {{
        const row = e.target.closest('tr');
        if (row && row.dataset.tests) {{
            const tests = JSON.parse(row.dataset.tests);
            tooltip.innerHTML = '<strong>Tests (' + tests.length + '):</strong><br>' + tests.join('<br>');
            tooltip.style.display = 'block';
            tooltip.style.left = (e.clientX + 15) + 'px';
            tooltip.style.top = (e.clientY + 15) + 'px';
        }}
    }});
    document.getElementById('files-container').addEventListener('mouseout', e => {{ if (e.target.closest('tr')) tooltip.style.display = 'none'; }});

    document.getElementById('min-heat').addEventListener('change', renderFiles);
    document.getElementById('file-filter').addEventListener('input', renderFiles);
    document.getElementById('only-hot').addEventListener('change', renderFiles);
    renderFiles();
    </script>
</body>
</html>
"""
    output_path.write_text(html_content)
    print(f"Generated line heat map: {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Analyze coverage JSON with contexts")
    parser.add_argument(
        "coverage_json", type=Path, help="coverage.py JSON file with --show-contexts"
    )
    parser.add_argument(
        "--overlap-md", type=Path, help="Output overlap report (Markdown)"
    )
    parser.add_argument(
        "--overlap-html", type=Path, help="Output overlap matrix (HTML)"
    )
    parser.add_argument(
        "--line-heat-md", type=Path, help="Output line heat map (Markdown)"
    )
    parser.add_argument(
        "--line-heat-html", type=Path, help="Output line heat map (HTML)"
    )
    parser.add_argument(
        "--source-root",
        type=Path,
        help="Root directory for source files (for path mapping)",
    )
    args = parser.parse_args()

    if not args.coverage_json.exists():
        print(f"Error: {args.coverage_json} not found", file=sys.stderr)
        sys.exit(1)

    print(f"Loading {args.coverage_json}...")
    test_coverages, line_tests = load_coverage_json(args.coverage_json)
    print(f"Found {len(test_coverages)} tests")

    if args.overlap_md:
        generate_overlap_markdown(test_coverages, args.overlap_md)

    if args.overlap_html:
        generate_overlap_html(test_coverages, args.overlap_html)

    if args.line_heat_md:
        generate_line_heat_markdown(line_tests, len(test_coverages), args.line_heat_md)

    if args.line_heat_html:
        generate_line_heat_html(
            line_tests, len(test_coverages), args.line_heat_html, args.source_root
        )


if __name__ == "__main__":
    main()
