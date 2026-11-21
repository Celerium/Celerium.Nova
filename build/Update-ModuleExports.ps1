<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Update-ModuleExports.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        DATE:    2025-11-17
        EMAIL:   celerium@Celerium.org

    TODO:

.SYNOPSIS
    Keeps the module manifest in sync with the module files

.DESCRIPTION
    The Update-ModuleExports script reads the function files in the Private & Public folders of the module
    & keeps the NestedModules, FunctionsToExport, & AliasesToExport entries of Celerium.Nova.psd1 in sync with them

    Run the script after a function is added, renamed, or removed. The CI workflow runs it & fails when
    the committed manifest is different

    The script works on Windows PowerShell 5.1 & PowerShell 7+

.PARAMETER ModuleName
    The name of the module to update

    Example: Celerium.Nova

.EXAMPLE
    .\Update-ModuleExports.ps1

    Updates the manifest

.EXAMPLE
    .\Update-ModuleExports.ps1 -WhatIf

    Shows what would be updated without writing any files

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

#Region  [ Parameters ]

[CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName = 'Celerium.Nova'
    )

#EndRegion  [ Parameters ]

Write-Verbose ''
Write-Verbose "START - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$StartDate = Get-Date

#Region     [ Prerequisites ]

$RootPath       = Split-Path -Path $PSScriptRoot -Parent
$ModulePath     = Join-Path -Path $RootPath -ChildPath $ModuleName
$ManifestPath   = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"
$Utf8NoBom      = [System.Text.UTF8Encoding]::new($false)

function Get-ModuleFile {
    # Every function file of a folder, in the same order on every platform
    param ([string]$Folder)

    $Path = Join-Path -Path $ModulePath -ChildPath $Folder
    if (-not (Test-Path -Path $Path -PathType Container)) { return }

    $Files = @(Get-ChildItem -Path $Path -Filter '*.ps1' -Recurse -File)

    [string[]]$Keys = @($Files | ForEach-Object { $_.FullName.Replace('\', '/') })
    [System.Array]::Sort($Keys, [System.StringComparer]::Ordinal)

    foreach ($Key in $Keys) { $Files | Where-Object { $_.FullName.Replace('\', '/') -eq $Key } }
}

#EndRegion  [ Prerequisites ]

#Region     [ Read the module files ]

Write-Verbose " - (1/2) - $(Get-Date -Format MM-dd-HH:mm) - Reading the module files"

$Entries = [System.Collections.Generic.List[object]]::new()

foreach ($Folder in 'Private', 'Public') {

    foreach ($File in (Get-ModuleFile -Folder $Folder)) {

        $Ast        = [System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$null, [ref]$null)
        $Functions  = @($Ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] })

        $Aliases = foreach ($Command in $Ast.FindAll({ param($Node) $Node -is [System.Management.Automation.Language.CommandAst] -and $Node.GetCommandName() -in 'Set-Alias', 'New-Alias' }, $false)) {
            $Bound = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($Command)
            if ($Bound.BoundParameters.ContainsKey('Name')) { $Bound.BoundParameters['Name'].ConstantValue }
        }

        $Relative = $File.FullName.Substring($ModulePath.Length + 1).Replace('\', '/')

        $Entries.Add([PSCustomObject]@{
            Folder      = $Folder
            Category    = if ($Folder -eq 'Private') { 'Internal' } else { $File.Directory.Name }
            File        = $Relative
            Functions   = @($Functions | ForEach-Object { $_.Name })
            Aliases     = @($Aliases | Where-Object { $_ })
        })

    }

}

#EndRegion  [ Read the module files ]

Write-Verbose " - (2/2) - $(Get-Date -Format MM-dd-HH:mm) - Updating the manifest"

#Region     [ Manifest ]

$NestedModules  = ($Entries | ForEach-Object { "        '$($_.File)'" }) -join ",`n"

$FunctionNames  = @($Entries | ForEach-Object { $_.Functions } | Select-Object -Unique)
[System.Array]::Sort($FunctionNames, [System.StringComparer]::Ordinal)
$Exported       = ($FunctionNames | ForEach-Object { "        '$_'" }) -join ",`n"

$AliasNames     = @($Entries | ForEach-Object { $_.Aliases } | Select-Object -Unique)
if ($AliasNames.Count -gt 0) { [System.Array]::Sort($AliasNames, [System.StringComparer]::Ordinal) }
$ExportedAlias  = ($AliasNames | ForEach-Object { "        '$_'" }) -join ",`n"

if ($PSCmdlet.ShouldProcess($ManifestPath, 'Update NestedModules, FunctionsToExport, & AliasesToExport')) {

    $Manifest = [System.IO.File]::ReadAllText($ManifestPath)

    $Manifest = [regex]::Replace($Manifest, '(?s)    NestedModules = @\(.*?\r?\n    \)', [System.Text.RegularExpressions.MatchEvaluator]{ "    NestedModules = @(`n$NestedModules`n    )" })
    $Manifest = [regex]::Replace($Manifest, '(?s)    FunctionsToExport = @\(.*?\r?\n    \)', [System.Text.RegularExpressions.MatchEvaluator]{ "    FunctionsToExport = @(`n$Exported`n    )" })
    $Manifest = [regex]::Replace($Manifest, '(?s)    AliasesToExport = @\(.*?\r?\n    \)', [System.Text.RegularExpressions.MatchEvaluator]{ "    AliasesToExport = @(`n$ExportedAlias`n    )" })

    [System.IO.File]::WriteAllText($ManifestPath, $Manifest, $Utf8NoBom)

}

#EndRegion  [ Manifest ]

Write-Verbose ''
Write-Verbose "END - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$TimeToComplete = New-TimeSpan -Start $StartDate -End (Get-Date)
Write-Verbose 'Time to complete'
Write-Verbose ($TimeToComplete | Select-Object * -ExcludeProperty Ticks,Total*,Milli* | Out-String)

Write-Output "Listed [ $($FunctionNames.Count) ] functions ([ $(@($Entries | Where-Object Folder -eq 'Public' | ForEach-Object { $_.Functions }).Count) ] public) from [ $($Entries.Count) ] files"
