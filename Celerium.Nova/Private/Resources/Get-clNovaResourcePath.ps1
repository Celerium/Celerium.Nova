function Get-clNovaResourcePath {
<#
    .SYNOPSIS
        Finds a resource file (template, css, js, icon, or data file) of the module

    .DESCRIPTION
        The Get-clNovaResourcePath cmdlet finds the full path of a resource file that is
        shipped with the module

        The module is used from two places & the resources are in a different place in each
            - Source module  : build\HtmlReport (next to the module folder)
            - Built module   : <module folder>\HtmlReport

        The folders above the file that calls the function are searched for the relative path,
        first as <folder>\<RelativePath> & then as <folder>\build\<RelativePath>

        This is an internal helper function that is used by the public functions

    .PARAMETER RelativePath
        The path of the resource relative to the root of the resources

        Example:
            HtmlReport/templates/Page.html
            HtmlReport/css/Celerium.Nova.css

    .PARAMETER SearchPath
        The folder the search starts from & works up from

        By default the folder of this file is used

    .EXAMPLE
        Get-clNovaResourcePath -RelativePath 'HtmlReport/templates/Page.html'

        Returns the full path of the Page.html report template

    .EXAMPLE
        Get-clNovaResourcePath -RelativePath 'HtmlReport/missing.json' -ErrorAction SilentlyContinue

        Returns nothing when the resource does not exist

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaResourcePath.html
#>

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$SearchPath = $PSScriptRoot
    )

    $Relative   = $RelativePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar).Replace('\', [System.IO.Path]::DirectorySeparatorChar)
    $Directory  = $SearchPath

    while ($Directory) {

        foreach ($Candidate in (Join-Path -Path $Directory -ChildPath $Relative), (Join-Path -Path (Join-Path -Path $Directory -ChildPath 'build') -ChildPath $Relative)) {
            if (Test-Path -Path $Candidate -PathType Leaf) { return $Candidate }
        }

        $Directory = Split-Path -Path $Directory -Parent

    }

    Write-Error "The resource [ $RelativePath ] was not found"

}
