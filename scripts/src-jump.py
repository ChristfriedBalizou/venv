#!/usr/bin/env python3

import argparse
import difflib
import shutil
import subprocess
import sys
from pathlib import Path


def clean_name(path: Path) -> str:
    name = path.name
    if name.endswith(".git"):
        return name[:-4]
    return name


def directories(root: Path, max_depth: int) -> list[Path]:
    if max_depth < 1:
        return []

    found: list[Path] = []
    stack: list[tuple[Path, int]] = [(root, 0)]

    while stack:
        current, depth = stack.pop()
        if depth >= max_depth:
            continue

        try:
            children = sorted(
                child for child in current.iterdir() if child.is_dir()
            )
        except OSError:
            continue

        for child in children:
            found.append(child)
            stack.append((child, depth + 1))

    return sorted(
        found,
        key=lambda path: (len(path.relative_to(root).parts), str(path)),
    )


def prefix_match(candidates: list[Path], query: str) -> Path | None:
    lowered_query = query.lower()

    for candidate in candidates:
        names = (candidate.name.lower(), clean_name(candidate).lower())
        if any(name.startswith(lowered_query) for name in names):
            return candidate

    return None


def fzf_match(candidates: list[Path], query: str) -> Path | None:
    if not shutil.which("fzf"):
        return None

    candidate_text = "\n".join(str(candidate) for candidate in candidates)
    result = subprocess.run(
        ["fzf", "--filter", query, "--select-1", "--exit-0"],
        input=candidate_text,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )

    first_match = result.stdout.splitlines()[0] if result.stdout else ""
    return Path(first_match) if first_match else None


def fuzzy_match(candidates: list[Path], query: str) -> Path | None:
    best_candidate: Path | None = None
    best_score = 0.0

    for candidate in candidates:
        names = (clean_name(candidate), str(candidate))
        score = max(
            difflib.SequenceMatcher(
                None,
                query.lower(),
                name.lower(),
            ).ratio()
            for name in names
        )
        if score > best_score:
            best_score = score
            best_candidate = candidate

    return best_candidate if best_score >= 0.45 else None


def best_match(root: Path, query: str, max_depth: int) -> Path | None:
    candidates = directories(root, max_depth)
    match = prefix_match(candidates, query)
    match = match or fzf_match(candidates, query)
    match = match or fuzzy_match(candidates, query)

    return match


def cd_jump(root: Path, queries: list[str]) -> int:
    root = root.expanduser().resolve()

    if not root.is_dir():
        print(f"Directory does not exist: {root}", file=sys.stderr)
        return 1

    if not queries:
        print(root)
        return 0

    destination = root

    for index, query in enumerate(queries):
        search_depth = len(queries) - index
        match = best_match(destination, query, search_depth)

        if not match:
            if index == 0:
                print(
                    f"No directory matching '{query}' under {destination}",
                    file=sys.stderr,
                )
                return 1
            break

        destination = match

    print(destination)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Print the best matching directory for shell cd shortcuts."
    )
    parser.add_argument("root")
    parser.add_argument("queries", nargs="*")
    args = parser.parse_args()

    return cd_jump(Path(args.root), args.queries)


if __name__ == "__main__":
    raise SystemExit(main())
