{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
  ];

  home.file.".claude/settings.json".text = builtins.toJSON {
    model = "claude-opus-5-5";
    modelSettings."claude-opus-5-5".effortLevel = "low";

    statusLine = {
      type = "command";
      command = "bun x ccusage statusline --no-offline";
      padding = 0;
    };
  };
}
