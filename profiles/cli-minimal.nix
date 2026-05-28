{
  pkgs,
  userName,
  ...
}:
{
  imports = [
    ./base.nix
  ];
  programs = {
    java = {
      enable = true;
      package = pkgs.jdk25;
    };
  };

  environment.systemPackages = with pkgs; [
    nil # Nix Language Server
    docker # Containerization Platform
    tio # A Simple TTY Terminal I/O Application
    sqlite # Vscode Raycast Extension Dependency
    oxker # Docker TUI Tool
    jdk25 # Java Development Kit 25
    maven # Java Build Tool
    gradle # Java Build Tool
    python312 # Python 3.12
    uv # Universal Virtual Environment Manager For Python
    bun # A Fast JavaScript Runtime Like Node.js And Deno
    unstable.claude-code # Anthropic's AI Assistant
    unstable.codex # OpenAI's Code Generation Model
    unstable.opencode # Coding AI Assistant
  ];

  home-manager.users.${userName}.imports = [ ];
}
