public enum ModSettingsUILanguage {
  auto = 0,
  ar_ar = 1,
  cz_cz = 2,
  de_de = 3,
  en_us = 4,
  es_es = 5,
  es_mx = 6,
  fr_fr = 7,
  hu_hu = 8,
  it_it = 9,
  jp_jp = 10,
  kr_kr = 11,
  pl_pl = 12,
  pt_br = 13,
  ru_ru = 14,
  th_th = 15,
  tr_tr = 16,
  ua_ua = 17,
  zh_cn = 18,
  zh_tw = 19
}

// Uses the existing Apply/Reset and user.ini persistence implementation.
public class ModSettingsUIConfig {
  @runtimeProperty("ModSettings.mod", "UI-Labels-ModSettings")
  @runtimeProperty("ModSettings.displayName", "ModSettings-UILanguage")
  @runtimeProperty("ModSettings.description", "ModSettings-LanguageDescription")
  @runtimeProperty("ModSettings.displayValues.auto", "ModSettings-Auto")
  @runtimeProperty("ModSettings.displayValues.ar_ar", "ModSettings-Language-ar-ar")
  @runtimeProperty("ModSettings.displayValues.cz_cz", "ModSettings-Language-cz-cz")
  @runtimeProperty("ModSettings.displayValues.de_de", "ModSettings-Language-de-de")
  @runtimeProperty("ModSettings.displayValues.en_us", "ModSettings-Language-en-us")
  @runtimeProperty("ModSettings.displayValues.es_es", "ModSettings-Language-es-es")
  @runtimeProperty("ModSettings.displayValues.es_mx", "ModSettings-Language-es-mx")
  @runtimeProperty("ModSettings.displayValues.fr_fr", "ModSettings-Language-fr-fr")
  @runtimeProperty("ModSettings.displayValues.hu_hu", "ModSettings-Language-hu-hu")
  @runtimeProperty("ModSettings.displayValues.it_it", "ModSettings-Language-it-it")
  @runtimeProperty("ModSettings.displayValues.jp_jp", "ModSettings-Language-jp-jp")
  @runtimeProperty("ModSettings.displayValues.kr_kr", "ModSettings-Language-kr-kr")
  @runtimeProperty("ModSettings.displayValues.pl_pl", "ModSettings-Language-pl-pl")
  @runtimeProperty("ModSettings.displayValues.pt_br", "ModSettings-Language-pt-br")
  @runtimeProperty("ModSettings.displayValues.ru_ru", "ModSettings-Language-ru-ru")
  @runtimeProperty("ModSettings.displayValues.th_th", "ModSettings-Language-th-th")
  @runtimeProperty("ModSettings.displayValues.tr_tr", "ModSettings-Language-tr-tr")
  @runtimeProperty("ModSettings.displayValues.ua_ua", "ModSettings-Language-ua-ua")
  @runtimeProperty("ModSettings.displayValues.zh_cn", "ModSettings-Language-zh-cn")
  @runtimeProperty("ModSettings.displayValues.zh_tw", "ModSettings-Language-zh-tw")
  public let language: ModSettingsUILanguage = ModSettingsUILanguage.auto;
}
