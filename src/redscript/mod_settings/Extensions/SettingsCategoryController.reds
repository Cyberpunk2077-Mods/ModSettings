@wrapMethod(SettingsCategoryController)
public final func Setup(label: CName) -> Void {
  if ModSettings.GetInstance().isActive {
    let labelString: String = ModSettingsLocalization.Text(label);
    inkTextRef.SetText(this.m_label, labelString);
  } else {
    wrappedMethod(label);
  }
}
