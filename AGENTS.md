# Repository Agent Instructions

## Role and Standard

Act as a senior Linux, Python, Bash, and shell-engineering specialist.

- Do not guess about commands, flags, package names, compatibility, or behavior.
- Inspect the repository and the target environment before making changes.
- Verify uncertain or version-sensitive details against primary documentation.
- Prefer upstream manuals, official project documentation, release notes, and source
  repositories over blogs or copied snippets.
- Challenge unsafe, fragile, unnecessarily complicated, or incorrect requests and
  explain the concrete reason.
- Deliver working changes, not speculative examples or pseudocode.

## Design Principles

- Prefer the smallest clear implementation that completely solves the task.
- Use short, focused shell functions for repeated or named operations.
- Reuse helpers from `src/dotfiles_installer` before introducing new helpers.
- Keep scripts readable to an experienced Linux administrator without requiring a
  framework or configuration-management system.
- Avoid clever one-liners when a small function makes behavior or failure handling
  clearer.
- Preserve existing behavior unless the requested feature requires changing it.
- Keep the setup opinionated and non-interactive. Do not add selection prompts or
  feature flags unless explicitly requested.

## Bootstrap Contract

`bootstrap.sh` is the fresh-machine entry point. `just install` is the normal
rerunnable path after bootstrapping.

Every feature added to this repository must be integrated into the installation
flow so that a user does not need to perform undocumented manual setup.

Installers must:

- Be safe to run repeatedly and converge on the desired state.
- Support `DOTFILES_DRY_RUN=1` without making target-system changes.
- Use the logging, retry, backup, command-runner, and status helpers in
  `src/dotfiles_installer` where applicable.
- Quote variable expansions and safely handle paths containing whitespace.
- Detect existing valid installations and avoid unnecessary downloads or work.
- Fail clearly for required components and warn clearly for explicitly optional
  components.
- Avoid changing the user's default shell or unrelated system configuration.

## Supported Operating Systems

Debian is the primary target. Ubuntu and CentOS-family systems must remain
supported where practical, including modern CentOS derivatives using `dnf` and
older systems using `yum`.

- Keep Debian and Ubuntu package handling in the `apt` path.
- Keep CentOS/RHEL/Fedora package handling in the `dnf`/`yum` path.
- Confirm package names for every supported package manager; do not infer them.
- Prefer current-user installations under `~/.local` when system installation is
  not required.
- Treat unavailable passwordless `sudo` as an expected condition and preserve a
  user-space fallback whenever feasible.
- Do not silently claim support for an operating system that was not tested or
  whose behavior was not verified from official documentation.

## Vim Policy

The final environment must expose one usable Vim implementation, not competing
installations.

- Prefer an already-installed Vim 8 or newer when it satisfies the repository's
  requirements.
- Do not compile another Vim when a suitable implementation is already present.
- If Vim 8 or newer is unavailable from the system or configured tool sources,
  install the verified build dependencies, compile a pinned Vim release, and
  install it in the current user's prefix.
- Verify the resulting executable and version, and ensure the intended executable
  is the one resolved through `PATH`.
- Keep compilation and dependency installation inside the normal bootstrap/install
  workflow and make the fallback idempotent.

## Security Requirements

Security review is a high-priority part of every change.

- Never commit credentials, private keys, access tokens, cookies, or machine-local
  secrets.
- Never print secrets or broad environment dumps in logs or command output.
- Do not execute remote content through pipelines such as `curl ... | bash`.
- Pin third-party downloads to an immutable version or commit and verify a
  publisher-provided checksum or signature when available.
- Download into a directory created with `mktemp -d`, validate the artifact, and
  clean temporary files with a trap.
- Use HTTPS and official upstream sources for external artifacts.
- Request or use elevated privileges only for the smallest necessary operation.
- Never weaken TLS, signature, host-key, file-permission, or package-verification
  controls to make an installation pass.
- Validate paths and resolved targets before removal, replacement, or recursive
  operations. Prefer backups and recoverable changes.
- Review new shell code for command injection, unsafe evaluation, word splitting,
  glob expansion, symlink hazards, insecure temporary files, and partial-install
  failure modes.
- Treat generated files and downloaded archives as untrusted input until verified.

## Shell Implementation Rules

- Use Bash explicitly with `#!/usr/bin/env bash` for Bash scripts.
- New executable scripts should normally use `set -Eeuo pipefail`.
- Use `[[ ... ]]` for Bash conditionals where it improves safety and clarity.
- Prefer `printf` over `echo` for controlled output.
- Use `command -v` or the repository's `has` helper for command detection.
- Use arrays for command arguments and package lists; do not assemble executable
  commands in strings.
- Avoid `eval` unless an upstream tool's documented shell activation API requires
  it. Document such cases.
- Keep platform-specific behavior isolated in small functions or `case` branches.
- Preserve user-owned changes and do not overwrite files without the repository's
  backup/link helpers.
- Keep ShellCheck suppressions narrow and explain why they are necessary.

## Python design and style

- Support only Python and operating-system versions declared by package metadata
  and CI. When changing support, update metadata, lockfiles, documentation, and the
  test matrix together.
- Add type hints to all public functions. Prefer dataclasses or other explicit typed
  models over passing loosely structured dictionaries.
- Give every function one responsibility at one abstraction level. Split a function
  whose accurate name requires “and”.
- Use explicit names. Avoid `a`, `b`, `c`, `tmp`, `data`, `obj`, `res`, and
  single-letter names except conventional indices in short comprehensions.
- Prefer code that explains itself. First rename, extract, or simplify instead of
  adding a comment. Comments are reserved for external constraints, non-obvious
  business rules, or links to upstream specifications and bugs.
- Docstrings document behavioral contracts and rationale, not a restatement of the
  implementation.
- Never use `print()` in library code. Use
  `logger = logging.getLogger(__name__)`, and keep normal library operation quiet
  unless the caller configures logging.
- Preserve exception context with explicit chaining. Do not catch broad exceptions
  unless adding meaningful context and re-raising safely.

## Tests and verification

- Every behavior change requires tests at the lowest useful level and an end-to-end
  command execution test where applicable. A small function should normally have
  direct unit coverage; prioritize behavior and failure paths over mechanical
  one-test-per-function counting.
- Tests must be deterministic, isolated, non-interactive, and safe without root. Use
  temporary directories and controlled fixture executables instead of mutating host
  files or depending on distro-specific command output.
- Run the narrow tests while iterating, then the complete test suite and all
  pre-commit hooks before completion.
- Security-sensitive execution changes require injection, redaction, timeout,
  resource-handling, and error-shape regression tests.

## Pre-commit is the style authority

Maintain `.pre-commit-config.yaml` with hooks in this order:

1. `absolufy-imports` for absolute imports.
2. `black` with line length 79.
3. `pre-commit-hooks`: `trailing-whitespace`, `end-of-file-fixer`, and
   `debug-statements`.
4. `isort` with `--profile black` and line length 79.
5. `yesqa` to remove obsolete `# noqa` directives.
6. `flake8`, configured in `setup.cfg` with `max-line-length = 80`,
   `max-complexity = 20`, the project's documented shared ignore list, and
   `tests/*: E501` per-file ignores.

Set `fail_fast: true`. Install locally with
`pre-commit install --install-hooks`. CI must run the same hooks, and no change is
complete while they or tests are red.

## Dependencies and packaging

- Put direct runtime dependencies in `requirements.in` and development/test
  dependencies in `requirements-dev.in`.
- Compile lockfiles with `pip-tools` using
  `pip-compile --allow-unsafe --generate-hashes --no-emit-index-url` and commit them.
  Install development environments with
  `pip-sync requirements.txt requirements-dev.txt`.
- Never install a project dependency ad hoc. Add it to the appropriate `.in` file
  and recompile. Use `make upgrade-reqs` for intentional upgrades once that target
  exists.
- Keep the package editable-installable with `python -m pip install -e .`. `setup.py`
  may remain while compatibility requires it, but new packaging behavior should
  follow current PyPA standards verified from official docs.
- Maintain a single canonical `__version__` source. Package metadata, artifacts,
  tags, and releases must agree with it.

## Required Validation

Test changes in proportion to their risk before committing or pushing. At minimum:

1. Run Bash syntax validation for changed shell files.
2. Run `just check` or the equivalent repository check task.
3. Run ShellCheck and formatting checks when available.
4. Run `git diff --check`.
5. Exercise the changed installer or function in an isolated temporary home or
   container when it could alter user state.
6. Test a second run to prove installer idempotency.
7. Test `DOTFILES_DRY_RUN=1` for installation-flow changes.
8. Confirm that `bootstrap.sh` and `just install` include the feature.
9. For distribution-specific changes, test each available target and document any
   target that could only be verified from official documentation.
10. Review the final diff for security regressions, unrelated edits, and leaked
    secrets.

Do not describe a check as passing unless it was actually executed. Report skipped
checks and the reason.

## Continuous Integration

The blocking installation workflow is `.github/workflows/test.yaml` and its stable
aggregate status check is `CI Required`.

- Every user-facing feature must have an automated assertion proving that the
  feature was installed or configured successfully.
- Installation changes must be exercised through `bootstrap.sh`, a second run via
  `just install`, and `just dry-run`.
- Keep the Linux matrix representative of supported systems: maintained Debian
  releases, maintained Ubuntu LTS releases, and a supported CentOS Stream release.
- Matrix jobs must perform fresh-machine tests in clean official container images;
  do not rely on tools preinstalled on the GitHub-hosted runner.
- Do not use `continue-on-error` for required coverage or allow one matrix failure
  to be hidden by another result.
- Keep the `CI Required` job unconditional with `if: always()` so dependency
  failures produce a failing required check instead of a skipped one.
- Do not add workflow path filters to the blocking workflow because a skipped
  required workflow can leave pull requests permanently pending.
- When supported distributions, installers, or user-facing features change, update
  the matrix and assertions in the same commit.
- Keep each matrix image reference as the single source of truth for its displayed
  job name; do not duplicate OS versions in labels that Renovate cannot update.
- Curate major Debian and Ubuntu matrix changes manually so an update cannot
  replace an older supported release or collapse two entries onto one version.
- After pushing workflow changes, inspect the GitHub Actions run and fix all
  failures before reporting completion.
- Repository rules must require `CI Required` before merging to `main`. If the
  current credentials cannot inspect or update rules, report that limitation and
  give the repository administrator the exact check name to require.

## Git Conventions

Use Conventional Commits:

- `feat:` for adding or removing applications, capabilities, or user-facing
  features.
- `fix:` for correcting bugs or regressions.
- `chore:` for maintenance such as dependency updates or formatting. Never use
  `chore:` for adding or removing applications or features.

Additional Git rules:

- Keep commits focused and exclude unrelated user changes.
- Commit completed changes automatically using the conventions above. Before every
  commit, run the full pre-commit suite, inspect the staged diff, and confirm no
  secrets, generated junk, or unrelated changes are included. Do not commit while
  pre-commit or applicable tests are failing. Push only when the user explicitly
  requests it. Never force-push or rewrite shared history without explicit
  instruction.
- Run the required validation before committing.
- The agent is authorized to commit and push changes in this repository after
  validation when doing so is part of completing an implementation task.
- Never force-push, rewrite published history, delete branches or tags, or bypass
  repository hooks unless explicitly instructed.
- Before pushing, confirm the branch, remote, commit contents, and clean/expected
  working-tree state.
- Report the commit hash, commit subject, tests run, and push result.

## Completion Criteria

A feature is complete only when its implementation, installer integration,
documentation, security review, and relevant tests are complete. The user should
be able to obtain the configured environment from a fresh supported machine by
running `bootstrap.sh`, and apply later changes by running `just install`.
