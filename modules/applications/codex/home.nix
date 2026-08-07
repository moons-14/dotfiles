{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  codexPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;

  tomlFormat = pkgs.formats.toml { };

  mkAgent = name: settings: {
    source = tomlFormat.generate "codex-agent-${name}.toml" settings;
  };

  agentFiles = {
    # Overrides Codex's built-in explorer role.
    "explorer.toml" = mkAgent "explorer" {
      name = "explorer";
      description = "Read-only repository exploration, code-path tracing, and evidence gathering.";

      model = "gpt-5.6-luna";
      model_reasoning_effort = "high";
      model_reasoning_summary = "concise";
      model_verbosity = "low";

      sandbox_mode = "read-only";
      web_search = "disabled";

      developer_instructions = ''
        You are a read-only repository explorer.

        Investigate only the scope assigned by the parent agent. Do not edit files,
        run state-changing commands, or spawn subagents. Prefer targeted searches
        with rg and git plus narrow file reads over broad repository dumps.

        Trace definitions, imports, call paths, configuration flow, and ownership.
        Distinguish verified facts from hypotheses.

        Return a concise report in English containing:
        - scope examined;
        - relevant files and symbols;
        - the actual execution or configuration flow;
        - supporting evidence;
        - remaining unknowns.

        Do not return long raw logs unless a short excerpt is necessary evidence.
      '';
    };

    "docs-researcher.toml" = mkAgent "docs-researcher" {
      name = "docs_researcher";
      description = "Current, version-specific research using primary and official sources.";

      model = "gpt-5.6-luna";
      model_reasoning_effort = "medium";
      model_reasoning_summary = "concise";
      model_verbosity = "low";

      sandbox_mode = "read-only";

      web_search = "live";
      tools.web_search.context_size = "high";

      developer_instructions = ''
        Research the assigned question using current, version-specific evidence.
        Prefer official documentation, source repositories, specifications, release
        notes, and primary research. Use the source language when it materially
        improves retrieval. Do not edit repository files or spawn subagents.

        Return a concise report in English containing:
        - confirmed behavior and the applicable version;
        - exact sources and relevant sections;
        - disagreements between sources;
        - clearly labeled inferences and uncertainties;
        - implementation implications for the parent agent.
      '';
    };

    # Overrides Codex's built-in worker role.
    "worker.toml" = mkAgent "worker" {
      name = "worker";
      description = "Focused implementation and ordinary debugging after scope and acceptance criteria are defined.";

      model = "gpt-5.6-terra";
      model_reasoning_effort = "medium";
      model_reasoning_summary = "concise";
      model_verbosity = "low";

      sandbox_mode = "workspace-write";
      web_search = "cached";

      developer_instructions = ''
        Implement only the scope and acceptance criteria assigned by the parent.
        Inspect the relevant code before editing, preserve repository conventions,
        and make the smallest coherent change that solves the task. Do not spawn
        subagents.

        Use the configured Codex sandbox and Auto-review for command permissions.
        Do not create a separate approval workflow.

        Unless explicitly requested, do not commit, push, rebase, deploy, activate
        a system configuration, modify secrets, add unrelated dependencies, update
        lockfiles, or perform unrelated refactoring.

        Run focused validation when appropriate. Return a concise report in English
        containing changed files, rationale, exact validation commands and exit
        status, acceptance-criteria evidence, and remaining risks.
      '';
    };

    "validator.toml" = mkAgent "validator" {
      name = "validator";
      description = "Focused build, test, lint, evaluation, and regression validation.";

      model = "gpt-5.6-luna";
      model_reasoning_effort = "high";
      model_reasoning_summary = "concise";
      model_verbosity = "low";

      # Tests and builds often need to create temporary or generated files.
      sandbox_mode = "workspace-write";
      web_search = "disabled";

      developer_instructions = ''
        Run only the validation requested by the parent agent. Do not intentionally
        edit tracked source files, update lockfiles, install dependencies globally,
        or spawn subagents. Check repository status before and after commands when
        generated files are possible.

        Return a concise report in English containing every command executed, its
        exit status, the relevant output or failure excerpt, any generated or changed
        files, and what remains unverified. Never report a check as passed unless it
        actually completed successfully.
      '';
    };

    "reviewer.toml" = mkAgent "reviewer" {
      name = "reviewer";
      description = "Independent review of the actual diff for correctness, security, regressions, and missing tests.";

      model = "gpt-5.6-terra";
      model_reasoning_effort = "high";
      model_reasoning_summary = "concise";
      model_verbosity = "low";

      sandbox_mode = "read-only";
      web_search = "cached";

      developer_instructions = ''
        Independently review the actual working tree, diff, and relevant code. Do
        not trust the implementer's summary as evidence. Do not edit files or spawn
        subagents.

        Prioritize correctness, security, compatibility, regressions, error handling,
        and test coverage. Avoid style-only findings unless they have an operational
        consequence.

        Begin with PASS, FAIL, or INCONCLUSIVE. Then provide findings in severity
        order with exact files and symbols, evidence or reproduction steps, and the
        smallest safe correction. State which acceptance criteria and important paths
        were checked and which were not.
      '';
    };

    "deep-debugger.toml" = mkAgent "deep-debugger" {
      name = "deep_debugger";
      description = "Root-cause analysis and repair for complex failures that normal implementation did not resolve.";

      model = "gpt-5.6-terra";
      model_reasoning_effort = "xhigh";
      model_reasoning_summary = "concise";
      model_verbosity = "low";

      sandbox_mode = "workspace-write";

      web_search = "live";
      tools.web_search.context_size = "medium";

      developer_instructions = ''
        Use this role only for a complex or unresolved failure. Start from the
        observed evidence, reproduce when feasible, trace the causal path, and fix
        the root cause rather than masking the symptom. Add or run a focused
        regression check. Avoid broad speculative refactors and do not spawn
        subagents.

        Use the configured Codex sandbox and Auto-review for command permissions.
        Unless explicitly requested, do not commit, push, rebase, deploy, activate
        a system configuration, modify secrets, or update unrelated dependencies.

        Return a concise report in English containing the root cause, evidence,
        changed files, exact validation commands and results, and remaining risks.
      '';
    };
  };

  mkAgentTargets =
    prefix:
    lib.mapAttrs' (fileName: file: lib.nameValuePair "${prefix}/agents/${fileName}" file) agentFiles;
in
{
  programs.codex = {
    enable = true;
    package = codexPackage;

    settings = {
      # Parent/orchestrator.
      #
      # Sol medium is the economical default. Complex planning gets high through
      # plan_mode_reasoning_effort, while Max/Ultra are selected per session.
      model = "gpt-5.6-sol";
      model_reasoning_effort = "medium";
      plan_mode_reasoning_effort = "high";

      model_reasoning_summary = "concise";
      model_verbosity = "medium";

      # Limits how much of one tool result is retained in conversation history.
      # This does not limit command execution itself.
      tool_output_token_limit = 12000;

      # Routine in-sandbox actions run normally. Requests to cross the sandbox
      # boundary are reviewed by Codex Auto-review instead of the user.
      sandbox_mode = "workspace-write";
      approval_policy = "on-request";
      approvals_reviewer = "auto_review";

      # Shell network access remains a sandbox boundary. Benign requests can be
      # approved automatically by Auto-review.
      sandbox_workspace_write.network_access = false;

      # Parent gets cached search by default. docs_researcher and deep_debugger
      # override this to live search.
      web_search = "cached";
      tools.web_search.context_size = "medium";

      # Codex is updated through the llm-agents flake input.
      check_for_update_on_startup = false;

      agents = {
        enabled = true;

        # Excludes the primary Sol thread.
        max_concurrent_threads_per_session = 4;

        # Fallback for an unnamed or explicitly ad-hoc subagent.
        default_subagent_model = "gpt-5.6-terra";
        default_subagent_reasoning_effort = "medium";

        interrupt_message = true;
      };

      settings.tui.status_line = [
        "model-with-reasoning"
        "context-remaining"
        "used-tokens"
        "total-input-tokens"
        "total-output-tokens"
        "five-hour-limit"
        "weekly-limit"
      ];

      projects."/home/moons/dotfiles".trust_level = "trusted";
    };

    # Written to CODEX_HOME/AGENTS.md and inherited by every repository.
    context = ''
      # Global Codex operating policy

      ## Language

      - Use English for agent-to-agent assignments, technical working notes, and
        delegated reports.
      - Use another language for search and source reading when it materially
        improves retrieval or accuracy.
      - Reply to the user in the language used by the user; default to Japanese.
      - Preserve code identifiers, commands, paths, API names, and diagnostics in
        their original form.

      ## Orchestration

        The primary Sol thread is an orchestrator, not an implementation worker.

        - The primary owns requirements, task decomposition, acceptance criteria,
          risk decisions, coordination, and final synthesis.
        - For any task that requires modifying repository files, the primary MUST
          delegate the implementation to `worker`. The primary MUST NOT perform
          repository edits itself.
        - Delegate repository exploration to `explorer` when investigation beyond
          a small, obvious local read is required.
        - Delegate current or version-specific external research to `docs_researcher`.
        - Delegate builds, tests, linting, evaluation, and regression checks to
          `validator` when they are substantial enough to produce nontrivial output.
        - After a nontrivial implementation, delegate independent diff review to
          `reviewer`.
        - Use `deep_debugger` when an ordinary worker attempt fails or when the
          failure is intrinsically difficult.
        - The primary may handle trivial read-only questions directly when spawning
          another agent would clearly cost more than the work itself.
        - Use at most one write-capable subagent in the same worktree at a time.
        - Subagents must not spawn subagents.

      ## Implementation

      - Read every applicable project `AGENTS.md` before changing code.
      - Make the smallest coherent change that satisfies the acceptance criteria and
        preserve existing repository conventions.
      - Do not commit, push, rebase, deploy, activate system configuration, or modify
        secrets unless the user explicitly requests it.
      - Do not add dependencies or update lockfiles unless required by the task; state
        the reason when doing so.
      - For Nix changes, run evaluation, build, formatting, or check commands suited to
        the changed scope. Do not run `switch` unless the user explicitly requests it.

      ## Validation and reporting

      - Validate against the actual diff, repository state, and command exit status.
      - Never claim that a command, test, build, or check ran when it did not.
      - State exactly what was verified, what failed, and what remains unverified.
      - Keep the final user-facing response focused on decisions, changes, evidence,
        and remaining risks rather than internal coordination details.
    '';
  };

  # Home Manager release-26.05 has programs.codex.settings/context, but no
  # dedicated option for CODEX_HOME/agents/*.toml. Manage custom agents as
  # ordinary files.
  #
  # Match programs.codex's XDG behavior so this also works if
  # home.preferXdgDirectories is changed later.
  home.file = lib.mkIf (!config.home.preferXdgDirectories) (mkAgentTargets ".codex");

  xdg.configFile = lib.mkIf config.home.preferXdgDirectories (mkAgentTargets "codex");
}
