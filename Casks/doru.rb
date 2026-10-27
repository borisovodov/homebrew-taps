cask "doru" do
  os = on_system_conditional macos: "mac", linux: "linux"
  url_arch = on_system_conditional macos: "arm64",
                                   linux: on_arch_conditional(arm: "arm64", intel: "x86_64")
  url_ext = on_system_conditional macos: "dmg", linux: "AppImage"

  version "0.0.26"
  sha256 arm:          "6cc7640e3a4d1e161ae8d6d22804c7fdbc8f4188fc2dd64795f49e7382cbdebc",
         arm64_linux:  "488c419fb249537ac949a011dc8281d9d592a325b20944a5fdfd952c353a80aa",
         x86_64_linux: "9c58094e0c5375fe94cdf95c5cdc02065e46edda241a20a2e44cd7691fdf583c"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :ventura

    app "Doru.app"

    zap trash: [
      "~/Library/Application Support/Doru",
      "~/Library/Preferences/org.doru.doru.plist",
      "~/Library/Saved Application State/org.doru.doru.savedState",
    ]
  end
  on_linux do
    app_image "doru-linux-#{url_arch}.AppImage", target: "Doru.AppImage"

    # AppImages carry no desktop integration of their own: write the desktop
    # entry, register the .doru/.gdz MIME types and extract the icon so the
    # launcher shows Dóru with a proper name and icon (matching the window's
    # app id org.doru.doru) and file managers associate the app with its file
    # types. `.ged` files are GEDCOM text; their type ships in
    # shared-mime-info itself (text/vnd.familysearch.gedcom), so the desktop
    # entry only declares it. The cache rebuilds keep the registration in
    # sync; the tools ship with shared-mime-info and desktop-file-utils.
    postflight_steps do
      mkdir_p "/home/{{user}}/.local/share/applications"
      write_file "/home/{{user}}/.local/share/applications/org.doru.doru.desktop", <<~DESKTOP
        [Desktop Entry]
        Type=Application
        # Must match the `name` stanza; the {{name}} template expands to the
        # names array and would render as ["Dóru"].
        Name=Dóru
        Comment=Local-first genealogy for the AI era
        Exec=/home/{{user}}/Applications/Doru.AppImage %U
        Icon=org.doru.doru
        Terminal=false
        Categories=Education;Science;
        MimeType=application/x-doru;application/x-gedzip;text/vnd.familysearch.gedcom;
      DESKTOP
      mkdir_p "/home/{{user}}/.local/share/mime/packages"
      write_file "/home/{{user}}/.local/share/mime/packages/org.doru.doru.xml", <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
          <mime-type type="application/x-doru">
            <comment>Dóru family tree</comment>
            <glob pattern="*.doru"/>
            <icon name="org.doru.doru"/>
          </mime-type>
          <mime-type type="application/x-gedzip">
            <comment>GEDZIP genealogy archive</comment>
            <glob pattern="*.gdz"/>
            <icon name="org.doru.doru"/>
          </mime-type>
        </mime-info>
      XML
      mkdir_p "/home/{{user}}/.local/share/icons/hicolor/512x512/apps"
      run "curl",
          args:           ["-fsSL", "-o", "/home/{{user}}/.local/share/icons/hicolor/512x512/apps/org.doru.doru.png",
                           "https://raw.githubusercontent.com/borisovodov/homebrew-taps/main/icons/org.doru.doru.png"],
          network_access: true,
          writable_paths: ["/home/{{user}}/.local/share/icons/hicolor/512x512/apps"]
      run "update-mime-database",
          args:           ["/home/{{user}}/.local/share/mime"],
          must_succeed:   false,
          writable_paths: ["/home/{{user}}/.local/share/mime"]
      run "update-desktop-database",
          args:           ["/home/{{user}}/.local/share/applications"],
          must_succeed:   false,
          writable_paths: ["/home/{{user}}/.local/share/applications"]
    end

    uninstall_postflight_steps do
      remove "/home/{{user}}/.local/share/applications/org.doru.doru.desktop"
      remove "/home/{{user}}/.local/share/mime/packages/org.doru.doru.xml"
      remove "/home/{{user}}/.local/share/icons/hicolor/512x512/apps/org.doru.doru.png"
      run "update-mime-database",
          args:           ["/home/{{user}}/.local/share/mime"],
          must_succeed:   false,
          writable_paths: ["/home/{{user}}/.local/share/mime"]
      run "update-desktop-database",
          args:           ["/home/{{user}}/.local/share/applications"],
          must_succeed:   false,
          writable_paths: ["/home/{{user}}/.local/share/applications"]
    end

    zap trash: [
      "~/.cache/Doru",
      "~/.config/Doru",
    ]
  end

  url "https://github.com/borisovodov/doru/releases/download/v#{version}/doru-#{os}-#{url_arch}.#{url_ext}"
  name "Dóru"
  desc "Local-first genealogy for the AI era"
  homepage "https://doru.family/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates false
end
