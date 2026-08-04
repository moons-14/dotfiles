{
  config,
  lib,
  pkgs,
  ...
}:
let
  nautilusExtensionDir = "${pkgs.nautilus-python}/lib/nautilus/extensions-4";
in
{
  home.packages = [
    pkgs.nautilus
    pkgs.nautilus-python
    pkgs.sushi
  ];

  # Nautilus に nautilus-python のC拡張を認識させる。
  # home.sessionVariables:
  #   通常のログインセッションやシェルから起動したNautilus向け
  #
  # systemd.user.sessionVariables:
  #   D-Bus/systemdユーザーサービス経由で起動したNautilus向け
  home.sessionVariables.NAUTILUS_4_EXTENSION_DIR = nautilusExtensionDir;

  systemd.user.sessionVariables.NAUTILUS_4_EXTENSION_DIR = nautilusExtensionDir;

  xdg.dataFile."nautilus-python/extensions/open-in-editor.py".text = ''
    import os
    import subprocess

    from gi.repository import GObject, Nautilus


    class OpenInEditorExtension(
        GObject.GObject,
        Nautilus.MenuProvider,
    ):
        EDITORS = (
            (
                "vscode",
                "VS Code で開く",
                ["${lib.getExe pkgs.vscode}"],
            ),
            (
                "zed",
                "Zed で開く",
                ["${lib.getExe pkgs.zed-editor}"],
            ),
            (
                "neovim",
                "Neovim で開く",
                [
                    "${lib.getExe pkgs.ghostty}",
                    "-e",
                    "${lib.getExe pkgs.neovim}",
                ],
            ),
        )

        @staticmethod
        def get_local_paths(files):
            paths = []

            for file in files:
                location = file.get_location()

                if location is None:
                    return []

                path = location.get_path()

                if path is None:
                    return []

                paths.append(path)

            return paths

        @staticmethod
        def get_working_directory(paths):
            path = paths[0]

            return path if os.path.isdir(path) else os.path.dirname(path)

        @staticmethod
        def launch(_item, command):
            subprocess.Popen(
                command,
                start_new_session=True,
                close_fds=True,
            )

        def create_items(self, context, paths):
            items = []

            for editor_id, label, command in self.EDITORS:
                item = Nautilus.MenuItem(
                    # 選択項目用と背景用で異なるIDにする
                    name=f"OpenInEditor::{context}::{editor_id}",
                    label=label,
                )

                item.connect(
                    "activate",
                    self.launch,
                    [*command, *paths],
                )

                items.append(item)

            item = Nautilus.MenuItem(
                name=f"OpenInEditor::{context}::ghostty",
                label="Ghostty で開く",
            )

            item.connect(
                "activate",
                self.launch,
                [
                    "${lib.getExe pkgs.ghostty}",
                    f"--working-directory={self.get_working_directory(paths)}",
                ],
            )

            items.append(item)

            return items

        def get_file_items(self, files):
            paths = self.get_local_paths(files)

            if not paths:
                return []

            # 選択中のファイル・ディレクトリを渡す
            return self.create_items("selection", paths)

        def get_background_items(self, current_folder):
            paths = self.get_local_paths([current_folder])

            if not paths:
                return []

            # 何も選択せず背景を右クリックした場合だけ現在位置を渡す
            return self.create_items("background", paths)
  '';

  dconf.settings = {
    "org/gnome/nautilus/preferences" = {
      always-use-location-entry = true;
      default-folder-viewer = "list-view";
    };

    "org/gnome/nautilus/list-view".use-tree-view = true;

    # Nautilus 50 migrates this setting from GTK 3 to GTK 4.
    "org/gtk/settings/file-chooser".show-hidden = true;
    "org/gtk/gtk4/settings/file-chooser".show-hidden = true;
  };

  gtk.gtk3.bookmarks = [
    "file://${config.home.homeDirectory}/Desktop Desktop"
    "file://${config.home.homeDirectory}/Pictures Pictures"
    "file://${config.home.homeDirectory}/Downloads Downloads"
    "file://${config.home.homeDirectory}/projects projects"
  ];

  home.activation.createProjectsDirectory = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      $DRY_RUN_CMD mkdir -p "$HOME/projects"
    '';
  };
}
