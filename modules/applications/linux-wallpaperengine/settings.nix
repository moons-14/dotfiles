{
  assetsDirectory = "~/.local/share/Steam/steamapps/common/wallpaper_engine/assets";
  workshopDirectory = "~/.local/share/Steam/steamapps/workshop/content/431960";

  wallpaperIds = [
    "2649146222"
    "2834355367"
    "2836628501"
    "2840196275"
    "2846639513"
    "2855820325"
    "2857233724"
    "2857994490"
    "2861661119"
    "2868304559"
    "2872296948"
    "2833810156"
    "2835102142"
    "2839511236"
    "2845095254"
    "2851762554"
    "2857085655"
    "2857263038"
    "2859848175"
    "2867283793"
    "2869066585"
    "2982896307"
  ];

  # null selects the first ID above.
  selectedWallpaperId = null;
  # Set a number such as 300 to rotate through multiple IDs.
  switchIntervalSeconds = null;

  fps = 30;
  mute = true;
  scaling = "fill";
}
