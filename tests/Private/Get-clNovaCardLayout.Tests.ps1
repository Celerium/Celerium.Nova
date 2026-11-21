<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Get-clNovaCardLayout.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the Get-clNovaCardLayout function

.DESCRIPTION
    Pester tests for the Get-clNovaCardLayout function

    The summary cards of a report are placed in rows that all have the same number of cards

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
    Invoke-Pester -Path .\Get-clNovaCardLayout.Tests.ps1

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

        $PesterTestName = (Get-Item -Path $PSCommandPath).Name

        # Cards, the most cards per row, & the expected cards per row & number of rows
        $LayoutCases = @(
            @{ Count = 1;   MaxPerRow = 4; Xl = 1;  Rows = 1 }
            @{ Count = 3;   MaxPerRow = 4; Xl = 3;  Rows = 1 }
            @{ Count = 4;   MaxPerRow = 4; Xl = 4;  Rows = 1 }
            @{ Count = 6;   MaxPerRow = 4; Xl = 3;  Rows = 2 }
            @{ Count = 8;   MaxPerRow = 4; Xl = 4;  Rows = 2 }
            @{ Count = 9;   MaxPerRow = 4; Xl = 3;  Rows = 3 }
            @{ Count = 12;  MaxPerRow = 4; Xl = 4;  Rows = 3 }
            @{ Count = 16;  MaxPerRow = 4; Xl = 4;  Rows = 4 }
            @{ Count = 10;  MaxPerRow = 5; Xl = 5;  Rows = 2 }
            @{ Count = 7;   MaxPerRow = 4; Xl = 4;  Rows = 2 }
        )

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    Context "[ Get-clNovaCardLayout ] evenly filled rows" {

        It "Places [ <Count> ] cards on [ <Rows> ] row(s) of [ <Xl> ] cards when the most per row is [ <MaxPerRow> ]" -ForEach $LayoutCases {

            $Layout = Get-clNovaCardLayout -Count $Count -MaxPerRow $MaxPerRow

            $Layout.Xl      | Should -Be $Xl
            $Layout.Rows    | Should -Be $Rows
            $Layout.Xl      | Should -BeLessOrEqual $MaxPerRow

        }

        It "Splits 6 cards in 2 rows of 3 cards" {
            $Layout = Get-clNovaCardLayout -Count 6
            $Layout.Rows | Should -Be 2
            $Layout.Xl   | Should -Be 3
        }

        It "Splits 12 cards in 3 rows of 4 cards" {
            $Layout = Get-clNovaCardLayout -Count 12
            $Layout.Rows | Should -Be 3
            $Layout.Xl   | Should -Be 4
        }

        It "Shows at most 2 cards per row on tablets & 1 card per row on phones" {
            $Layout = Get-clNovaCardLayout -Count 12
            $Layout.Md | Should -Be 2
            $Layout.Sm | Should -Be 1
        }

        It "Returns no rows when there are no cards" {
            (Get-clNovaCardLayout -Count 0).Rows | Should -Be 0
        }

    }

}
