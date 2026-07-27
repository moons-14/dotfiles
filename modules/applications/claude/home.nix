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
    statusLine = {
      type = "command";
      command = "bun x ccusage statusline --no-offline";
      padding = 0;
    };
  };
}
