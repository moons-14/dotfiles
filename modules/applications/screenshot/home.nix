{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "screenshot";

      runtimeInputs = with pkgs; [
        coreutils
        grim
        slurp
        wl-clipboard
        xdg-user-dirs
      ];

      text = ''
        mode="''${1:-region}"

        pictures_dir="$(xdg-user-dir PICTURES)"
        if [[ -z "$pictures_dir" ]]; then
          pictures_dir="$HOME/Pictures"
        fi

        output_dir="$pictures_dir/Screenshots"
        output_file="$output_dir/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"

        mkdir -p "$output_dir"

        case "$mode" in
          region)
            geometry="$(slurp)" || exit 0
            grim -g "$geometry" "$output_file"
            ;;

          output)
            geometry="$(slurp -o)" || exit 0
            grim -g "$geometry" "$output_file"
            ;;

          all)
            grim "$output_file"
            ;;

          *)
            echo "Unknown screenshot mode: $mode" >&2
            exit 2
            ;;
        esac

        wl-copy --type image/png < "$output_file"
      '';
    })
  ];
}
