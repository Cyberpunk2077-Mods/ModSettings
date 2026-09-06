// Resolve game/ArchiveXL keys while preserving literal labels supplied by mods.
public abstract class ModSettingsLocalization {
  public static func LanguageCode(index: Int32) -> String {
    if index < 1 || index > 19 {
      return "auto";
    };
    return StrReplace(NameToString(EnumValueToName(n"ModSettingsUILanguage", Cast<Int64>(index))), "_", "-");
  }

  public static func GetLanguage() -> String {
    let options: array<ref<ConfigVar>> = ModSettings.GetVars(n"UI-Labels-ModSettings", n"None");
    let option: ref<ModConfigVarEnum>;
    for entry in options {
      if Equals(entry.GetName(), n"language") {
        option = entry as ModConfigVarEnum;
        if IsDefined(option) {
          return ModSettingsLocalization.LanguageCode(option.GetIndex());
        };
      };
    };
    return "auto";
  }

  // These two captions were authored as literal English in the ink resource.
  public static func LocalizeChrome(widget: wref<inkWidget>) -> Void {
    let text: wref<inkText> = widget as inkText;
    let compound: wref<inkCompoundWidget> = widget as inkCompoundWidget;
    let i: Int32 = 0;
    if IsDefined(text) {
      if Equals(text.GetName(), n"mod_settings_label") {
        text.SetText(ModSettingsLocalization.Text(n"UI-Labels-ModSettings"));
      } else {
        if Equals(text.GetName(), n"noMods") {
          text.SetText(ModSettingsLocalization.Text(n"ModSettings-NoModsAvailable"));
        };
      };
    };
    if IsDefined(compound) {
      while i < compound.GetNumChildren() {
        ModSettingsLocalization.LocalizeChrome(compound.GetWidgetByIndex(i));
        i += 1;
      };
    };
  }

  public static func Text(key: CName) -> String {
    let text: String;
    let language: String;
    if Equals(key, n"") || Equals(key, n"None") {
      return "";
    };
    language = ModSettingsLocalization.GetLanguage();
    if NotEquals(language, "auto") {
      text = GetLocalizedTextByKey(StringToName(NameToString(key) + "." + language));
      if StrLen(text) > 0 {
        return text;
      };
    };
    text = GetLocalizedTextByKey(key);
    if StrLen(text) == 0 {
      return NameToString(key);
    };
    return text;
  }
}
