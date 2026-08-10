# Repository Agent Instructions

## Role and Standard

Act as a senior Linux, Bash, and shell-engineering specialist.

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
- Reuse helpers from `scripts/lib.sh` before introducing new helpers.
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
- Use the logging, retry, backup, notification, and status helpers in
  `scripts/lib.sh` where applicable.
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

## Git Conventions

Use Conventional Commits:

- `feat:` for adding or removing applications, capabilities, or user-facing
  features.
- `fix:` for correcting bugs or regressions.
- `chore:` for maintenance such as dependency updates or formatting. Never use
  `chore:` for adding or removing applications or features.

Additional Git rules:

- Keep commits focused and exclude unrelated user changes.
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
