<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: BuildScripts.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the scripts in the build folder

.DESCRIPTION
    Pester tests for the scripts in the build folder

    Every script is parsed & the help of the scripts that update the module data is checked. The scripts are not
    run because they download files or change files of the repository

.PARAMETER ModuleName
    The name of the local module to import

    Default value: Celerium.Nova

.PARAMETER Version
    The version of the local module to import

.PARAMETER BuildTarget
    Which version of the module to run tests against

    Allowed values:
        'built', 'notBuilt'

.EXAMPLE
    Invoke-Pester -Path .\BuildScripts.Tests.ps1

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
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='6.0.0' }

#Region     [ Parameters ]

#Available in Discovery & Run
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ModuleName = 'Celerium.Nova',

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [ValidateSet('built', 'notBuilt')]
    [string]$BuildTarget
)

#EndRegion  [ Parameters ]

#Region     [ Prerequisites ]

    BeforeDiscovery {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        $PesterTestName = (Get-Item -Path $PSCommandPath).Name

        $BuildPath = Join-Path -Path (Get-TestRootPath) -ChildPath 'build'

        $BuildScripts = @(Get-ChildItem -Path $BuildPath -Filter *.ps1 -File | Sort-Object -Property Name | ForEach-Object {

            $ParsedScript = Get-TestScriptAst -Path $_.FullName

            @{
                ScriptName      = $_.Name
                ScriptPath      = $_.FullName
                HasModuleName   = [bool]$ParsedScript.Ast.ParamBlock.Parameters.Where({ $_.Name.VariablePath.UserPath -eq 'ModuleName' })
                RequiresPwsh7   = ($ParsedScript.Ast.ScriptRequirements -and $ParsedScript.Ast.ScriptRequirements.RequiredPSVersion -and $ParsedScript.Ast.ScriptRequirements.RequiredPSVersion.Major -ge 7)
            }

        })

        # Scripts that need PowerShell 7 can not be parsed by Windows PowerShell
        $ParseScripts      = @($BuildScripts | Where-Object { -not ($_.RequiresPwsh7 -and $PSVersionTable.PSVersion.Major -lt 7) })
        $ModuleNameScripts = @($BuildScripts | Where-Object { $_.HasModuleName })

        $HelpScripts = @($BuildScripts | Where-Object { $_.ScriptName -in 'Update-HtmlResources.ps1', 'Update-ModuleExports.ps1' })

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    Context "Build scripts" {

        It "[ <ScriptName> ] is a valid PowerShell script" -ForEach $ParseScripts {

            (Get-TestScriptAst -Path $ScriptPath).ParseErrors | Should -BeNullOrEmpty
        }

        It "[ <ScriptName> ] has a ModuleName parameter that defaults to Celerium.Nova" -ForEach $ModuleNameScripts {

            $Ast        = (Get-TestScriptAst -Path $ScriptPath).Ast
            $Parameter  = $Ast.ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'ModuleName' }

            $Parameter.DefaultValue.Value | Should -Be 'Celerium.Nova'

        }

        It "[ <ScriptName> ] has comment based help with a synopsis, a description, & an example" -ForEach $HelpScripts {

            $Help = (Get-TestScriptAst -Path $ScriptPath).Ast.GetHelpContent()

            $Help.Synopsis | Should -Not -BeNullOrEmpty
            $Help.Description | Should -Not -BeNullOrEmpty
            @($Help.Examples).Count | Should -BeGreaterOrEqual 1
            @($Help.Links).Count | Should -BeGreaterOrEqual 1

        }

        It "[ <ScriptName> ] documents every parameter" -ForEach $HelpScripts {

            $Ast        = (Get-TestScriptAst -Path $ScriptPath).Ast
            $Help       = $Ast.GetHelpContent()
            $Declared   = @($Ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath })

            $Undocumented = @($Declared | Where-Object { -not $Help.Parameters.ContainsKey($_.ToUpperInvariant()) -or -not $Help.Parameters[$_.ToUpperInvariant()] })

            $Undocumented | Should -BeNullOrEmpty -Because "[ $($Undocumented -join ', ') ] should have a .PARAMETER section"

        }

        It "[ <ScriptName> ] has parameters that are documented & declared" -ForEach $HelpScripts {

            $Ast        = (Get-TestScriptAst -Path $ScriptPath).Ast
            $Help       = $Ast.GetHelpContent()
            $Declared   = @($Ast.ParamBlock.Parameters | ForEach-Object { $_.Name.VariablePath.UserPath.ToUpperInvariant() })

            $Stale = @($Help.Parameters.Keys | Where-Object { $_ -notin $Declared })

            $Stale | Should -BeNullOrEmpty -Because "[ $($Stale -join ', ') ] is documented but is not a parameter"

        }

    }

    Context "The module files are listed in the manifest" {

        It "Update-ModuleExports.ps1 does not change the manifest" {

            $RootPath   = Get-TestRootPath
            $Manifest   = Join-Path -Path (Join-Path -Path $RootPath -ChildPath 'Celerium.Nova') -ChildPath 'Celerium.Nova.psd1'

            $ManifestBefore = [System.IO.File]::ReadAllText($Manifest)

            try     { $null = & (Join-Path -Path (Join-Path -Path $RootPath -ChildPath 'build') -ChildPath 'Update-ModuleExports.ps1') }
            finally {
                $ManifestAfter = [System.IO.File]::ReadAllText($Manifest)

                # Always put the file back so the tests never change the repository
                [System.IO.File]::WriteAllText($Manifest, $ManifestBefore, [System.Text.UTF8Encoding]::new($false))
            }

            $ManifestAfter.Replace("`r`n", "`n") | Should -Be $ManifestBefore.Replace("`r`n", "`n") -Because 'run build\Update-ModuleExports.ps1 & commit the changes'

        }

    }

}
