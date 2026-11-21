<#
.NOTES
    Copyright 1990-2024 Celerium

    NAME: Invoke-moduleBuild.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        DATE:    2023-04-1
        EMAIL:   celerium@Celerium.org
        Updated: 2023-09-16

    TODO:

.SYNOPSIS
    Builds & prepares a PowerShell module for deployment

.DESCRIPTION
    The Invoke-moduleBuild.ps1 script builds & prepares a PowerShell
    module for deployment

    The HTML report resources of build\HtmlReport (templates, css, js, icons, & Bootstrap)
    are copied to the built module because the module reads them at runtime

.PARAMETER ModuleName
    The name of the module to build

    Example: Celerium.Nova

.PARAMETER Version
    The module version (must be a valid System.Version such as PowerShell supports for modules)

.PARAMETER UnversionedOutputDirectory
    Overrides the VersionedOutputDirectory, producing an OutputDirectory without a version number as the last folder

.EXAMPLE
    .\Invoke-moduleBuild.ps1 -Version 1.2.3

    Compiles the module files located in ..\moduleName and builds
    a combined module in ...\build\moduleName\1.2.3

.INPUTS
    N/A

.OUTPUTS
    N/A

.LINK
    https://celerium.org

#>

<############################################################################################
                                        Code
############################################################################################>
#Requires -Version 5.1
#Requires -Modules ModuleBuilder

#Region  [ Parameters ]

[CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName = 'Celerium.Nova',

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Version,

        [Parameter(Mandatory=$false)]
        [switch]$UnversionedOutputDirectory
    )

#EndRegion  [ Parameters ]

Write-Verbose ''
Write-Verbose "START - $(Get-Date -Format yyyy-MM-dd-HH:mm) - [ $($PSCmdlet.ParameterSetName) ]"
Write-Verbose ''

#Region     [ Prerequisites ]

$StartDate = Get-Date

#EndRegion  [ Prerequisites ]

#Region     [ Build Module ]

try {

    $RootPath = Split-Path -Path $PSScriptRoot -Parent

    $ModulePath         = Join-Path -Path $RootPath -ChildPath $ModuleName
    $SourcePath         = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"
    $OutputDirectory    = Join-Path -Path $RootPath -ChildPath "build"

    $Params = @{
        SourcePath      = $SourcePath
        OutputDirectory = $OutputDirectory
        Version         = $Version
        PublicFilter    = Join-Path -Path 'Private','Public' -ChildPath "*.ps1"
        UnversionedOutputDirectory = $UnversionedOutputDirectory
    }

    Build-Module @Params -Verbose

    $BuiltPath = if ($UnversionedOutputDirectory) { Join-Path -Path $OutputDirectory -ChildPath $ModuleName }
                    else { Join-Path -Path (Join-Path -Path $OutputDirectory -ChildPath $ModuleName) -ChildPath $Version }

    #Add the HTML report resources that the module reads at runtime
    $ResourcePath = Join-Path -Path $BuiltPath -ChildPath 'HtmlReport'
    New-Item -Path $ResourcePath -ItemType Directory -Force > $null

    foreach ($Resource in 'templates', 'css', 'js', 'icons', 'logo', 'vendor', 'resources.json') {
        Copy-Item -Path (Join-Path -Path (Join-Path -Path $OutputDirectory -ChildPath 'HtmlReport') -ChildPath $Resource) -Destination $ResourcePath -Recurse -Force
    }

    #Replace & comment out NestedModules from nonBuilt module
    $ModulePathBuilt = if ($UnversionedOutputDirectory) { Join-Path -Path (Join-Path -Path $OutputDirectory -ChildPath $ModuleName) -ChildPath "$ModuleName.psd1" }
                        else { Join-Path -Path (Join-Path -Path (Join-Path -Path $OutputDirectory -ChildPath $ModuleName) -ChildPath $Version) -ChildPath "$ModuleName.psd1" }
    Update-Metadata -Path $ModulePathBuilt -PropertyName NestedModules -Value  @()
    (Get-Content -Path $ModulePathBuilt -Raw) -replace 'NestedModules = @\(\)', '# NestedModules = @()' | Set-Content -Path $ModulePathBuilt

}
catch {
    Write-Error $_
    exit 1
}

#EndRegion  [ Build Module ]

Write-Verbose ''
Write-Verbose "END - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$TimeToComplete = New-TimeSpan -Start $StartDate -End (Get-Date)
Write-Verbose 'Time to complete'
Write-Verbose ($TimeToComplete | Select-Object * -ExcludeProperty Ticks,Total*,Milli* | Out-String)