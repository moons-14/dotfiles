#!/usr/bin/env python3
"""Change-aware, non-activating validation for this Nix dotfiles repository."""

from __future__ import annotations

import argparse
from collections import defaultdict, deque
from contextlib import contextmanager
import io
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import sys
import tarfile
import tempfile
import tomllib
from typing import Any, Iterator, Sequence

GLOBAL_FILES = {"flake.nix", "flake.lock", "hosts/default.nix"}
GLOBAL_PREFIXES = ("flake/", "libs/", "overlays/")
FULL_EVAL_PREFIXES = GLOBAL_PREFIXES + ("scripts/", "shells/", "tests/")
FULL_BUILD_PREFIXES = GLOBAL_PREFIXES + ("scripts/", "shells/", "tests/")
DOC_SUFFIXES = (".md", ".png", ".jpg", ".jpeg", ".webp")


class ValidationError(RuntimeError):
    pass


def command_text(command: Sequence[str]) -> str:
    return " ".join(json.dumps(part) if any(c.isspace() for c in part) else part for part in command)


def run(
    command: Sequence[str],
    *,
    cwd: Path,
    capture: bool = False,
    check: bool = True,
    input_text: str | None = None,
) -> subprocess.CompletedProcess[str]:
    print(f"+ {command_text(command)}", file=sys.stderr)
    return subprocess.run(
        list(command),
        cwd=cwd,
        check=check,
        text=True,
        input=input_text,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def git(root: Path, *args: str, check: bool = True) -> str:
    return run(["git", *args], cwd=root, capture=True, check=check).stdout


def repo_root() -> Path:
    return Path(run(["git", "rev-parse", "--show-toplevel"], cwd=Path.cwd(), capture=True).stdout.strip()).resolve()


def normalize(root: Path, raw: str) -> str:
    candidate = Path(raw)
    absolute = candidate.resolve() if candidate.is_absolute() else (root / candidate).resolve()
    try:
        return absolute.relative_to(root).as_posix()
    except ValueError as error:
        raise ValidationError(f"path escapes repository root: {raw}") from error


def nonempty_lines(value: str) -> list[str]:
    return [line for line in value.splitlines() if line]


def tracked_paths(root: Path) -> set[str]:
    return set(nonempty_lines(git(root, "ls-files")))


def untracked_paths(root: Path) -> set[str]:
    return set(nonempty_lines(git(root, "ls-files", "--others", "--exclude-standard")))


def expand_paths(root: Path, raw_paths: Sequence[str], available: set[str]) -> list[str]:
    result: set[str] = set()
    for raw in raw_paths:
        relative = normalize(root, raw)
        target = root / relative
        if target.is_dir():
            prefix = f"{relative.rstrip('/')}/" if relative else ""
            result.update(path for path in available if path.startswith(prefix))
        else:
            result.add(relative)
    return sorted(result)


def collect_paths(root: Path, args: argparse.Namespace) -> tuple[list[str], set[str]]:
    tracked = tracked_paths(root)
    untracked = untracked_paths(root)
    if args.paths:
        paths = expand_paths(root, args.paths, tracked | untracked)
    elif args.all_files:
        paths = sorted(tracked)
    elif args.base:
        paths = nonempty_lines(
            git(root, "diff", "--name-only", "--no-renames", "--diff-filter=ACMRTUXBD", f"{args.base}...HEAD", "--")
        )
    else:
        paths = nonempty_lines(git(root, "diff", "--name-only", "--no-renames", "--diff-filter=ACMRTUXBD", "HEAD", "--"))
        paths += sorted(untracked)
    return sorted(set(paths)), untracked


def remove_path(path: Path) -> None:
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.is_dir():
        shutil.rmtree(path)


@contextmanager
def flake_reference(root: Path, changed: Sequence[str]) -> Iterator[str]:
    """Create a clean HEAD snapshot and overlay only task-owned worktree paths."""
    with tempfile.TemporaryDirectory(prefix="dotfiles-flake-") as temporary:
        source = Path(temporary) / "source"
        source.mkdir()
        archive = subprocess.run(
            ["git", "archive", "--format=tar", "HEAD"],
            cwd=root,
            check=True,
            stdout=subprocess.PIPE,
        ).stdout
        with tarfile.open(fileobj=io.BytesIO(archive), mode="r:") as tar:
            tar.extractall(source, filter="data")
        for relative in changed:
            src, dst = root / relative, source / relative
            remove_path(dst)
            if src.is_symlink():
                dst.parent.mkdir(parents=True, exist_ok=True)
                dst.symlink_to(os.readlink(src))
            elif src.is_file():
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, dst)
        yield f"path:{source}"


def load_metadata(root: Path, reference: str) -> dict[str, Any]:
    result = run(
        ["nix", "eval", "--json", "--show-trace", f"{reference}#lib.validationMetadata"],
        cwd=root,
        capture=True,
    )
    metadata = json.loads(result.stdout)
    if metadata.get("schemaVersion") != 1:
        raise ValidationError("unsupported validation metadata schema")
    return metadata


def reverse_dependencies(units: dict[str, Any]) -> dict[str, set[str]]:
    result: dict[str, set[str]] = defaultdict(set)
    for unit_id, unit in units.items():
        for dependency in unit.get("includes", []):
            result[dependency].add(unit_id)
    return result


def users_of(unit_id: str, reverse: dict[str, set[str]]) -> set[str]:
    result, queue = {unit_id}, deque([unit_id])
    while queue:
        for dependent in reverse.get(queue.popleft(), set()):
            if dependent not in result:
                result.add(dependent)
                queue.append(dependent)
    return result


def owner_for(path: str, units: dict[str, Any]) -> str | None:
    matches = []
    for unit_id, unit in units.items():
        directory = unit["directory"].rstrip("/")
        if path == directory or path.startswith(f"{directory}/"):
            matches.append((len(directory), unit_id))
    return max(matches)[1] if matches else None


def path_classes(path: str, unit: dict[str, Any]) -> set[str]:
    directory = unit["directory"].rstrip("/")
    relative = path[len(directory) :].lstrip("/")
    if relative == "nixos.nix" or relative == "home/nixos.nix":
        return {"nixos"}
    if relative == "darwin.nix" or relative == "home/darwin.nix":
        return {"darwin"}
    if relative == "meta.nix":
        return {"nixos", "darwin"}
    if relative in {"common.nix", "home.nix", "home/common.nix"}:
        return {"nixos", "darwin"}
    fragments = set(unit.get("fragments", []))
    classes: set[str] = set()
    if fragments & {"common", "nixos", "home", "homeCommon", "homeNixos"}:
        classes.add("nixos")
    if fragments & {"common", "darwin", "home", "homeCommon", "homeDarwin"}:
        classes.add("darwin")
    return classes or {"nixos", "darwin"}


def is_docs_only(path: str) -> bool:
    return path.endswith(DOC_SUFFIXES)


def plan(metadata: dict[str, Any], paths: Sequence[str], *, all_hosts: bool = False) -> dict[str, Any]:
    hosts: dict[str, Any] = metadata["hosts"]
    units: dict[str, Any] = metadata["units"]
    reverse = reverse_dependencies(units)
    affected_units: set[str] = set()
    unit_classes: dict[str, set[str]] = defaultdict(set)
    affected_hosts = {"nixos": set(), "darwin": set()}
    global_change = all_hosts
    requires_full_eval = False
    requires_full_build = False
    requires_nix = False

    for path in paths:
        if path in GLOBAL_FILES or path.startswith(GLOBAL_PREFIXES):
            global_change = True
            requires_nix = True
        if path.startswith(FULL_EVAL_PREFIXES) or path in GLOBAL_FILES:
            requires_full_eval = True
        if path.startswith(FULL_BUILD_PREFIXES) or path in {"flake.nix", "flake.lock"}:
            requires_full_build = True
        if path.endswith(".nix") or path == "flake.lock":
            requires_nix = True
        if path == "scripts/dotfiles-check.py":
            requires_nix = requires_full_eval = requires_full_build = True

        if path.startswith("hosts/") and path != "hosts/default.nix":
            parts = PurePosixPath(path).parts
            if len(parts) > 1 and parts[1] in hosts:
                affected_hosts[hosts[parts[1]]["kind"]].add(parts[1])
                requires_nix = True

        owner = owner_for(path, units)
        if owner:
            classes = path_classes(path, units[owner])
            for unit_id in users_of(owner, reverse):
                affected_units.add(unit_id)
                unit_classes[unit_id].update(classes)
            requires_nix = requires_nix or not is_docs_only(path)
        elif path.startswith("modules/") and not is_docs_only(path):
            global_change = True
            requires_nix = True

    if global_change:
        for name, host in hosts.items():
            affected_hosts[host["kind"]].add(name)
    else:
        for name, host in hosts.items():
            selected = set(host["selectedUnits"])
            if any(unit_id in selected and host["kind"] in unit_classes[unit_id] for unit_id in affected_units):
                affected_hosts[host["kind"]].add(name)

    synthetic = {"nixos": set(), "darwin": set()}
    for unit_id in affected_units:
        for kind in unit_classes[unit_id]:
            if not any(unit_id in hosts[name]["selectedUnits"] for name in affected_hosts[kind]):
                synthetic[kind].add(unit_id)

    systems = sorted({host["system"] for host in hosts.values()})
    native_systems = {system: False for system in systems}
    if requires_full_build:
        native_systems = {system: requires_nix for system in systems}
    else:
        for kind, names in affected_hosts.items():
            for name in names:
                native_systems[hosts[name]["system"]] = True
        for kind, unit_ids in synthetic.items():
            if unit_ids:
                candidates = sorted(host["system"] for host in hosts.values() if host["kind"] == kind)
                if candidates:
                    native_systems[candidates[0]] = True

    return {
        "schemaVersion": 1,
        "paths": sorted(paths),
        "affectedUnits": sorted(affected_units),
        "affectedHosts": {kind: sorted(names) for kind, names in affected_hosts.items()},
        "syntheticUnits": {kind: sorted(names) for kind, names in synthetic.items()},
        "requiresNixValidation": requires_nix,
        "requiresFullEvaluation": requires_full_eval,
        "requiresFullNativeBuild": requires_full_build,
        "nativeBuildSystems": native_systems,
    }


def render_plan(value: dict[str, Any], reference: str) -> None:
    print(f"flake: {reference}")
    print("paths:", ", ".join(value["paths"]) or "(none)")
    print("units:", ", ".join(value["affectedUnits"]) or "(none)")
    for kind in ("nixos", "darwin"):
        print(f"{kind} hosts:", ", ".join(value["affectedHosts"][kind]) or "(none)")
        print(f"{kind} synthetic:", ", ".join(value["syntheticUnits"][kind]) or "(none)")
    print("full evaluation:", value["requiresFullEvaluation"])
    print("full native build:", value["requiresFullNativeBuild"])


def validate_skill(path: Path) -> None:
    text = path.read_text()
    if not text.startswith("---\n"):
        raise ValidationError(f"missing Skill frontmatter: {path}")
    try:
        frontmatter = text.split("---\n", 2)[1]
        name = next(line.split(":", 1)[1].strip() for line in frontmatter.splitlines() if line.startswith("name:"))
    except (IndexError, StopIteration) as error:
        raise ValidationError(f"invalid Skill frontmatter: {path}") from error
    if name != path.parent.name:
        raise ValidationError(f"Skill name {name!r} does not match directory {path.parent.name!r}")


def static_checks(root: Path, paths: Sequence[str], untracked: set[str]) -> None:
    for relative in paths:
        path = root / relative
        if not path.is_file():
            continue
        if relative.endswith(".nix"):
            run(["nix-instantiate", "--parse", str(path)], cwd=root, capture=True)
        elif relative.endswith(".json"):
            json.loads(path.read_text())
        elif relative.endswith(".toml"):
            tomllib.loads(path.read_text())
        elif relative.endswith(".py"):
            compile(path.read_text(), relative, "exec")
        if path.name == "SKILL.md":
            validate_skill(path)
        if relative in untracked:
            for number, line in enumerate(path.read_text(errors="replace").splitlines(), 1):
                if line.rstrip() != line:
                    raise ValidationError(f"trailing whitespace: {relative}:{number}")

    diff_paths = [path for path in paths if path not in untracked]
    if diff_paths:
        run(["git", "diff", "--check", "HEAD", "--", *diff_paths], cwd=root)


def run_fast(root: Path, reference: str, paths: Sequence[str], untracked: set[str], *, all_files: bool) -> None:
    static_checks(root, paths, untracked)
    command = ["nix", "develop", f"{reference}#validation", "--command", "pre-commit", "run"]
    command += ["--all-files"] if all_files else (["--files", *paths] if paths else [])
    if paths or all_files:
        run(command, cwd=root)


def selection_module_expr(unit_id: str) -> str:
    quoted = json.dumps(unit_id)
    return f"(flake.lib.registry.mkSelectionModule [ {quoted} ])"


def synthetic_expr(reference: str, host_name: str, host: dict[str, Any], unit_id: str, *, drv_path: bool) -> str:
    selection = selection_module_expr(unit_id)
    modules = [selection]
    if host.get("homeManager", True):
        user = json.dumps(host["user"])
        modules.append(f"{{ home-manager.users.{user}.imports = [ {selection} ]; }}")
    base = f"flake.{('darwinConfigurations' if host['kind'] == 'darwin' else 'nixosConfigurations')}.{json.dumps(host_name)}"
    output = "extended.system" if host["kind"] == "darwin" else "extended.config.system.build.toplevel"
    if drv_path:
        output += ".drvPath"
    return f'''let
  flake = builtins.getFlake {json.dumps(reference)};
  base = {base};
  extended = base.extendModules {{ modules = [ {' '.join(modules)} ]; }};
in {output}'''


def representative_host(metadata: dict[str, Any], kind: str, current_system: str | None = None) -> tuple[str, dict[str, Any]] | None:
    candidates = [(name, host) for name, host in metadata["hosts"].items() if host["kind"] == kind]
    if current_system:
        candidates = [item for item in candidates if item[1]["system"] == current_system]
    return sorted(candidates)[0] if candidates else None


def host_drv_attr(reference: str, host: dict[str, Any]) -> str:
    return f"{reference}#{host['buildAttr']}.drvPath"


def run_eval(
    root: Path,
    reference: str,
    metadata: dict[str, Any],
    value: dict[str, Any],
    *,
    all_systems: bool,
) -> None:
    if all_systems or value["requiresFullEvaluation"]:
        run(["nix", "flake", "check", reference, "--no-build", "--all-systems", "--keep-going", "--show-trace"], cwd=root)
        return
    for kind in ("nixos", "darwin"):
        for name in value["affectedHosts"][kind]:
            run(["nix", "eval", "--raw", "--show-trace", host_drv_attr(reference, metadata["hosts"][name])], cwd=root)
        representative = representative_host(metadata, kind)
        if representative:
            name, host = representative
            for unit_id in value["syntheticUnits"][kind]:
                run(["nix", "eval", "--raw", "--impure", "--show-trace", "--expr", synthetic_expr(reference, name, host, unit_id, drv_path=True)], cwd=root)


def current_system(root: Path) -> str:
    return run(["nix", "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"], cwd=root, capture=True).stdout.strip()


def run_full_native(root: Path, reference: str, system: str) -> None:
    run(
        ["nix", "run", f"{reference}#nix-fast-build", "--", "--flake", f"{reference}#checks.{system}", "--skip-cached", "--no-nom", "--no-link"],
        cwd=root,
    )


def run_build(root: Path, reference: str, metadata: dict[str, Any], value: dict[str, Any]) -> None:
    system = current_system(root)
    if value["requiresFullNativeBuild"]:
        run_full_native(root, reference, system)
        return

    installables: list[str] = []
    for kind in ("nixos", "darwin"):
        for name in value["affectedHosts"][kind]:
            host = metadata["hosts"][name]
            if host["system"] == system:
                installables.append(f"{reference}#{host['buildAttr']}")
            else:
                print(f"skip incompatible build: {name} ({host['system']})", file=sys.stderr)
    for check in ("registry", "validation-tool"):
        installables.append(f"{reference}#checks.{system}.{check}")
    if installables:
        run(["nix", "build", "--no-link", "--keep-going", "--print-build-logs", *sorted(set(installables))], cwd=root)

    for kind in ("nixos", "darwin"):
        representative = representative_host(metadata, kind, system)
        if representative:
            name, host = representative
            for unit_id in value["syntheticUnits"][kind]:
                run(["nix", "build", "--no-link", "--impure", "--expr", synthetic_expr(reference, name, host, unit_id, drv_path=False)], cwd=root)


def self_test() -> None:
    metadata = {
        "schemaVersion": 1,
        "units": {
            "applications.foo": {"directory": "modules/applications/foo", "includes": [], "fragments": ["home", "homeNixos"]},
            "applications.dormant": {"directory": "modules/applications/dormant", "includes": [], "fragments": ["home"]},
            "profiles.workload.dev": {"directory": "modules/profiles/workload/dev", "includes": ["applications.foo"], "fragments": ["meta"]},
        },
        "hosts": {
            "linux": {"kind": "nixos", "system": "x86_64-linux", "user": "test", "homeManager": True, "selectedUnits": ["profiles.workload.dev"], "buildAttr": "nixosConfigurations.linux.config.system.build.toplevel"},
            "mac": {"kind": "darwin", "system": "aarch64-darwin", "user": "test", "homeManager": True, "selectedUnits": ["profiles.workload.dev"], "buildAttr": "darwinConfigurations.mac.system"},
        },
    }
    nixos = plan(metadata, ["modules/applications/foo/home/nixos.nix"])
    assert nixos["affectedHosts"] == {"nixos": ["linux"], "darwin": []}
    assert nixos["affectedUnits"] == ["applications.foo", "profiles.workload.dev"]
    common = plan(metadata, ["modules/applications/foo/home.nix"])
    assert common["affectedHosts"] == {"nixos": ["linux"], "darwin": ["mac"]}
    dormant = plan(metadata, ["modules/applications/dormant/home.nix"])
    assert dormant["syntheticUnits"] == {"nixos": ["applications.dormant"], "darwin": ["applications.dormant"]}
    global_value = plan(metadata, ["flake.nix"])
    assert global_value["requiresFullEvaluation"] and global_value["requiresFullNativeBuild"]
    docs = plan(metadata, ["modules/profiles/README.md"])
    assert not docs["requiresNixValidation"]
    print("dotfiles-check self-test passed")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("command", choices=("plan", "fast", "eval", "build", "all", "full", "self-test"))
    result.add_argument("--paths", nargs="+", help="Explicit task-owned repository paths")
    result.add_argument("--base", help="Compare BASE...HEAD")
    result.add_argument("--all-files", action="store_true", help="Check every tracked file")
    result.add_argument("--all-hosts", action="store_true", help="Validate every registered host")
    result.add_argument("--all-systems", action="store_true", help="Evaluate every flake system")
    result.add_argument("--json", action="store_true", help="Emit the plan as JSON")
    return result


def main() -> int:
    args = parser().parse_args()
    if args.command == "self-test":
        self_test()
        return 0
    selectors = sum(bool(value) for value in (args.paths, args.base, args.all_files))
    if selectors > 1:
        raise ValidationError("use only one of --paths, --base, or --all-files")
    if args.command == "full":
        if selectors or args.all_hosts or args.all_systems:
            raise ValidationError("full is exhaustive and accepts no scope flags")
        args.all_files = args.all_hosts = args.all_systems = True

    root = repo_root()
    paths, untracked = collect_paths(root, args)
    with flake_reference(root, paths) as reference:
        metadata = load_metadata(root, reference)
        value = plan(metadata, paths, all_hosts=args.all_hosts)
        if args.command == "plan":
            print(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True)) if args.json else render_plan(value, reference)
            return 0
        if args.command in {"fast", "all", "full"}:
            run_fast(root, reference, paths, untracked, all_files=args.all_files)
        if args.command in {"eval", "all", "full"} and value["requiresNixValidation"]:
            run_eval(root, reference, metadata, value, all_systems=args.all_systems or args.command in {"all", "full"})
        if args.command in {"build", "all"} and value["requiresNixValidation"]:
            run_build(root, reference, metadata, value)
        if args.command == "full":
            run_full_native(root, reference, current_system(root))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValidationError as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(2) from error
    except subprocess.CalledProcessError as error:
        if error.stdout:
            print(error.stdout, file=sys.stderr, end="")
        if error.stderr:
            print(error.stderr, file=sys.stderr, end="")
        raise SystemExit(error.returncode) from error
