[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not (Get-Command magick -ErrorAction SilentlyContinue)) {
    throw 'ImageMagick 7 (magick) is required to render the splash previews.'
}

$sourceDir = Join-Path $PSScriptRoot '../appicon'
& (Join-Path $sourceDir 'verify-assets.ps1')

$drawableDir = Join-Path $PSScriptRoot 'android/drawable'
[void][System.IO.Directory]::CreateDirectory($drawableDir)

# Keep all geometry, gradients, strokes, and the centered 0.6 scale intact.
# Only the intrinsic size changes from the launcher layer's 108 dp to 288 dp.
$androidSource = Get-Content -LiteralPath (Join-Path $sourceDir 'android/drawable/ic_launcher_foreground.xml') -Raw
$androidSplash = $androidSource.Replace('android:width="108dp"', 'android:width="288dp"').Replace('android:height="108dp"', 'android:height="288dp"')
if ($androidSplash -ceq $androidSource) { throw 'Launcher drawable dimensions changed; review splash sizing.' }
[System.IO.File]::WriteAllText((Join-Path $drawableDir 'ic_splash.xml'), $androidSplash)

$svgSource = Get-Content -LiteralPath (Join-Path $sourceDir 'appicon-foreground.svg') -Raw
$svgSplash = $svgSource.Replace('width="108" height="108"', 'width="288" height="288"')
$svgSplash = $svgSplash.Replace('MECHA//TODO adaptive icon foreground', 'MECHA//TODO splash icon')
$svgSplash = $svgSplash.Replace('inside the Android adaptive icon safe zone.', 'on a transparent splash canvas with a 192 dp safe circle.')
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot 'splash-icon.svg'), $svgSplash)

[xml]$colors = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'android/values/splash_colors.xml') -Raw
$background = $colors.resources.color.InnerText
$art = [regex]::Replace($svgSplash, '(?s)^<svg[^>]*>\s*<title[^>]*>.*?</title>\s*<desc[^>]*>.*?</desc>', '')
$art = [regex]::Replace($art, '</svg>\s*$', '')

# Preview pixels represent dp at mdpi. System bars and OEM placement are omitted.
foreach ($preview in @(
    @{ Name = 'splash-preview'; Width = 360; Height = 800; Guide = $false },
    @{ Name = 'splash-preview-landscape'; Width = 800; Height = 360; Guide = $false },
    @{ Name = 'splash-safe-area'; Width = 288; Height = 288; Guide = $true }
)) {
    $width = $preview.Width
    $height = $preview.Height
    $iconX = ($width - 288) / 2
    $iconY = ($height - 288) / 2
    $guide = if ($preview.Guide) {
        '<circle cx="144" cy="144" r="96" fill="none" stroke="#F5F1F8" stroke-width="1" stroke-dasharray="4 4" />'
    } else { '' }
    $markup = @"
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height" role="img" aria-labelledby="preview-title">
  <title id="preview-title">MECHA//TODO splash placement preview</title>
  <rect width="$width" height="$height" fill="$background" />
  <svg x="$iconX" y="$iconY" width="288" height="288" viewBox="0 0 512 512">
$art
  </svg>
  $guide
</svg>
"@
    $svgPath = Join-Path $PSScriptRoot ($preview.Name + '.svg')
    $pngPath = Join-Path $PSScriptRoot ($preview.Name + '.png')
    [System.IO.File]::WriteAllText($svgPath, $markup)
    & magick -background none $svgPath -colorspace sRGB -depth 8 "PNG32:$pngPath"
    if ($LASTEXITCODE -ne 0) { throw "Could not render $svgPath" }
}

Write-Output 'Generated splash drawable, SVG, portrait and landscape previews, and safe-circle preview from the current launcher foreground.'
