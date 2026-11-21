function Get-clNovaHtmlResource {
<#
    .SYNOPSIS
        Gets the content of a file used to build an HTML report

    .DESCRIPTION
        The Get-clNovaHtmlResource cmdlet reads a template, css, js, or other text file that
        is used to build an HTML report

        The files are in the HtmlReport folder of the module (build\HtmlReport in the source
        module). A different folder can be used with the ResourcePath parameter

        This is an internal helper function that is used by the public functions

    .PARAMETER Name
        The path of the file relative to the HtmlReport folder

        Example:
            templates/Page.html
            css/Celerium.Nova.css

    .PARAMETER ResourcePath
        The HtmlReport folder to read the file from

        By default the folder of the module is used

    .EXAMPLE
        Get-clNovaHtmlResource -Name 'templates/Page.html'

        Returns the text of the Page.html report template

    .EXAMPLE
        Get-clNovaHtmlResource -Name 'css/Celerium.Nova.css' -ResourcePath 'C:\Branding\HtmlReport'

        Returns the css from a custom HtmlReport folder

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaHtmlResource.html
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

    if ($ResourcePath) {
        $Path = Join-Path -Path $ResourcePath -ChildPath ($Name.Replace('/', [System.IO.Path]::DirectorySeparatorChar))
    }
    else {
        $Path = Get-clNovaResourcePath -RelativePath "HtmlReport/$Name" -ErrorAction Stop
    }

    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        throw "The report resource [ $Name ] was not found at [ $Path ]"
    }

    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)

}
