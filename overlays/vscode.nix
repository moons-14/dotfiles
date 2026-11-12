_final: prev: {
  vscode =
    if prev.vscode.version == "1.144.0" then
      prev.vscode.overrideAttrs (old: {
        # VS Code 1.144 moved the bundled ripgrep to a platform-specific directory.
        postPatch =
          prev.lib.replaceStrings
            [ "resources/app/node_modules/@vscode/ripgrep/bin/rg" ]
            [
              "resources/app/node_modules/@vscode/ripgrep-universal/bin/linux-${prev.stdenv.hostPlatform.node.arch}/rg"
            ]
            old.postPatch;
      })
    else
      prev.vscode;
}
