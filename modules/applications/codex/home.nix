{
  inputs,
  pkgs,
  ...
}:
{
  programs.codex = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex;

    # Home Manager writes this as CODEX_HOME/config.toml.  Keep only general
    # client defaults here; custom agents, hooks, and global instructions are
    # intentionally not configured.
    settings = {
      model = "gpt-5.6-terra";
      model_reasoning_effort = "medium";

      approval_policy = "on-request";
      approvals_reviewer = "auto_review";
      sandbox_mode = "workspace-write";
      sandbox_workspace_write.network_access = false;
      web_search = "cached";
    };

    # `grill-me` delegates to the reusable `grilling` primitive, so both are
    # installed even though `/grill-me` is the user-facing entry point.
    skills = {
      grill-me = inputs.skills + "/skills/productivity/grill-me";
      grilling = inputs.skills + "/skills/productivity/grilling";
    };
  };
}
