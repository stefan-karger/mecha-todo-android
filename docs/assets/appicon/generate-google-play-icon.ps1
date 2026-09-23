param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command magick -ErrorAction SilentlyContinue)) {
    throw 'ImageMagick 7 (magick) is required to export the Google Play icon.'
}

$sourcePath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../appicon_logo.png')).Path
$outputPath = Join-Path $PSScriptRoot 'google-play-icon.png'
$previewDir = Join-Path $PSScriptRoot 'google-play-previews'

function Invoke-Magick {
    param([Parameter(Mandatory)][string[]] $Arguments)

    & magick @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "ImageMagick exited with code $LASTEXITCODE."
    }
}

function Set-SrgbMetadata {
    param([Parameter(Mandatory)][string] $Path)

    # Some ImageMagick versions omit sRGB when there is no source ICC profile.
    # Tag the already-sRGB samples explicitly without changing their values.
    $pngBytes = [System.IO.File]::ReadAllBytes($Path)
    $chunkOffset = 8
    while ($chunkOffset -lt $pngBytes.Length) {
        $length = [uint32]$pngBytes[$chunkOffset] * 16777216 +
            [uint32]$pngBytes[$chunkOffset + 1] * 65536 +
            [uint32]$pngBytes[$chunkOffset + 2] * 256 +
            [uint32]$pngBytes[$chunkOffset + 3]
        $chunkType = [System.Text.Encoding]::ASCII.GetString($pngBytes, $chunkOffset + 4, 4)
        if ($chunkType -ceq 'sRGB') { return }
        $chunkOffset += 12 + $length
    }

    # PNG sRGB chunk: length 1, name sRGB, perceptual intent 0, CRC AECE1CE9.
    # Insert after IHDR, before any color information or image data.
    [byte[]] $srgbChunk = 0, 0, 0, 1, 115, 82, 71, 66, 0, 174, 206, 28, 233
    $stream = [System.IO.MemoryStream]::new()
    try {
        $stream.Write($pngBytes, 0, 33)
        $stream.Write($srgbChunk, 0, $srgbChunk.Length)
        $stream.Write($pngBytes, 33, $pngBytes.Length - 33)
        [System.IO.File]::WriteAllBytes($Path, $stream.ToArray())
    }
    finally { $stream.Dispose() }
}

# Preserve the supplied artwork, including its lighting and bevels. The source
# canvas becomes 432 px wide, with 40 px of additional space on each side.
# PNG32 forces 8-bit RGBA even though the final image is fully opaque.
Invoke-Magick @(
    '-size', '512x512', 'xc:#0B0911',
    '(', $sourcePath, '-colorspace', 'sRGB',
    '-filter', 'Lanczos', '-resize', '432x432', ')',
    '-gravity', 'center', '-compose', 'over', '-composite',
    '-alpha', 'set', '-depth', '8', '+profile', '*',
    '-set', 'colorspace', 'sRGB', '-intent', 'Perceptual',
    '-define', 'png:include-chunk=sRGB,gAMA,cHRM',
    '-define', 'png:exclude-chunk=date,time',
    "PNG32:$outputPath"
)
Set-SrgbMetadata -Path $outputPath

$attributes = Invoke-Magick @(
    'identify', '-format', '%w|%h|%z|%[colorspace]|%[opaque]|%[png:IHDR.color-type-orig]',
    $outputPath
)
if ($attributes -cne '512|512|8|sRGB|True|6') {
    throw "Unexpected output attributes: $attributes"
}
if ((Get-Item -LiteralPath $outputPath).Length -gt 1024KB) {
    throw 'The Google Play icon exceeds 1024 KB.'
}

# Check the actual PNG chunks so a missing color-space tag fails the export.
$pngBytes = [System.IO.File]::ReadAllBytes($outputPath)
$chunkOffset = 8
$hasSrgbChunk = $false
while ($chunkOffset -lt $pngBytes.Length) {
    $length = [uint32]$pngBytes[$chunkOffset] * 16777216 +
        [uint32]$pngBytes[$chunkOffset + 1] * 65536 +
        [uint32]$pngBytes[$chunkOffset + 2] * 256 +
        [uint32]$pngBytes[$chunkOffset + 3]
    $chunkType = [System.Text.Encoding]::ASCII.GetString($pngBytes, $chunkOffset + 4, 4)
    if ($chunkType -ceq 'sRGB') { $hasSrgbChunk = $true }
    $chunkOffset += 12 + $length
}
if (-not $hasSrgbChunk) {
    throw 'The Google Play icon is missing its explicit sRGB chunk.'
}

New-Item -ItemType Directory -Path $previewDir -Force | Out-Null
foreach ($size in 512, 96, 48) {
    $previewPath = Join-Path $previewDir "rounded-${size}.png"
    # Supersample the mask for smooth corners. Google's documented radius is
    # 30% of the icon size. These previews omit Google's dynamic outer shadow.
    Invoke-Magick @(
        $outputPath,
        '(', '-size', '2048x2048', 'xc:black', '-fill', 'white',
        '-draw', 'roundrectangle 0,0 2047,2047 614.4,614.4',
        '-resize', '512x512', ')',
        '-alpha', 'off', '-compose', 'CopyOpacity', '-composite',
        '-filter', 'Lanczos', '-resize', "${size}x${size}",
        '-depth', '8', '+profile', '*', '-set', 'colorspace', 'sRGB',
        '-intent', 'Perceptual', '-define', 'png:include-chunk=sRGB,gAMA,cHRM',
        '-define', 'png:exclude-chunk=date,time', "PNG32:$previewPath"
    )
    Set-SrgbMetadata -Path $previewPath
}

$fileSize = (Get-Item -LiteralPath $outputPath).Length
Write-Output "Verified Google Play icon: 512 x 512, 8-bit RGBA, sRGB, opaque, $fileSize bytes."
Write-Output "Upload: $outputPath"
Write-Output "Rounded previews: $previewDir"
