function ConvertTo-clNovaHtmlDataUri {
<#
    .SYNOPSIS
        Converts an image file to a data uri that can be embedded in an HTML page

    .DESCRIPTION
        The ConvertTo-clNovaHtmlDataUri cmdlet reads an image file & returns it as a base64 data uri
        (data:image/png;base64,...) so the image is part of the HTML file & is also shown when the
        computer is offline

        The supported files are png, jpg, jpeg, gif, svg, webp, & ico

        This is an internal helper function that is used by the public functions

    .PARAMETER Path
        The path of the image file

    .EXAMPLE
        ConvertTo-clNovaHtmlDataUri -Path .\logo.png

        Returns data:image/png;base64,iVBORw0KGgo...

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/Internal/ConvertTo-clNovaHtmlDataUri.html
#>

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    $FullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

    if (-not (Test-Path -Path $FullPath -PathType Leaf)) { throw "The image [ $Path ] was not found" }

    $Types = @{ '.png' = 'image/png'; '.jpg' = 'image/jpeg'; '.jpeg' = 'image/jpeg'; '.gif' = 'image/gif'; '.svg' = 'image/svg+xml'; '.webp' = 'image/webp'; '.ico' = 'image/x-icon' }
    $Type  = $Types[[System.IO.Path]::GetExtension($FullPath).ToLowerInvariant()]

    if (-not $Type) { throw "The image [ $Path ] must be a png, jpg, gif, svg, webp, or ico file" }

    return ('data:{0};base64,{1}' -f $Type, [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($FullPath)))

}
