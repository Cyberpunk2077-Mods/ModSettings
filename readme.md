# Mod Settings

[![](https://byob.yarr.is/jackhumbert/mod_settings/cp_version)](https://github.com/jackhumbert/mod_settings/actions/workflows/build.yaml)

![Wt2Z4fgfQT](https://user-images.githubusercontent.com/141431/223482953-f7860657-62dd-4cc9-90ea-e099edfa1691.jpg)

## Installation

[Get the latest release here](https://github.com/jackhumbert/mod_settings/releases). Extract `packed-v*.zip` into the game's installation folder. Install the requirements listed below separately; they are not bundled in the release archive.

If you want to install the mod outside of a release (not recommended), the `build/` folder in the repo contains all of the mod-specific files that you can drag into your game's installation folder.

## Configuration

Configuration is done through redscript classes. [See one example here](https://github.com/jackhumbert/in_world_navigation/blob/main/src/redscript/in_world_navigation/InWorldNavigation.reds). Variable & class names are limited to 1024 characters.

## Listen for changes

In Redscript, you can register the class (where you have your mod variables defined) as a listener to changes made in Mod Settings:

```swift
ModSettings.RegisterListenerToClass(this);
...
ModSettings.UnregisterListenerToClass(this);
```

The default values & runtime values will then be updated when settings are changed.

You can also listen to things globally via:

```swift
ModSettings.RegisterListenerToModifications(this);
```

Which will fire callbacks that must be named/look like this:

```swift
public cb func OnModVariableChangeRequested(groupPath: CName, varName: CName) -> Void { }
public cb func OnModVariableChangeAccepted(groupPath: CName, varName: CName) -> Void { }
public cb func OnModSettingsChange() -> Void { }
```

`groupPath` is equal to `/mods/[ModName]/[ModClass]`, and `varName` is equal to the variable name.


## Keybinding Configuration

Specify an .xml file to be processed by Input Loader like, defining a `overridableUI` attribute in a button inside of a mapping:

```xml
<?xml version="1.0"?>
<bindings>
    <context name="VehicleDriveBase" append="true">
        <action name="TestModAction" map="TestModMap"/>
    </context>
    <mapping name="TestModMap" type="Button" >
        <button id="IK_A" overridableUI="MyModTestButton" />
    </mapping>
</bindings>
```

On the redscript side, define a variable using the `overridableUI` value as the name in a class (any class) for your mod like this:

```swift
@runtimeProperty("ModSettings.mod", "Test mod")
public let MyModTestButton: EInputKey = EInputKey.IK_A;
```

You can then listen for your action when the context you specified in the .xml is active:

```swift
player.RegisterInputListener(this, n"TestModAction");
```

And respond to it with a callback: 

```swift
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool { 
  if Equals(ListenerAction.GetName(action), n"TestModAction") {
    ...
  }
}
```

## Advanced Configuration for Enums

```swift
enum ModSetting {
  OptionA = 0,
  OptionB = 1,
  OptionC = 2
}

class ModSettings {
  @runtimeProperty("ModSettings.mod", "Mod")
  @runtimeProperty("ModSettings.displayName", "UI-ModSetting-Label")
  @runtimeProperty("ModSettings.displayValues.OptionA", "UI-ModSetting-OptionA")
  @runtimeProperty("ModSettings.displayValues.OptionB", "Fixed Option B")
  public let setting: ModSetting = ModSetting.OptionA;
}
```

This example will produce the following results for enum values:

| Enum Value | Display Value |
| --- | --- |
| `OptionA` | Localized text `GetLocalizedText("UI-ModSetting-OptionA")`  |
| `OptionB` | Fixed text `"Fixed Option B"`  |
| `OptionC` | Value name `"OptionC"`  |


## Requirements

* [RED4ext 1.30.0+](https://github.com/WopsS/RED4ext)
* [ArchiveXL 1.29.2+](https://github.com/psiberx/cp2077-archive-xl)
* [Redscript 0.5.31+](https://github.com/jac3km4/redscript)

_For the mod to work with REDmod deployments, the following mod is required:_
* [cybercmd](https://github.com/jac3km4/cybercmd)

If the game stops during startup after installing a mod that depends on Mod
Settings, first update all three requirements above. A failure to load
`mod_settings.dll` leaves the `ModSettings` redscript API unavailable, so the
dependent mod then fails redscript compilation. Check
`red4ext/logs/red4ext.log` for native plugin load errors and
`r6/logs/redscript_rCURRENT.log` for missing `ModSettings` types.

## Development

### Runtime string parsing and regression checks

Game RTTI string parsing is routed through `src/red4ext/GameStringParser.hpp`.
Cyberpunk 2.31 expects a borrowed pointer-and-length buffer at virtual slot
`0x70`; the SDK's `CString` declaration is not ABI-compatible with that input.
Do not replace this adapter with a direct `IType::FromString` call without
verifying the game's implementation.

From an x64 MSVC developer shell, build and run the isolated adapter test:

```powershell
cl /EHsc /std:c++17 tools/Test-GameStringParser.cpp /Fe:Test-GameStringParser.exe
./Test-GameStringParser.exe
python tools/test_script_packaging.py <cmake.exe-path> <ninja.exe-path>
```

These checks cover argument layout, failed parsing, and incremental script
packaging. They do not replace compiling the full plugin and testing game startup.
CI also retains the matching PDB as a separate artifact keyed by commit SHA.

### Interface language

The Mod Settings tab contains an interface language selector with Auto and all
19 game languages. Auto follows the game's current interface language. Select a
language and press Apply to save it in the existing
`red4ext/plugins/mod_settings/user.ini` configuration. The menu captions and
category labels refresh after applying the selection; menu entries use it when
the main, pause, or death menu is rebuilt.

The project supplies translations for its menu/title, empty state, language
option, description, and Auto option. Language names are shown in their native
scripts. Game-owned controls, input hints and confirmation messages continue to
use the game language. Their fonts also use the game's language resources;
cross-language glyph coverage requires in-game verification.

Third-party mod names, categories, descriptions and enum values resolve through
the same helper. A mod can provide `My-Key.zh-cn` (and equivalent suffixes) to
support an explicit menu language. Otherwise the helper falls back to `My-Key`
in the game language, then to the original literal. Existing registration APIs
are unchanged. Format labels resolve the template and each parameter separately;
each `%` consumes one parameter, preserving subsequent placeholders and literal
percent signs in replacement text. Third-party translations must be supplied by
their authors.

### Rebuilding localization resources

`src/archiveXL/base/localization` contains the 19 authoritative translation
files. `src/archiveXL/language-names.json` supplies native language names.
The build tool creates explicit-language aliases in every language resource,
converts them to CR2W, and packages them alongside the existing UI assets:

```powershell
./tools/Build-LocalizationArchive.ps1 -WolvenKit C:/tools/WolvenKit.CLI.exe
./tools/Build-LocalizationArchive.ps1 -VerifyOnly
```

Use WolvenKit Console 8.20.0 and its .NET 8 runtime. Commit the rebuilt
`src/wolvenkit/packed/archive/pc/mod/ModSettings.archive` and
`src/archiveXL/archive-inputs.sha256` with resource changes. CI checks translation
key parity, nonempty values, and input/archive hashes before building the DLL.
The runtime localizes the legacy literal title and empty-state widgets; the
original binary widget remains editable with the existing WolvenKit workflow.

Running `tools/ModStngs.1sc` on `mod_settings_main.inkwidget` will toggle between using a custom class (`ModStngs` replacing `Settings` in `SettingsMainGameController` and `SettingsSelectorController*`) so the file can be opened & edited in Wolvenkit. If you keep the file open in Wolvenkit, you won't need to convert back, and only run the script after you've saved it in Wolvenkit, before packing.

## Bugs

If you come across something that doesn't work quite right, or interferes with another mod, [search for or create an issue!](https://github.com/jackhumbert/mod_settings/issues) I have a lot of things on a private TODO list still, but can start to move things to Github issues.

Special thanks to @psiberx for [Codeware Lib](https://github.com/psiberx/cp2077-codeware/), [InkPlayground Demo](https://github.com/psiberx/cp2077-playground), and Redscript & CET examples on Discord, @WopsS for [RED4ext](https://github.com/WopsS/RED4ext), @jac3km4 for [Redscript toolkit](https://github.com/jac3km4/redscript), @yamashi for [CET](https://github.com/yamashi/CyberEngineTweaks), @rfuzzo & team (especially @seberoth!) for [WolvenKit](https://github.com/WolvenKit/WolvenKit), and all of them for being helpful on Discord.
