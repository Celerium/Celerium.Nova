function Get-clNovaHtmlIcon {
<#
    .SYNOPSIS
        Gets an inline SVG icon for an HTML report

    .DESCRIPTION
        The Get-clNovaHtmlIcon cmdlet returns a Bootstrap Icon as inline SVG so that the icon
        works in an offline report & does not need a font or an internet connection

        The icons are the svg files in the icons folder of the report resources
        (build\HtmlReport\icons). The Update-HtmlResources.ps1 build script downloads them

        When the icon does not exist the info-circle icon is returned. An empty string
        is returned when there are no icons at all

        This is an internal helper function that is used by the public functions

    .PARAMETER Name
        The name of the Bootstrap Icon without the .svg extension

        Example:
            server
            check-circle-fill

    .PARAMETER ResourcePath
        The HtmlReport folder to read the icons from

        By default the folder of the module is used

    .EXAMPLE
        Get-clNovaHtmlIcon -Name 'server'

        Returns the SVG of the server icon

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaHtmlIcon.html
#>

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$ResourcePath
    )

    $Svg = $null

    # The icons folder is found once, a missing icon is checked with Test-Path so it does not add an error to $Error
    $IconFolder = $null
    if ($ResourcePath) { $IconFolder = Join-Path -Path $ResourcePath -ChildPath 'icons' }
    else {
        $FallbackPath = Get-clNovaResourcePath -RelativePath 'HtmlReport/icons/info-circle.svg' -ErrorAction Ignore
        if ($FallbackPath) { $IconFolder = Split-Path -Path $FallbackPath -Parent }
    }

    if (-not $IconFolder) { return '' }

    # Only letters, numbers, & dashes are valid in the name of an icon
    foreach ($IconName in $Name, 'info-circle') {

        if ($IconName -notmatch '^[A-Za-z0-9-]+$') { continue }

        $IconPath = Join-Path -Path $IconFolder -ChildPath "$IconName.svg"
        if (Test-Path -LiteralPath $IconPath -PathType Leaf) { $Svg = [System.IO.File]::ReadAllText($IconPath, [System.Text.Encoding]::UTF8) }

        if ($Svg) { break }

    }

    if (-not $Svg) { return '' }

    $Svg = $Svg.Trim()
    $Svg = [regex]::Replace($Svg, 'class="([^"]*)"', 'class="$1 psn-icon" aria-hidden="true" focusable="false"', 1)

    return $Svg

}
