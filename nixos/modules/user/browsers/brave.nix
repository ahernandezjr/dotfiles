# Brave browser configuration with sane defaults.
# Source: https://gist.github.com/hoyhoy/1c675f6f02118f6e0db7616c070917ac

{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings.browsers.brave;

  # Managed extensions via Policy (Forced)
  # This is more reliable than Home Manager's External Extensions for Brave on Linux.
  managedExtensions = [
    "nngceckbapebfimnlniiiahkandclblb" # bitwarden
    "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
    "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
    "mnjggcdmjocbbbhaepdhchncahnbgone" # sponsor block
    "ammjkodgmmoknidbanneddgankgfejfh" # 7tv
    "bpaoeijjlplfjbagceilcgbkcdjbomjd" # ttv lol pro
  ];

  # The "Sane Defaults" policies from the Gist
  bravePolicies = {
    AIModeSettings = 1;
    ShowFullURLs = true;
    WideAddressBar = true;
    TorDisabled = true;
    DefaultGeolocationSetting = 2;
    DefaultNotificationsSetting = 2;
    BookmarksBarEnabled = true;
    DefaultSerialGuardSetting = 2;
    CloudReportingEnabled = false;
    DriveDisabled = true;
    PasswordManagerEnabled = false;
    PasswordSharingEnabled = false;
    DefaultSensorsSetting = 2;
    MetricsReportingEnabled = false;
    SafeBrowseExtendedReportingEnabled = false;
    AutomaticallySendAnalytics = false;
    DnsOverHttpsMode = "automatic";

    BraveSyncUrl = "";
    BraveTalkDisabled = true;
    BraveNewsDisabled = true;
    BraveP3AEnabled = false;
    BraveSpeedreaderEnabled = false;
    BraveStatsPingEnabled = false;
    BraveWebDiscoveryEnabled = true;
    BraveRewardsDisabled = true;
    BraveVPNDisabled = true;
    BraveWalletDisabled = true;
    BraveAIChatEnabled = false;
    BraveRewardsIconHidden = true;
    BraveSyncEnabled = false;
    BraveExperimentalAdblockEnabled = true;
    BravePlaylistEnabled = false;
    BraveWaybackMachineEnabled = false;

    HardwareAccelerationModeEnabled = true;
    MemorySaverEnabled = true;
    BackgroundModeEnabled = false;
    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "Google";
    DefaultSearchProviderSearchURL = "www.google.com";
    "NewTabPageLocation" = "https://www.google.com";
    SyncDisabled = true;

    ShieldsAdvancedView = true;
    DefaultLocalFontsSetting = 2;
    PasswordLeakDetectionEnabled = false;
    QuickAnswersEnabled = false;
    SafeBrowseSurveysEnabled = false;
    SafeBrowseDeepScanningEnabled = false;
    DeviceActivityHeartbeatEnabled = false;
    DeviceMetricsReportingEnabled = false;
    HeartbeatEnabled = false;
    LogUploadEnabled = false;
    SpellcheckEnabled = true;
    SpellcheckLanguage = [ "en-US" ];

    ReportAppInventory = [ "" ];
    ReportDeviceActivityTimes = false;
    ReportDeviceAppInfo = false;
    ReportDeviceSystemInfo = false;
    ReportDeviceUsers = false;
    ReportWebsiteTelemetry = [ "" ];
    AlternateErrorPagesEnabled = false;
    AutofillCreditCardEnabled = false;
    BrowserGuestModeEnabled = false;
    BrowserSignin = 0;
    BuiltInDnsClientEnabled = false;
    DefaultBrowserSettingEnabled = true;
    SafeBrowsingExtendedReportingEnabled = false;
    SafeBrowsingSurveysEnabled = false;
    SafeBrowsingDeepScanningEnabled = false;
    ParcelTrackingEnabled = false;
    RelatedWebsiteSetsEnabled = false;
    ShoppingListEnabled = false;
    ExtensionManifestV2Availability = 2;

    # Inject the extension list into the policy
    ExtensionInstallForcelist = map (id: "${id};https://clients2.google.com/service/update2/crx") managedExtensions;
  };
in
{
  options.userSettings.browsers.brave = {
    # Store policies in an option so the system module can access them
    policies = lib.mkOption {
      type = lib.types.attrs;
      default = bravePolicies;
      description = "Managed policies for Brave browser";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.brave = {
      enable = true;
      package = pkgs.brave;
    };
  };
}
