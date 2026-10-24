cask "doru" do
  os = on_system_conditional macos: "mac", linux: "linux"
  url_arch = on_system_conditional macos: "arm64",
                                   linux: on_arch_conditional(arm: "arm64", intel: "x86_64")
  url_ext = on_system_conditional macos: "dmg", linux: "AppImage"

  version "0.0.14"
  sha256 arm:          "b502f598db11e4b80d13cdd8dd9d78daafdd7ce3ea8c663c71e0500b531153ea",
         arm64_linux:  "b5aa2e1412eca56466266231f4a67ce9a83b3181f3cd621167639792e68f6df1",
         x86_64_linux: "756ba38c20abc215a815328596a4b3c5eb6621dfc0db13345955dfe8068cfded"

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
