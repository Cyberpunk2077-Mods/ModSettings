param(
    [string]$WolvenKit,
    [switch]$VerifyOnly
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$source = Join-Path $root 'src/wolvenkit/source/archive'
$locales = Join-Path $root 'src/archiveXL/base/localization'
$packed = Join-Path $root 'src/wolvenkit/packed/archive/pc/mod/ModSettings.archive'
$manifest = Join-Path $root 'src/archiveXL/archive-inputs.sha256'

function Get-InputHashes {
    $files = @(Get-ChildItem $source -Recurse -File) + @(Get-ChildItem $locales -Recurse -Filter '*.json')
    $files += Get-Item (Join-Path $root 'src/archiveXL/ModSettings.archive.xl')
    $files += Get-Item (Join-Path $root 'src/archiveXL/language-names.json')
    $files += Get-Item $PSCommandPath
    $files += Get-Item $packed
    return @($files | Sort-Object FullName | ForEach-Object {
        $relative = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
        if ($_.FullName.StartsWith((Join-Path $root 'src/archiveXL')) -or $_.Extension -eq '.ps1') {
            # Git may check text out as CRLF on Windows and LF elsewhere.
            $bytes = [Text.Encoding]::UTF8.GetBytes([IO.File]::ReadAllText($_.FullName).Replace("`r`n", "`n"))
            $sha = [Security.Cryptography.SHA256]::Create()
            try { $hash = [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '') }
            finally { $sha.Dispose() }
        } else {
            $hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
        }
        '{0}  {1}' -f $hash, $relative
    })
}

$resources = @(Get-ChildItem $locales -Recurse -Filter '*.json')
$languageNames = Get-Content (Join-Path $root 'src/archiveXL/language-names.json') -Raw -Encoding utf8 | ConvertFrom-Json
if (Compare-Object @($resources.Directory.Parent.Name | Sort-Object) @($languageNames.PSObject.Properties.Name | Sort-Object)) {
    throw 'Language names must match the 19 resource directories.'
}
if ($resources.Count -ne 19) { throw 'Expected 19 language resources.' }
$expectedKeys = $null
foreach ($resource in $resources) {
    $data = Get-Content $resource.FullName -Raw -Encoding utf8 | ConvertFrom-Json
    $entries = @($data.Data.RootChunk.root.Data.entries)
    $keys = @($entries.secondaryKey | Sort-Object)
    if (@($keys | Select-Object -Unique).Count -ne $keys.Count) { throw "Duplicate keys: $resource" }
    if ($entries.Where({ [string]::IsNullOrWhiteSpace($_.femaleVariant) }).Count) { throw "Empty translation: $resource" }
    if ($null -eq $expectedKeys) { $expectedKeys = $keys }
    if (Compare-Object $expectedKeys $keys) { throw "Mismatched translation keys: $resource" }
}
if ($VerifyOnly) {
    if (!(Test-Path $manifest)) { throw 'Rebuild the localization archive to create its input manifest.' }
    if (Compare-Object (Get-Content $manifest) (Get-InputHashes)) {
        throw 'Localization archive is stale. Run tools/Build-LocalizationArchive.ps1 -WolvenKit <CLI path>.'
    }
    Write-Output 'Verified 19 language resources and archive input hashes.'
    return
}
if (!(Test-Path $WolvenKit -PathType Leaf)) { throw 'Provide the WolvenKit CLI executable path.' }
$WolvenKit = (Resolve-Path $WolvenKit).Path
# A new staging directory prevents obsolete resources from entering the archive.
$work = Join-Path ([IO.Path]::GetTempPath()) ('mod-settings-localization-' + [guid]::NewGuid().ToString('N'))
$stage = Join-Path $work 'ModSettings'
$json = Join-Path $work 'json'
$out = Join-Path $work 'packed'
New-Item -ItemType Directory -Force $stage, $json, $out | Out-Null
Copy-Item (Join-Path $source '*') $stage -Recurse
foreach ($resource in $resources) {
    $relative = $resource.FullName.Substring((Join-Path $root 'src/archiveXL').Length + 1)
    $target = Join-Path $json ($relative + '.json')
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
    $data = Get-Content $resource.FullName -Raw -Encoding utf8 | ConvertFrom-Json
    $entries = @($data.Data.RootChunk.root.Data.entries)
    # Explicit-language aliases let this menu change language without changing
    # the game's global language or requiring an additional runtime dependency.
    foreach ($translation in $resources) {
        $locale = $translation.Directory.Parent.Name
        $translated = Get-Content $translation.FullName -Raw -Encoding utf8 | ConvertFrom-Json
        foreach ($entry in $translated.Data.RootChunk.root.Data.entries) {
            $entries += [ordered]@{
                '$type' = 'localizationPersistenceOnScreenEntry'
                secondaryKey = $entry.secondaryKey + '.' + $locale
                femaleVariant = $entry.femaleVariant
            }
        }
    }
    foreach ($language in $languageNames.PSObject.Properties) {
        $entries += [ordered]@{
            '$type' = 'localizationPersistenceOnScreenEntry'
            secondaryKey = 'ModSettings-Language-' + $language.Name
            femaleVariant = $language.Value
        }
    }
    $data.Data.RootChunk.root.Data.entries = $entries
    $data | ConvertTo-Json -Depth 30 | Set-Content $target -Encoding utf8
}
& $WolvenKit convert deserialize $json
if ($LASTEXITCODE -ne 0) { throw 'WolvenKit localization conversion failed.' }
foreach ($resource in $resources) {
    $relative = $resource.FullName.Substring((Join-Path $root 'src/archiveXL').Length + 1)
    $binary = Join-Path $json $relative
    if (!(Test-Path $binary)) { throw "Missing converted resource: $relative" }
    $bytes = [IO.File]::ReadAllBytes($binary)
    if ([Text.Encoding]::ASCII.GetString($bytes, 0, 4) -ne 'CR2W') { throw "Invalid resource: $relative" }
    $target = Join-Path $stage $relative
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
    Copy-Item $binary $target -Force
}
& $WolvenKit pack $stage -o $out
if ($LASTEXITCODE -ne 0 -or !(Test-Path (Join-Path $out 'ModSettings.archive'))) { throw 'Archive packing failed.' }
Copy-Item (Join-Path $out 'ModSettings.archive') $packed -Force
Get-InputHashes | Set-Content $manifest -Encoding ascii
Write-Output "Rebuilt $packed; staging files: $work"
