<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Invoke-HelpContent.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        DATE:    2022-11-26
        EMAIL:   celerium@celerium.org
        Updated: 2025-11-16

    TODO:

.SYNOPSIS
    Calls the Update-HelpContent function to update module markdown help files

.DESCRIPTION
    The Invoke-HelpContent script calls the Update-HelpContent function to
    update module markdown help files

.PARAMETER ModuleName
    The name of the module to update help docs for

.PARAMETER GitHubPageUri
    The github project url to inject into help docs

.EXAMPLE
    .\Invoke-HelpContent.ps1
        -ModuleName Celerium.Nova
        -HelpDocsPath "C:\Celerium\Projects\Celerium.Nova\docs"
        -GitHubPageUri "https://celerium.github.io/Celerium.Nova"

    Updates markdown docs and external help files

    No progress information is sent to the console while the script is running.

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
#Requires -Modules Microsoft.PowerShell.PlatyPS

#Region  [ Parameters ]

[CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName = 'Celerium.Nova',

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$GitHubPageUri = "https://celerium.github.io/Celerium.Nova"
    )

#EndRegion  [ Parameters ]

Write-Verbose ''
Write-Verbose "START - $(Get-Date -Format yyyy-MM-dd-HH:mm) - [ $($PSCmdlet.ParameterSetName) ]"
Write-Verbose ''

#Region     [ Prerequisites ]

$StartDate = Get-Date

#EndRegion  [ Prerequisites ]

#Region  [ Update Help ]

try {

    $RootPath = Split-Path -Path $PSScriptRoot -Parent

    . (Join-Path -Path $PSScriptRoot -ChildPath 'Update-HelpContent.ps1')

    $Parameters = @{
        ModuleName      = $ModuleName
        HelpDocsPath    = Join-Path -Path $RootPath -ChildPath 'docs'
        GitHubPageUri   = $GitHubPageUri
        Verbose         = $true
    }

    Update-HelpContent @Parameters

}
catch {
    Write-Error $_
    exit 1
}

#EndRegion  [ Update Help ]

Write-Verbose ''
Write-Verbose "END - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$TimeToComplete = New-TimeSpan -Start $StartDate -End (Get-Date)
Write-Verbose 'Time to complete'
Write-Verbose ($TimeToComplete | Select-Object * -ExcludeProperty Ticks,Total*,Milli* | Out-String)