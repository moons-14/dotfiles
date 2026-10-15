{ pkgs, ... }:
{
  home.packages = [
    (
      (pkgs.unityhub.override {
        extraLibs = p: [ p.ncurses ];
      }).overrideAttrs
        (old: {
          postFixup = (old.postFixup or "") + ''
            wrapProgram $out/opt/unityhub/unityhub \
              --set LD_LIBRARY_PATH /usr/lib64
          '';
        })
    )
  ];
}
