{
  inputs,
  pkgs,
  ...
}:
{
  programs.opencode = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

    # Project-specific tools should normally come from that project's dev shell.
    extraPackages = with pkgs; [
      fd
      git
      jq
      ripgrep
    ];

    settings = {
      model = "openai/gpt-5.6-sol";
      small_model = "opencode-go/deepseek-v4-flash";
      default_agent = "orchestrator";
      subagent_depth = 1;

      autoupdate = false;
      share = "disabled";

      compaction = {
        auto = true;
        prune = true;
        reserved = 10000;
      };

      # Fallback for built-in or newly-added agents. The custom agents below
      # override this in their Markdown frontmatter.
      permission = {
        "*" = "ask";
        question = "allow";
      };
    };

    agents = {
      orchestrator = ''
        ---
        description: "Technical lead that plans and delegates all repository operations"
        mode: primary
        model: openai/gpt-5.6-sol
        steps: 14
        reasoningEffort: medium
        textVerbosity: low
        permission:
          "*": deny
          question: allow
          task:
            "*": deny
            explore-cheap: allow
            implement-cheap: allow
            verify-cheap: allow
        ---

        You are the technical lead and the only expensive model in this workflow.
        Do not read repository files, edit files, or run shell commands yourself.
        Obtain repository evidence through subagents and keep raw logs out of your
        own context.

        For each non-trivial coding task:

        1. Define explicit, testable acceptance criteria.
        2. Ask `explore-cheap` for the smallest relevant code surface, constraints,
           existing conventions, and suitable verification commands.
        3. Decide the design yourself.
        4. Give `implement-cheap` one bounded implementation task.
        5. Ask `verify-cheap` to inspect the real diff and verify it independently.
        6. On failure, request one focused repair and verify again. Stop after two
           failed repair cycles and explain the concrete blocker.

        Keep architecture, public APIs, authentication, authorization, migrations,
        and security-boundary decisions at this level. Never run two write-capable
        tasks concurrently in the same worktree.

        Require subagents to return:

        status: PASS | FAIL | INCONCLUSIVE
        summary: at most 8 concise lines
        files_touched: paths or none
        commands_run: exact command and exit code
        acceptance_criteria: criterion plus PASS | FAIL | NOT_CHECKED
        evidence: file, symbol, and concise observation
        unresolved_risks: risks or none
        recommended_next_action: exactly one action
      '';

      explore-cheap = ''
        ---
        description: "Cheap read-only repository and dependency reconnaissance"
        mode: subagent
        hidden: true
        model: opencode-go/deepseek-v4-flash
        steps: 10
        permission:
          "*": deny
          read:
            "*": allow
            "*.env": ask
            "*.env.*": ask
            "*.env.example": allow
          glob: allow
          grep: allow
          list: allow
          lsp: allow
          webfetch: allow
          websearch: allow
          question: allow
          external_directory: ask
        ---

        Perform read-only reconnaissance. Return only concrete file paths, symbols,
        execution flow, existing patterns, repository instructions, and the narrowest
        useful checks. Do not edit files, run shell commands, dump entire files, or
        propose unrelated refactors. Clearly separate observed evidence from inference.
        Use the parent-requested handoff and stay under 700 words.
      '';

      implement-cheap = ''
        ---
        description: "Cheap worker that implements one bounded change and runs checks"
        mode: subagent
        hidden: true
        model: opencode-go/kimi-k2.7-code
        steps: 28
        permission:
          "*": deny
          read:
            "*": allow
            "*.env": ask
            "*.env.*": ask
            "*.env.example": allow
          edit:
            "*": allow
            "*.env": ask
            "*.env.*": ask
            "*.env.example": allow
            ".opencode/*": ask
            "*opencode.json*": ask
            "*AGENTS.md": ask
            ".github/workflows/*": ask
          glob: allow
          grep: allow
          list: allow
          lsp: allow
          webfetch: allow
          websearch: allow
          question: allow
          external_directory: ask
          doom_loop: ask
          bash:
            # Routine local inspection/build/test commands run without approval.
            "*": allow

            # Unambiguously high-impact command families require human approval.
            "sudo *": ask
            "doas *": ask
            "su *": ask
            "bash -c *": ask
            "sh -c *": ask
            "zsh -c *": ask
            "eval *": ask
            "rm *": ask
            "unlink *": ask
            "shred *": ask
            "dd *": ask
            "chown *": ask
            "chmod -R *": ask
            "kill *": ask
            "pkill *": ask

            # Local machine or service state; inspection remains automatic.
            "systemctl *": ask
            "systemctl status*": allow
            "systemctl show*": allow
            "systemctl is-active*": allow
            "systemctl is-enabled*": allow
            "systemctl list-*": allow
            "systemctl --user status*": allow
            "systemctl --user show*": allow
            "systemctl --user is-active*": allow
            "systemctl --user is-enabled*": allow
            "loginctl *": ask
            "loginctl show*": allow
            "loginctl list*": allow
            "reboot*": ask
            "shutdown*": ask
            "poweroff*": ask
            "mount *": ask
            "umount *": ask

            # Git mutation and remote writes; read-only Git commands remain automatic.
            "git *": ask
            "git status*": allow
            "git diff*": allow
            "git log*": allow
            "git show*": allow
            "git grep*": allow
            "git blame*": allow
            "git ls-*": allow
            "gh *": ask
            "gh pr view*": allow
            "gh pr list*": allow
            "gh pr diff*": allow
            "gh pr checks*": allow
            "gh issue view*": allow
            "gh issue list*": allow
            "gh run view*": allow
            "gh run list*": allow
            "gh repo view*": allow

            # Activating Nix configurations or changing persistent Nix state.
            "nh os switch*": ask
            "nh os boot*": ask
            "nh os test*": ask
            "nh darwin switch*": ask
            "nh home switch*": ask
            "nixos-rebuild switch*": ask
            "nixos-rebuild boot*": ask
            "nixos-rebuild test*": ask
            "darwin-rebuild switch*": ask
            "home-manager switch*": ask
            "nix flake update*": ask
            "nix flake lock*": ask
            "nix profile *": ask
            "nix-env *": ask
            "nix store delete*": ask
            "nix-collect-garbage*": ask

            # Remote hosts and infrastructure. Read-only subcommands are exceptions.
            "ssh *": ask
            "scp *": ask
            "rsync *": ask
            "docker *": ask
            "docker ps*": allow
            "docker inspect*": allow
            "docker logs*": allow
            "docker images*": allow
            "kubectl *": ask
            "kubectl get*": allow
            "kubectl describe*": allow
            "kubectl logs*": allow
            "kubectl diff*": allow
            "helm *": ask
            "helm list*": allow
            "helm status*": allow
            "helm get*": allow
            "helm template*": allow
            "helm lint*": allow
            "terraform *": ask
            "terraform plan*": allow
            "terraform show*": allow
            "terraform validate*": allow
            "terraform fmt*": allow
            "tofu *": ask
            "tofu plan*": allow
            "tofu show*": allow
            "tofu validate*": allow
            "tofu fmt*": allow
            "ansible-playbook *": ask
            "talosctl apply-config*": ask
            "talosctl upgrade*": ask
            "talosctl reset*": ask

            # Secrets and direct schema/data mutation.
            "sops *": ask
            "gpg *": ask
            "prisma migrate deploy*": ask
            "prisma db push*": ask
            "drizzle-kit push*": ask
            "alembic upgrade*": ask
            "rails db:migrate*": ask
        ---

        Implement only the bounded task assigned by the parent. Follow project
        instructions and existing architecture. Prefer the smallest coherent diff;
        do not perform unrelated cleanup.

        Choose and run routine local inspection, formatting, build, type-check, lint,
        and test commands without asking. Commands matched by an `ask` rule should be
        invoked normally so OpenCode's permission UI can request approval.

        For a semantically high-impact action not covered by an `ask` pattern, call
        the `question` tool before acting. High-impact includes deleting or overwriting
        user data, changing host/service state, remote Git or infrastructure, database
        data/schema, secrets, dependency choices, or paths outside the worktree.

        Never bypass approval by wrapping, encoding, scripting, aliasing, or replacing
        a command with an equivalent implementation. A rejection means stop that
        action and report it. Use the parent-requested handoff, stay under 700 words,
        and summarize failures instead of pasting raw logs.
      '';

      verify-cheap = ''
        ---
        description: "Independent cheap reviewer that inspects the diff and runs checks"
        mode: subagent
        hidden: true
        model: opencode-go/deepseek-v4-pro
        steps: 16
        permission:
          "*": deny
          read:
            "*": allow
            "*.env": ask
            "*.env.*": ask
            "*.env.example": allow
          edit: deny
          glob: allow
          grep: allow
          list: allow
          lsp: allow
          webfetch: allow
          websearch: allow
          question: allow
          external_directory: ask
          doom_loop: ask
          bash:
            # Independent verification is conservative: known inspection/build/test
            # commands run directly; unusual commands ask the user.
            "*": ask
            "git status*": allow
            "git diff*": allow
            "git log*": allow
            "git show*": allow
            "git grep*": allow
            "rg *": allow
            "fd *": allow
            "find *": allow
            "ls*": allow
            "stat *": allow
            "file *": allow
            "cat *": allow
            "head *": allow
            "tail *": allow
            "jq *": allow
            "nix eval*": allow
            "nix build*": allow
            "nix flake check*": allow
            "nix flake show*": allow
            "nh os build*": allow
            "nh darwin build*": allow
            "nh home build*": allow
            "treefmt*": allow
            "deadnix*": allow
            "statix*": allow
            "npm test*": allow
            "npm run *": allow
            "pnpm test*": allow
            "pnpm run *": allow
            "yarn test*": allow
            "yarn run *": allow
            "bun test*": allow
            "bun run *": allow
            "cargo check*": allow
            "cargo test*": allow
            "cargo clippy*": allow
            "go test*": allow
            "pytest*": allow
            "python -m pytest*": allow
            "ruff*": allow
            "uv run *": allow
        ---

        Act as an independent verifier. Never edit files and do not trust the
        implementation worker's conclusion. Inspect the actual diff and repository
        state. Verify each acceptance criterion with the narrowest useful checks.

        Record `git diff` before and after checks. If a check unexpectedly changes a
        tracked file, report it instead of accepting the generated diff. Do not run
        deployment, activation, migration, destructive, credential, or remote-write
        commands, and never work around an approval prompt. Return PASS only with
        concrete evidence; otherwise return FAIL or INCONCLUSIVE with one minimal next
        action. Use the parent-requested handoff and omit raw logs.
      '';
    };
  };
}
