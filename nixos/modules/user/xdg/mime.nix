{ config, lib, ... }:

let
  cfg = config.userSettings.xdg;
  browser = [ "floorp.desktop" ];
  fileManager = [ "nautilus.desktop" ];
  archiveManager = [ "org.gnome.FileRoller.desktop" ];
in
{
  config = lib.mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "x-scheme-handler/mailto" = browser;

        "application/pdf" = browser;

        "inode/directory" = fileManager;

        "application/zip" = archiveManager;
        "application/x-zip-compressed" = archiveManager;
        "application/x-rar" = archiveManager;
        "application/x-rar-compressed" = archiveManager;
        "application/vnd.rar" = archiveManager;
        "application/x-7z-compressed" = archiveManager;
        "application/x-tar" = archiveManager;
        "application/x-gzip" = archiveManager;
        "application/x-bzip2" = archiveManager;

        "image/jpeg" = [ "floorp.desktop" ];
        "image/png" = [ "floorp.desktop" ];
        "image/gif" = [ "floorp.desktop" ];
        "image/webp" = [ "floorp.desktop" ];

        "video/mp4" = [ "mpv.desktop" "vlc.desktop" ];
        "video/mpeg" = [ "mpv.desktop" "vlc.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" "vlc.desktop" ];
        "video/quicktime" = [ "mpv.desktop" "vlc.desktop" ];
        "video/x-msvideo" = [ "mpv.desktop" "vlc.desktop" ];
        "video/x-flv" = [ "mpv.desktop" "vlc.desktop" ];
        "video/webm" = [ "mpv.desktop" "vlc.desktop" ];

        "audio/mpeg" = [ "vlc.desktop" "mpv.desktop" ];
        "audio/x-wav" = [ "vlc.desktop" "mpv.desktop" ];
        "audio/x-flac" = [ "vlc.desktop" "mpv.desktop" ];
        "audio/x-m4a" = [ "vlc.desktop" "mpv.desktop" ];

        "text/plain" = [ "nvim.desktop" "cursor.desktop" "code.desktop" ];

        "x-scheme-handler/discord" = [ "vesktop.desktop" ];
        "x-scheme-handler/stremio" = [ "stremio.desktop" ];
      };
    };
  };
}
