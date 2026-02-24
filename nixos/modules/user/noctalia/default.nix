# Noctalia-shell: Home Manager config using native options (Configuration Defaults schema).
# Values from config/noctalia/*.json; structure follows docs default schema.
# See https://docs.noctalia.dev/getting-started/nixos/
{ config, inputs, lib, ... }:

let
  home = config.home.homeDirectory;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  config.programs.noctalia-shell = {
    enable = true;

    settings = lib.mkForce {
      settingsVersion = 31;

      bar = {
        barType = "simple";
        position = "left";
        monitors = [ ];
        density = "comfortable";
        showOutline = false;
        showCapsule = true;
        capsuleOpacity = 1;
        capsuleColorKey = "none";
        widgetSpacing = 6;
        fontScale = 1;
        backgroundOpacity = 0.93;
        useSeparateOpacity = false;
        floating = false;
        marginVertical = 0.25;
        marginHorizontal = 0.25;
        frameThickness = 8;
        frameRadius = 12;
        outerCorners = true;
        hideOnOverview = false;
        displayMode = "always_visible";
        autoHideDelay = 500;
        autoShowDelay = 150;
        showOnWorkspaceSwitch = true;
        exclusive = true;
        transparent = false;
        widgets = {
          left = [
            { id = "ControlCenter"; colorizeDistroLogo = false; colorizeSystemIcon = "none"; customIconPath = ""; enableColorization = false; icon = "noctalia"; useDistroLogo = false; }
            { id = "SystemMonitor"; diskPath = "/"; showCpuTemp = true; showCpuUsage = true; showDiskUsage = false; showGpuTemp = false; showMemoryAsPercent = false; showMemoryUsage = true; showNetworkStats = false; usePrimaryColor = false; }
            { id = "ActiveWindow"; colorizeIcons = false; hideMode = "hidden"; maxWidth = 145; scrollingMode = "hover"; showIcon = true; useFixedWidth = false; }
            { id = "MediaMini"; hideMode = "hidden"; hideWhenIdle = false; maxWidth = 145; scrollingMode = "hover"; showAlbumArt = false; showArtistFirst = true; showProgressRing = true; showVisualizer = false; useFixedWidth = false; visualizerType = "linear"; }
            { id = "WallpaperSelector"; }
            { id = "NightLight"; }
            { id = "NoctaliaPerformance"; }
          ];
          center = [
            { id = "Workspace"; characterCount = 2; colorizeIcons = false; enableScrollWheel = true; followFocusedScreen = false; hideUnoccupied = false; labelMode = "index"; showApplications = false; showLabelsOnlyWhenOccupied = true; }
          ];
          right = [
            { id = "Tray"; blacklist = [ ]; colorizeIcons = false; drawerEnabled = true; hidePassive = false; pinned = [ ]; }
            { id = "ScreenRecorder"; }
            { id = "plugin:keybind-cheatsheet"; }
            { id = "NotificationHistory"; hideWhenZero = true; showUnreadBadge = true; }
            { id = "Volume"; displayMode = "onhover"; }
            { id = "Brightness"; displayMode = "onhover"; }
            { id = "Clock"; customFont = ""; formatHorizontal = "HH:mm ddd, MMM dd"; formatVertical = "HH mm - dd MM"; useCustomFont = false; usePrimaryColor = true; }
          ];
        };
        screenOverrides = [ ];
      };

      general = {
        avatarImage = "${home}/.face";
        dimmerOpacity = 0.6;
        showScreenCorners = false;
        forceBlackScreenCorners = false;
        scaleRatio = 1.1;
        radiusRatio = 1;
        iRadiusRatio = 1;
        boxRadiusRatio = 1;
        screenRadiusRatio = 1;
        animationSpeed = 1;
        animationDisabled = false;
        compactLockScreen = false;
        lockScreenAnimations = false;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
        showHibernateOnLockScreen = false;
        enableShadows = true;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        language = "";
        allowPanelsOnScreenWithoutBar = true;
        showChangelogOnStartup = true;
        telemetryEnabled = false;
        enableLockScreenCountdown = true;
        lockScreenCountdownDuration = 10000;
        autoStartAuth = false;
        allowPasswordWithFprintd = false;
        clockStyle = "custom";
        clockFormat = "hh\nmm";
        passwordChars = false;
        lockScreenMonitors = [ ];
        lockScreenBlur = 0;
        lockScreenTint = 0;
        keybinds = {
          keyUp = [ "Up" ];
          keyDown = [ "Down" ];
          keyLeft = [ "Left" ];
          keyRight = [ "Right" ];
          keyEnter = [ "Return" ];
          keyEscape = [ "Esc" ];
          keyRemove = [ "Del" ];
        };
        reverseScroll = false;
      };

      ui = {
        fontDefault = "Roboto";
        fontFixed = "MesloLGSDZ Nerd Font Mono";
        fontDefaultScale = 1;
        fontFixedScale = 1;
        tooltipsEnabled = true;
        panelBackgroundOpacity = 1;
        panelsAttachedToBar = true;
        settingsPanelMode = "centered";
        wifiDetailsViewMode = "grid";
        bluetoothDetailsViewMode = "grid";
        networkPanelView = "wifi";
        bluetoothHideUnnamedDevices = false;
        boxBorderEnabled = false;
      };

      location = {
        name = "Crown Point, IN";
        weatherEnabled = true;
        weatherShowEffects = true;
        useFahrenheit = true;
        use12hourFormat = true;
        showWeekNumberInCalendar = false;
        showCalendarEvents = true;
        showCalendarWeather = true;
        analogClockInCalendar = false;
        firstDayOfWeek = -1;
        hideWeatherTimezone = false;
        hideWeatherCityName = false;
      };

      calendar = {
        cards = [
          { enabled = true; id = "calendar-header-card"; }
          { enabled = true; id = "calendar-month-card"; }
          { enabled = true; id = "timer-card"; }
          { enabled = true; id = "weather-card"; }
        ];
      };

      wallpaper = {
        enabled = true;
        overviewEnabled = false;
        directory = "${home}/Pictures/Wallpapers";
        monitorDirectories = [ ];
        enableMultiMonitorDirectories = false;
        showHiddenFiles = false;
        viewMode = "single";
        setWallpaperOnAllMonitors = true;
        fillMode = "crop";
        fillColor = "#000000";
        useSolidColor = false;
        solidColor = "#1a1a2e";
        automationEnabled = false;
        wallpaperChangeMode = "random";
        randomIntervalSec = 300;
        transitionDuration = 1500;
        transitionType = "random";
        skipStartupTransition = false;
        transitionEdgeSmoothness = 0.05;
        panelPosition = "follow_bar";
        hideWallpaperFilenames = false;
        overviewBlur = 0.4;
        overviewTint = 0.6;
        useWallhaven = true;
        wallhavenQuery = "";
        wallhavenSorting = "favorites";
        wallhavenOrder = "desc";
        wallhavenCategories = "111";
        wallhavenPurity = "100";
        wallhavenRatios = "";
        wallhavenApiKey = "";
        wallhavenResolutionMode = "atleast";
        wallhavenResolutionWidth = "2560";
        wallhavenResolutionHeight = "1440";
        sortOrder = "name";
        favorites = [ ];
      };

      appLauncher = {
        enableClipboardHistory = false;
        autoPasteClipboard = false;
        enableClipPreview = true;
        clipboardWrapText = true;
        clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
        clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
        position = "center";
        pinnedApps = [ ];
        useApp2Unit = false;
        sortByMostUsed = true;
        terminalCommand = "xterm -e";
        customLaunchPrefixEnabled = false;
        customLaunchPrefix = "";
        viewMode = "list";
        showCategories = true;
        iconMode = "tabler";
        showIconBackground = false;
        enableSettingsSearch = true;
        enableWindowsSearch = true;
        enableSessionSearch = true;
        ignoreMouseInput = false;
        screenshotAnnotationTool = "";
        overviewLayer = false;
        density = "default";
      };

      controlCenter = {
        position = "close_to_bar_button";
        diskPath = "/";
        shortcuts = {
          left = [ { id = "WiFi"; } { id = "Bluetooth"; } { id = "ScreenRecorder"; } { id = "WallpaperSelector"; } ];
          right = [ { id = "Notifications"; } { id = "PowerProfile"; } { id = "KeepAwake"; } { id = "NightLight"; } ];
        };
        cards = [
          { enabled = true; id = "profile-card"; }
          { enabled = true; id = "shortcuts-card"; }
          { enabled = true; id = "audio-card"; }
          { enabled = true; id = "weather-card"; }
          { enabled = true; id = "media-sysmon-card"; }
          { enabled = false; id = "brightness-card"; }
        ];
      };

      systemMonitor = {
        cpuWarningThreshold = 75;
        cpuCriticalThreshold = 90;
        tempWarningThreshold = 75;
        tempCriticalThreshold = 90;
        gpuWarningThreshold = 80;
        gpuCriticalThreshold = 90;
        memWarningThreshold = 75;
        memCriticalThreshold = 90;
        swapWarningThreshold = 80;
        swapCriticalThreshold = 90;
        diskWarningThreshold = 75;
        diskCriticalThreshold = 90;
        diskAvailWarningThreshold = 20;
        diskAvailCriticalThreshold = 10;
        batteryWarningThreshold = 20;
        batteryCriticalThreshold = 5;
        enableDgpuMonitoring = false;
        useCustomColors = false;
        warningColor = "#8be9fd";
        criticalColor = "#ff5555";
        externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
      };

      dock = {
        enabled = false;
        position = "bottom";
        displayMode = "always_visible";
        dockType = "floating";
        backgroundOpacity = 1;
        floatingRatio = 1;
        size = 1;
        onlySameOutput = true;
        monitors = [ ];
        pinnedApps = [ "Warframe" "cursor" "OrcaSlicer" "floorp" "floorp-d3979563-d63a-4aa7-a6f6-8114e2b8a3d9" "Marvel Rivals" ];
        colorizeIcons = false;
        showLauncherIcon = false;
        launcherPosition = "end";
        launcherIconColor = "none";
        pinnedStatic = false;
        inactiveIndicators = false;
        groupApps = false;
        groupContextMenuMode = "extended";
        groupClickAction = "cycle";
        groupIndicatorStyle = "dots";
        deadOpacity = 0.6;
        animationSpeed = 1;
        sitOnFrame = false;
        showFrameIndicator = true;
      };

      network = {
        wifiEnabled = true;
        airplaneModeEnabled = false;
        bluetoothRssiPollingEnabled = false;
        bluetoothRssiPollIntervalMs = 60000;
        wifiDetailsViewMode = "grid";
        bluetoothDetailsViewMode = "grid";
        bluetoothHideUnnamedDevices = false;
        disableDiscoverability = false;
      };

      sessionMenu = {
        enableCountdown = true;
        countdownDuration = 10000;
        position = "center";
        showHeader = true;
        showKeybinds = true;
        largeButtonsStyle = false;
        largeButtonsLayout = "single-row";
        powerOptions = [
          { action = "lock"; enabled = true; keybind = "1"; }
          { action = "suspend"; enabled = true; keybind = "2"; }
          { action = "hibernate"; enabled = true; keybind = "3"; }
          { action = "reboot"; enabled = true; keybind = "4"; }
          { action = "logout"; enabled = true; keybind = "5"; }
          { action = "shutdown"; enabled = true; keybind = "6"; }
          { action = "rebootToUefi"; enabled = true; keybind = "7"; }
        ];
      };

      notifications = {
        enabled = true;
        enableMarkdown = false;
        density = "default";
        monitors = [ "DP-3" ];
        location = "top_right";
        overlayLayer = true;
        backgroundOpacity = 1;
        respectExpireTimeout = false;
        lowUrgencyDuration = 3;
        normalUrgencyDuration = 4;
        criticalUrgencyDuration = 5;
        clearDismissed = true;
        saveToHistory = { low = true; normal = true; critical = true; };
        sounds = {
          enabled = false;
          volume = 0.5;
          separateSounds = false;
          criticalSoundFile = "";
          normalSoundFile = "";
          lowSoundFile = "";
          excludedApps = "discord,firefox,chrome,chromium,edge";
        };
        enableMediaToast = false;
        enableKeyboardLayoutToast = true;
        enableBatteryToast = true;
      };

      osd = {
        enabled = true;
        location = "top_right";
        autoHideMs = 2000;
        overlayLayer = true;
        backgroundOpacity = 1;
        enabledTypes = [ 0 1 2 ];
        monitors = [ ];
      };

      audio = {
        volumeStep = 5;
        volumeOverdrive = false;
        cavaFrameRate = 30;
        visualizerType = "linear";
        mprisBlacklist = [ ];
        preferredPlayer = "";
        volumeFeedback = false;
      };

      brightness = {
        brightnessStep = 5;
        enforceMinimum = true;
        enableDdcSupport = false;
        backlightDeviceMappings = [ ];
      };

      colorSchemes = {
        useWallpaperColors = true;
        predefinedScheme = "Dracula";
        darkMode = true;
        schedulingMode = "off";
        manualSunrise = "06:30";
        manualSunset = "18:30";
        generationMethod = "tonal-spot";
        monitorForColors = "";
      };

      templates = {
        activeTemplates = [ "Steam" ];
        enableUserTheming = false;
        enableUserTemplates = true;
        alacritty = true;
        steam = true;
        cava = false;
        code = false;
        discord = true;
        emacs = false;
        foot = false;
        fuzzel = false;
        ghostty = false;
        gtk = true;
        kcolorscheme = true;
        kitty = false;
        niri = false;
        pywalfox = true;
        qt = true;
        spicetify = false;
        telegram = false;
        vicinae = false;
        walker = false;
        wezterm = false;
        yazi = false;
        zed = false;
      };

      nightLight = {
        enabled = false;
        forced = false;
        autoSchedule = true;
        nightTemp = "4000";
        dayTemp = "6500";
        manualSunrise = "06:30";
        manualSunset = "18:30";
      };

      hooks = {
        enabled = false;
        wallpaperChange = "";
        darkModeChange = "";
        screenLock = "";
        screenUnlock = "";
        performanceModeEnabled = "";
        performanceModeDisabled = "";
        startup = "";
        session = "";
      };

      plugins.autoUpdate = false;

      desktopWidgets = {
        enabled = false;
        overviewEnabled = true;
        gridSnap = false;
        monitorWidgets = [ ];
      };

      screenRecorder = {
        audioCodec = "opus";
        audioSource = "default_output";
        colorRange = "limited";
        directory = "${home}/Videos";
        frameRate = 60;
        quality = "very_high";
        showCursor = true;
        videoCodec = "h264";
        videoSource = "portal";
      };
    };

    plugins = {
      version = 1;
      sources = [
        { name = "Official Noctalia Plugins"; url = "https://github.com/noctalia-dev/noctalia-plugins"; }
        { enabled = false; name = "a"; url = "https://github.com/ahernandezjr/noctalia-ai-plugins"; }
      ];
      states = {
        "keybind-cheatsheet" = { enabled = true; };
        "ai-chat" = { enabled = false; };
      };
    };

    user-templates = ''
      [config]

      [templates]

      # User-defined templates
      # Add your custom templates below
    '';
  };
}
