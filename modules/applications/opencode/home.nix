{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.oh-my-opencode
  ];

  home.file.".omo/omo.jsonc".text = builtins.toJSON {
    agents = {
      sisyphus.model = "openai/gpt-5.6-sol";
      hephaestus.model = "openai/gpt-5.6-terra";
      prometheus.model = "openai/gpt-5.6-terra";
      oracle.model = "openai/gpt-5.6-terra";
      momus.model = "openai/gpt-5.6-terra";
      librarian.model = "openai/gpt-5.6-luna";
      explore.model = "openai/gpt-5.6-luna";
      atlas.model = "openai/gpt-5.6-luna";
    };
  };
}
