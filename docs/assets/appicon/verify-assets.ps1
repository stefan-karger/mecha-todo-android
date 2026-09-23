[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$androidNamespace = 'http://schemas.android.com/apk/res/android'

function Assert-Equal {
    param(
        [Parameter(Mandatory)] $Actual,
        [Parameter(Mandatory)] $Expected,
        [Parameter(Mandatory)] [string] $Label
    )

    if ($Actual -ne $Expected) {
        throw "$Label expected '$Expected' but found '$Actual'."
    }
}

function Read-XmlFile {
    param([Parameter(Mandatory)] [string] $Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Missing required asset: $Path"
    }

    return [xml](Get-Content -LiteralPath $Path -Raw)
}

function Get-AndroidAttribute {
    param(
        [Parameter(Mandatory)] [System.Xml.XmlElement] $Element,
        [Parameter(Mandatory)] [string] $Name
    )

    return $Element.GetAttribute($Name, $androidNamespace)
}

function Normalize-PathData {
    param([Parameter(Mandatory)] [string] $PathData)

    return [regex]::Replace($PathData, '[,\s]+', '').ToUpperInvariant()
}

function Get-SvgPathData {
    param([Parameter(Mandatory)] [xml] $Document)

    return @($Document.SelectNodes("//*[local-name()='path']") | ForEach-Object {
        Normalize-PathData -PathData $_.GetAttribute('d')
    })
}

function Get-AndroidPathData {
    param([Parameter(Mandatory)] [xml] $Document)

    return @($Document.SelectNodes("//*[local-name()='path']") | ForEach-Object {
        Normalize-PathData -PathData (Get-AndroidAttribute -Element $_ -Name 'pathData')
    })
}

function Get-PathsBelowId {
    param(
        [Parameter(Mandatory)] [xml] $Document,
        [Parameter(Mandatory)] [string] $Id
    )

    return @($Document.SelectNodes("//*[@id='$Id']//*[local-name()='path']") | ForEach-Object {
        Normalize-PathData -PathData $_.GetAttribute('d')
    })
}

function Assert-PathParity {
    param(
        [Parameter(Mandatory)] [xml] $Svg,
        [Parameter(Mandatory)] [xml] $Android,
        [Parameter(Mandatory)] [string] $Label
    )

    $svgPaths = Get-SvgPathData -Document $Svg
    $androidPaths = Get-AndroidPathData -Document $Android
    Assert-Equal -Actual $androidPaths.Count -Expected $svgPaths.Count -Label "$Label path count"

    for ($index = 0; $index -lt $svgPaths.Count; $index++) {
        Assert-Equal -Actual $androidPaths[$index] -Expected $svgPaths[$index] -Label "$Label path $($index + 1)"
    }
}

function Assert-PreviewPathParity {
    param(
        [Parameter(Mandatory)] [xml] $Source,
        [Parameter(Mandatory)] [xml] $Preview,
        [Parameter(Mandatory)] [string] $PreviewGroupId,
        [Parameter(Mandatory)] [string] $Label
    )

    $sourcePaths = Get-SvgPathData -Document $Source
    $previewPaths = Get-PathsBelowId -Document $Preview -Id $PreviewGroupId
    Assert-Equal -Actual $previewPaths.Count -Expected $sourcePaths.Count -Label "$Label preview path count"

    for ($index = 0; $index -lt $sourcePaths.Count; $index++) {
        Assert-Equal -Actual $previewPaths[$index] -Expected $sourcePaths[$index] -Label "$Label preview path $($index + 1)"
    }
}

function Assert-SvgCanvas {
    param(
        [Parameter(Mandatory)] [xml] $Document,
        [Parameter(Mandatory)] [string] $Label
    )

    Assert-Equal -Actual $Document.DocumentElement.GetAttribute('width') -Expected '108' -Label "$Label width"
    Assert-Equal -Actual $Document.DocumentElement.GetAttribute('height') -Expected '108' -Label "$Label height"
    Assert-Equal -Actual $Document.DocumentElement.GetAttribute('viewBox') -Expected '0 0 512 512' -Label "$Label viewBox"
}

function Assert-AndroidCanvas {
    param(
        [Parameter(Mandatory)] [xml] $Document,
        [Parameter(Mandatory)] [string] $Label
    )

    $root = $Document.DocumentElement
    Assert-Equal -Actual (Get-AndroidAttribute -Element $root -Name 'width') -Expected '108dp' -Label "$Label width"
    Assert-Equal -Actual (Get-AndroidAttribute -Element $root -Name 'height') -Expected '108dp' -Label "$Label height"
    Assert-Equal -Actual (Get-AndroidAttribute -Element $root -Name 'viewportWidth') -Expected '512' -Label "$Label viewport width"
    Assert-Equal -Actual (Get-AndroidAttribute -Element $root -Name 'viewportHeight') -Expected '512' -Label "$Label viewport height"
}

function Get-InheritedSvgAttribute {
    param([System.Xml.XmlElement] $Element, [string] $Name)

    $node = $Element
    while ($node -is [System.Xml.XmlElement]) {
        if ($node.HasAttribute($Name)) { return $node.GetAttribute($Name) }
        $node = $node.ParentNode
    }
    return ''
}

function Assert-ForegroundPaintParity {
    param([xml] $Svg, [xml] $Android, [xml] $Preview)

    $svgPaths = $Svg.SelectNodes("//*[local-name()='path']")
    $androidPaths = $Android.SelectNodes("//*[local-name()='path']")
    $previewPaths = $Preview.SelectNodes("//*[@id='preview-foreground-layer']//*[local-name()='path']")
    for ($index = 0; $index -lt $svgPaths.Count; $index++) {
        $label = "Foreground path $($index + 1)"
        foreach ($property in 'fill', 'stroke', 'stroke-width', 'stroke-linecap', 'stroke-linejoin', 'fill-rule') {
            Assert-Equal -Actual (Get-InheritedSvgAttribute $previewPaths[$index] $property) `
                -Expected (Get-InheritedSvgAttribute $svgPaths[$index] $property) -Label "$label preview $property"
        }
        foreach ($pair in @(@('stroke-width', 'strokeWidth'), @('stroke-linecap', 'strokeLineCap'), @('stroke-linejoin', 'strokeLineJoin'))) {
            Assert-Equal -Actual (Get-AndroidAttribute $androidPaths[$index] $pair[1]) `
                -Expected (Get-InheritedSvgAttribute $svgPaths[$index] $pair[0]) -Label "$label Android $($pair[1])"
        }
        Assert-Equal -Actual (Get-AndroidAttribute $androidPaths[$index] 'fillType') -Expected 'evenOdd' -Label "$label fill rule"
        foreach ($pair in @(@('fill', 'fillColor'), @('stroke', 'strokeColor'))) {
            $paint = Get-InheritedSvgAttribute $svgPaths[$index] $pair[0]
            $androidGradient = $androidPaths[$index].SelectSingleNode("*[local-name()='attr' and @name='android:$($pair[1])']/*[local-name()='gradient']")
            if ($paint -match '^url\(#([\w-]+)\)$') {
                $gradientId = $Matches[1]
                $gradient = $Svg.SelectSingleNode("//*[local-name()='linearGradient' and @id='$gradientId']")
                $previewGradient = $Preview.SelectSingleNode("//*[local-name()='linearGradient' and @id='$gradientId']")
                if ($null -eq $gradient -or $null -eq $previewGradient -or $null -eq $androidGradient) {
                    throw "$label is missing gradient $gradientId in SVG, Android, or preview."
                }
                Assert-Equal -Actual $gradient.GetAttribute('gradientUnits') -Expected 'userSpaceOnUse' -Label "$gradientId coordinate space"
                Assert-Equal -Actual $previewGradient.GetAttribute('gradientUnits') -Expected 'userSpaceOnUse' -Label "$gradientId preview coordinate space"
                Assert-Equal -Actual (Get-AndroidAttribute $androidGradient 'type') -Expected 'linear' -Label "$gradientId Android type"
                foreach ($axis in @(@('x1','startX'), @('y1','startY'), @('x2','endX'), @('y2','endY'))) {
                    Assert-Equal -Actual (Get-AndroidAttribute $androidGradient $axis[1]) -Expected $gradient.GetAttribute($axis[0]) -Label "$gradientId Android $($axis[1])"
                    Assert-Equal -Actual $previewGradient.GetAttribute($axis[0]) -Expected $gradient.GetAttribute($axis[0]) -Label "$gradientId preview $($axis[0])"
                }
                $stops = $gradient.SelectNodes("*[local-name()='stop']")
                $previewStops = $previewGradient.SelectNodes("*[local-name()='stop']")
                $androidStops = $androidGradient.SelectNodes("*[local-name()='item']")
                Assert-Equal -Actual $previewStops.Count -Expected $stops.Count -Label "$gradientId preview stop count"
                Assert-Equal -Actual $androidStops.Count -Expected $stops.Count -Label "$gradientId Android stop count"
                for ($stopIndex = 0; $stopIndex -lt $stops.Count; $stopIndex++) {
                    $offset = $stops[$stopIndex].GetAttribute('offset')
                    $color = $stops[$stopIndex].GetAttribute('stop-color')
                    Assert-Equal -Actual $previewStops[$stopIndex].GetAttribute('offset') -Expected $offset -Label "$gradientId preview stop $stopIndex offset"
                    Assert-Equal -Actual $previewStops[$stopIndex].GetAttribute('stop-color') -Expected $color -Label "$gradientId preview stop $stopIndex color"
                    Assert-Equal -Actual (Get-AndroidAttribute $androidStops[$stopIndex] 'offset') -Expected $offset -Label "$gradientId Android stop $stopIndex offset"
                    Assert-Equal -Actual (Get-AndroidAttribute $androidStops[$stopIndex] 'color') -Expected ('#FF' + $color.Substring(1)) -Label "$gradientId Android stop $stopIndex color"
                }
            } else {
                if ($null -ne $androidGradient) { throw "$label has an unexpected Android gradient." }
                $expected = if ($paint -eq 'none') { '#00000000' } elseif ($paint) { '#FF' + $paint.Substring(1) } else { '' }
                Assert-Equal -Actual (Get-AndroidAttribute $androidPaths[$index] $pair[1]) -Expected $expected -Label "$label Android $($pair[1])"
            }
        }
    }
}

function Assert-SymmetricForegroundShading {
    param([xml] $Svg)

    # The existing traced silhouette is slightly irregular. Added helmet facets
    # must be exact reflections about its x=255.8 design axis.
    $leftFacets = $Svg.SelectNodes("//*[@id='fg-surface-facets']/*[substring(@id, string-length(@id) - 4) = '-left']")
    Assert-Equal -Actual $leftFacets.Count -Expected 10 -Label 'Mirrored helmet facet pairs'
    foreach ($left in $leftFacets) {
        $rightId = $left.GetAttribute('id') -replace '-left$', '-right'
        $right = $Svg.SelectSingleNode("//*[@id='$rightId']")
        if ($null -eq $right) { throw "Missing mirrored facet $rightId." }
        $leftTokens = [regex]::Matches($left.GetAttribute('d'), '[MLZ]|-?\d+(?:\.\d+)?')
        $rightTokens = [regex]::Matches($right.GetAttribute('d'), '[MLZ]|-?\d+(?:\.\d+)?')
        Assert-Equal -Actual $rightTokens.Count -Expected $leftTokens.Count -Label "$rightId token count"
        $isX = $true
        for ($index = 0; $index -lt $leftTokens.Count; $index++) {
            $token = $leftTokens[$index].Value
            if ($token -match '^[MLZ]$') {
                Assert-Equal -Actual $rightTokens[$index].Value -Expected $token -Label "$rightId path command"
                $isX = $true
            } else {
                $leftValue = [double]::Parse($token, [Globalization.CultureInfo]::InvariantCulture)
                $rightValue = [double]::Parse($rightTokens[$index].Value, [Globalization.CultureInfo]::InvariantCulture)
                $expected = if ($isX) { 511.6 - $leftValue } else { $leftValue }
                if ([math]::Abs($rightValue - $expected) -gt 0.001) { throw "$rightId is not a mirrored facet." }
                $isX = -not $isX
            }
        }
        $leftPaint = $left.GetAttribute('fill') -replace '^url\(#|\)$', ''
        $rightPaint = $right.GetAttribute('fill') -replace '^url\(#|\)$', ''
        $leftGradient = $Svg.SelectSingleNode("//*[@id='$leftPaint']")
        $rightGradient = $Svg.SelectSingleNode("//*[@id='$rightPaint']")
        foreach ($axis in 'x1', 'y1', 'x2', 'y2') {
            $leftValue = [double]::Parse($leftGradient.GetAttribute($axis), [Globalization.CultureInfo]::InvariantCulture)
            $rightValue = [double]::Parse($rightGradient.GetAttribute($axis), [Globalization.CultureInfo]::InvariantCulture)
            $expected = if ($axis.StartsWith('x')) { 511.6 - $leftValue } else { $leftValue }
            if ([math]::Abs($rightValue - $expected) -gt 0.001) { throw "$rightId has an asymmetric gradient." }
        }
        Assert-Equal -Actual $rightGradient.InnerXml -Expected $leftGradient.InnerXml -Label "$rightId gradient stops"
    }
    foreach ($pair in @(@('fg-shell-left','fg-shell-right'), @('fg-lower-left','fg-lower-right'), @('fg-accent-1','fg-accent-2'), @('fg-accent-3','fg-accent-4'))) {
        $left = $Svg.SelectSingleNode("//*[@id='$($pair[0])']")
        $right = $Svg.SelectSingleNode("//*[@id='$($pair[1])']")
        Assert-Equal -Actual $right.InnerXml -Expected $left.InnerXml -Label "$($pair[0]) paired gradient stops"
        foreach ($axis in 'x1', 'y1', 'x2', 'y2') {
            Assert-Equal -Actual $right.GetAttribute($axis) -Expected $left.GetAttribute($axis) -Label "$($pair[0]) paired gradient $axis"
        }
    }
}

$backgroundSvgPath = Join-Path $PSScriptRoot 'appicon-background.svg'
$foregroundSvgPath = Join-Path $PSScriptRoot 'appicon-foreground.svg'
$monochromeSvgPath = Join-Path $PSScriptRoot 'appicon-monochrome.svg'
$previewSvgPath = Join-Path $PSScriptRoot 'appicon-preview.svg'
$backgroundAndroidPath = Join-Path $PSScriptRoot 'android/drawable/ic_launcher_background.xml'
$foregroundAndroidPath = Join-Path $PSScriptRoot 'android/drawable/ic_launcher_foreground.xml'
$monochromeAndroidPath = Join-Path $PSScriptRoot 'android/drawable/ic_launcher_monochrome.xml'
$adaptiveV26Path = Join-Path $PSScriptRoot 'android/mipmap-anydpi-v26/ic_launcher.xml'
$adaptiveV33Path = Join-Path $PSScriptRoot 'android/mipmap-anydpi-v33/ic_launcher.xml'

$backgroundSvg = Read-XmlFile -Path $backgroundSvgPath
$foregroundSvg = Read-XmlFile -Path $foregroundSvgPath
$monochromeSvg = Read-XmlFile -Path $monochromeSvgPath
$previewSvg = Read-XmlFile -Path $previewSvgPath
$backgroundAndroid = Read-XmlFile -Path $backgroundAndroidPath
$foregroundAndroid = Read-XmlFile -Path $foregroundAndroidPath
$monochromeAndroid = Read-XmlFile -Path $monochromeAndroidPath
$adaptiveV26 = Read-XmlFile -Path $adaptiveV26Path
$adaptiveV33 = Read-XmlFile -Path $adaptiveV33Path

Assert-SvgCanvas -Document $backgroundSvg -Label 'Background SVG'
Assert-SvgCanvas -Document $foregroundSvg -Label 'Foreground SVG'
Assert-SvgCanvas -Document $monochromeSvg -Label 'Monochrome SVG'
Assert-Equal -Actual $previewSvg.DocumentElement.GetAttribute('width') -Expected '784' -Label 'Preview SVG width'
Assert-Equal -Actual $previewSvg.DocumentElement.GetAttribute('height') -Expected '158' -Label 'Preview SVG height'
Assert-Equal -Actual $previewSvg.DocumentElement.GetAttribute('viewBox') -Expected '0 0 784 158' -Label 'Preview SVG viewBox'
Assert-AndroidCanvas -Document $backgroundAndroid -Label 'Background Android vector'
Assert-AndroidCanvas -Document $foregroundAndroid -Label 'Foreground Android vector'
Assert-AndroidCanvas -Document $monochromeAndroid -Label 'Monochrome Android vector'

Assert-PathParity -Svg $backgroundSvg -Android $backgroundAndroid -Label 'Background'
Assert-PathParity -Svg $foregroundSvg -Android $foregroundAndroid -Label 'Foreground'
Assert-PathParity -Svg $monochromeSvg -Android $monochromeAndroid -Label 'Monochrome'
Assert-PreviewPathParity -Source $backgroundSvg -Preview $previewSvg -PreviewGroupId 'preview-background-layer' -Label 'Background'
Assert-PreviewPathParity -Source $foregroundSvg -Preview $previewSvg -PreviewGroupId 'preview-foreground-layer' -Label 'Foreground'
Assert-PreviewPathParity -Source $monochromeSvg -Preview $previewSvg -PreviewGroupId 'preview-monochrome-layer' -Label 'Monochrome'
Assert-ForegroundPaintParity -Svg $foregroundSvg -Android $foregroundAndroid -Preview $previewSvg
Assert-SymmetricForegroundShading -Svg $foregroundSvg
Assert-Equal -Actual $foregroundSvg.SelectNodes("//*[local-name()='filter' or local-name()='image']").Count -Expected 0 -Label 'Foreground raster images or filters'

# The original helmet, boxes, and bars remain in the monochrome layer.
# The foreground ticks are deliberately shorter and thinner to clear the boxes.
$foregroundPaths = Get-SvgPathData -Document $foregroundSvg
foreach ($path in (Get-SvgPathData -Document $monochromeSvg)) {
    if ($path -in @('M170203L182214L199194', 'M170275L182286L199266')) { continue }
    Assert-Equal -Actual @($foregroundPaths | Where-Object { $_ -ceq $path }).Count -Expected 1 -Label 'Foreground original shape count'
}

$expectedSvgTransform = 'translate(256 256) scale(0.6) translate(-256 -256)'
foreach ($entry in @(
    @{ Document = $foregroundSvg; Label = 'Foreground SVG' },
    @{ Document = $monochromeSvg; Label = 'Monochrome SVG' },
    @{ Document = $previewSvg; Label = 'Preview foreground'; Id = 'preview-foreground-layer' },
    @{ Document = $previewSvg; Label = 'Preview monochrome'; Id = 'preview-monochrome-layer' }
)) {
    $group = if ($entry.ContainsKey('Id')) {
        $entry.Document.SelectSingleNode("//*[@id='$($entry.Id)']")
    } else {
        $entry.Document.SelectSingleNode("//*[local-name()='g' and @transform]")
    }
    Assert-Equal -Actual $group.GetAttribute('transform') -Expected $expectedSvgTransform -Label "$($entry.Label) transform"
}

Assert-Equal -Actual $previewSvg.SelectNodes("//*[local-name()='image']").Count -Expected 0 -Label 'Preview external image count'
Assert-Equal -Actual $previewSvg.SelectNodes("//*[contains(concat(' ', normalize-space(@class), ' '), ' launcher-preview ')]").Count -Expected 6 -Label 'Launcher preview count'
foreach ($use in $previewSvg.SelectNodes("//*[local-name()='use']")) {
    if (-not $use.GetAttribute('href').StartsWith('#', [System.StringComparison]::Ordinal)) {
        throw "Preview use element has an external reference: $($use.GetAttribute('href'))"
    }
}

foreach ($entry in @(
    @{ Document = $foregroundAndroid; Label = 'Foreground Android vector' },
    @{ Document = $monochromeAndroid; Label = 'Monochrome Android vector' }
)) {
    $group = $entry.Document.SelectSingleNode("//*[local-name()='group']")
    Assert-Equal -Actual (Get-AndroidAttribute -Element $group -Name 'pivotX') -Expected '256' -Label "$($entry.Label) pivot X"
    Assert-Equal -Actual (Get-AndroidAttribute -Element $group -Name 'pivotY') -Expected '256' -Label "$($entry.Label) pivot Y"
    Assert-Equal -Actual (Get-AndroidAttribute -Element $group -Name 'scaleX') -Expected '0.6' -Label "$($entry.Label) scale X"
    Assert-Equal -Actual (Get-AndroidAttribute -Element $group -Name 'scaleY') -Expected '0.6' -Label "$($entry.Label) scale Y"
}

$v26Monochrome = $adaptiveV26.SelectNodes("//*[local-name()='monochrome']")
$v33Monochrome = $adaptiveV33.SelectNodes("//*[local-name()='monochrome']")
Assert-Equal -Actual $v26Monochrome.Count -Expected 0 -Label 'API 26 monochrome element count'
Assert-Equal -Actual $v33Monochrome.Count -Expected 1 -Label 'API 33 monochrome element count'

foreach ($entry in @(
    @{ Document = $adaptiveV26; Label = 'API 26 adaptive icon'; Monochrome = $false },
    @{ Document = $adaptiveV33; Label = 'API 33 adaptive icon'; Monochrome = $true }
)) {
    $background = $entry.Document.SelectSingleNode("//*[local-name()='background']")
    $foreground = $entry.Document.SelectSingleNode("//*[local-name()='foreground']")
    Assert-Equal -Actual (Get-AndroidAttribute -Element $background -Name 'drawable') -Expected '@drawable/ic_launcher_background' -Label "$($entry.Label) background"
    Assert-Equal -Actual (Get-AndroidAttribute -Element $foreground -Name 'drawable') -Expected '@drawable/ic_launcher_foreground' -Label "$($entry.Label) foreground"

    if ($entry.Monochrome) {
        $monochrome = $entry.Document.SelectSingleNode("//*[local-name()='monochrome']")
        Assert-Equal -Actual (Get-AndroidAttribute -Element $monochrome -Name 'drawable') -Expected '@drawable/ic_launcher_monochrome' -Label "$($entry.Label) monochrome"
    }
}

$backgroundSvgText = Get-Content -LiteralPath $backgroundSvgPath -Raw
$backgroundAndroidText = Get-Content -LiteralPath $backgroundAndroidPath -Raw
$previewSvgText = Get-Content -LiteralPath $previewSvgPath -Raw
foreach ($color in '#231133', '#0B0911', '#0C2118', '#B86CFF', '#45FF63') {
    if (-not $backgroundSvgText.Contains($color, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Background SVG is missing palette color $color."
    }
}
foreach ($color in '#231133', '#0B0911', '#0C2118', '#B86CFF', '#45FF63') {
    if (-not $previewSvgText.Contains($color, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Preview SVG is missing palette color $color."
    }
}
foreach ($color in '#FF231133', '#FF0B0911', '#FF0C2118', '#1AB86CFF', '#1645FF63') {
    if (-not $backgroundAndroidText.Contains($color, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Background Android vector is missing palette color $color."
    }
}

Write-Output 'Adaptive icon assets are consistent: SVG/Android paints and gradients, mirrored helmet shading, preview paints and gradients, original shapes, and API 26/API 33 definitions.'
