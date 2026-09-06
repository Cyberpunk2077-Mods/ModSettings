param([Parameter(Mandatory)][string]$ExtractedJsonRoot)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$sources = @(Get-ChildItem (Join-Path $root 'src/archiveXL/base/localization') -Recurse -Filter '*.json')
$names = Get-Content (Join-Path $root 'src/archiveXL/language-names.json') -Raw -Encoding utf8 | ConvertFrom-Json
$exports = @(Get-ChildItem $ExtractedJsonRoot -Recurse -Filter '*.json.json')
if ($exports.Count -ne 19) { throw "Expected 19 exported CR2W localization files, got $($exports.Count)." }
$aliases = @{}
foreach ($source in $sources) {
    $locale = $source.Directory.Parent.Name
    $entries = (Get-Content $source.FullName -Raw -Encoding utf8 | ConvertFrom-Json).Data.RootChunk.root.Data.entries
    foreach ($entry in $entries) { $aliases[$entry.secondaryKey + '.' + $locale] = $entry.femaleVariant }
}
foreach ($export in $exports) {
    $locale = $export.Directory.Parent.Name
    $source = $sources | Where-Object { $_.Directory.Parent.Name -eq $locale }
    if (!$source) { throw "Unexpected locale: $locale" }
    $expected = $aliases.Clone()
    $entries = (Get-Content $source.FullName -Raw -Encoding utf8 | ConvertFrom-Json).Data.RootChunk.root.Data.entries
    foreach ($entry in $entries) { $expected[$entry.secondaryKey] = $entry.femaleVariant }
    foreach ($name in $names.PSObject.Properties) { $expected['ModSettings-Language-' + $name.Name] = $name.Value }
    $actual = @((Get-Content $export.FullName -Raw -Encoding utf8 | ConvertFrom-Json).Data.RootChunk.root.Data.entries)
    if ($actual.Count -ne $expected.Count) { throw "Unexpected entry count in $locale" }
    $seen = @{}
    foreach ($entry in $actual) {
        if ($seen.ContainsKey($entry.secondaryKey)) { throw "Duplicate key in $locale" }
        $seen[$entry.secondaryKey] = $true
        if (!$expected.ContainsKey($entry.secondaryKey) -or $expected[$entry.secondaryKey] -cne $entry.femaleVariant) {
            throw "Translation mismatch: $locale / $($entry.secondaryKey)"
        }
    }
}
Write-Output "Verified all 19 archived languages, explicit-language aliases and native language names against source."
