_: {
  programs.vesktop = {
    enable = true;

    settings = {
      discordBranch = "stable";

      hardwareAcceleration = true;
      hardwareVideoAcceleration = true;

      tray = true;
      minimizeToTray = true;

      # Discord Rich Presence
      arRPC = true;

      openLinksWithElectron = false;

      spellCheckLanguages = [
        "ja-JP"
        "en-US"
      ];
    };

    vencord = {
      useSystem = false;

      settings = {
        autoUpdate = true;
        autoUpdateNotification = false;

        useQuickCss = false;

        cloud.settingsSync = false;

        notifications = {
          position = "bottom-right";
          useNative = "not-focused";
          timeout = 5000;
          logLimit = 50;
        };

        plugins = {
          # プライバシー・安全性
          NoTrack.enabled = true;
          ClearURLs.enabled = true;

          # 設定・セッション
          BetterSettings.enabled = true;
          BetterSessions.enabled = true;

          # 画像・添付ファイル
          FixImagesQuality.enabled = true;
          ImageZoom.enabled = true;
          ViewIcons.enabled = true;
          CopyFileContents.enabled = true;

          # メッセージ操作
          QuickReply.enabled = true;
          SendTimestamps.enabled = true;
          FullSearchContext.enabled = true;
          MessageLinkEmbeds.enabled = true;
          Unindent.enabled = true;
          ValidReply.enabled = true;

          # 通知・誤操作対策
          ReadAllNotificationsButton.enabled = true;
          NoReplyMention.enabled = true;
          NotificationVolume.enabled = true;

          # UI・パフォーマンス
          NoTypingAnimation.enabled = true;
          FavoriteEmojiFirst.enabled = true;
          KeepCurrentChannel.enabled = true;

          # サーバー・権限確認
          PermissionsViewer.enabled = true;
          MemberCount.enabled = true;

          # ボイス・アクティビティ
          CallTimer.enabled = true;
          GameActivityToggle.enabled = true;

          # Vesktop向け
          WebKeybinds.enabled = true;
          WebScreenShareFixes.enabled = true;

          # Message history
          MessageLogger.enabled = true;
          ShowHiddenChannels.enabled = true;
        };
      };
    };
  };
}
