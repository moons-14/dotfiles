{
  assetsDirectory = "~/.local/share/Steam/steamapps/common/wallpaper_engine/assets";
  workshopDirectory = "~/.local/share/Steam/steamapps/workshop/content/431960";

  wallpaperIds = [
    "2833810156"
    "2834355367"
    "2836628501"
    "2845095254"
    "2859848175"
    "2861661119"
    "2982896307"
  ];

  # null selects the first ID above.
  selectedWallpaperId = null;
  # Set a number such as 300 to rotate through multiple IDs.
  switchIntervalSeconds = 300;

  fps = 30;
  mute = true;
  scaling = "fill";
}
