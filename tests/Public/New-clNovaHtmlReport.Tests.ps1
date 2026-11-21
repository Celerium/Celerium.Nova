<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: New-clNovaHtmlReport.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the HTML report functions

.DESCRIPTION
    Pester tests for New-clNovaHtmlReport, New-clNovaHtmlSummaryCardSet, New-clNovaHtmlSummaryCard, & New-clNovaHtmlTable

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
    Invoke-Pester -Path .\New-clNovaHtmlReport.Tests.ps1

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

        # The number of cards, & the cards per row (and rows) on a desktop
        $CardCases = @(
            @{ Count = 2;   PerRow = 2; Rows = 1 }
            @{ Count = 6;   PerRow = 3; Rows = 2 }
            @{ Count = 8;   PerRow = 4; Rows = 2 }
            @{ Count = 12;  PerRow = 4; Rows = 3 }
        )

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget

        $Data = @(
            [PSCustomObject]@{ Name = 'Charlie'; Count = 10;  Status = 'Yes';   Date = [datetime]'2026-03-01 10:30:00'; Tags = @('a', 'b') }
            [PSCustomObject]@{ Name = 'Alpha';   Count = 9;   Status = 'No';    Date = [datetime]'2025-01-15 08:00:00'; Tags = @() }
            [PSCustomObject]@{ Name = 'Bravo';   Count = 100; Status = 'Maybe'; Date = $null;                           Tags = $null }
        )

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    Context "[ New-clNovaHtmlSummaryCard ] one card" {

        It "Shows the title, the value, & the icon" {
            $Html = New-clNovaHtmlSummaryCard -Title 'Total Computers' -Value 23 -Icon 'laptop'

            $Html | Should -Match 'Total Computers'
            $Html | Should -Match 'psn-card-value">23<'
            $Html | Should -Match '<svg'
        }

        It "Shows a value of 0" {
            New-clNovaHtmlSummaryCard -Title 'None' -Value 0 | Should -Match 'psn-card-value">0<'
        }

        It "Uses the color of the card" {
            New-clNovaHtmlSummaryCard -Title 'Bad' -Value 1 -Color Danger | Should -Match 'psn-c-danger'
        }

        It "Shows a progress bar with Percent" {
            $Html = New-clNovaHtmlSummaryCard -Title 'Supported' -Value '14 | 61%' -Percent 61

            $Html | Should -Match 'role="progressbar"'
            $Html | Should -Match 'width: 61%'
        }

        It "Does not show a progress bar without Percent" {
            New-clNovaHtmlSummaryCard -Title 'Total' -Value 3 | Should -Not -Match 'progressbar'
        }

        It "Shows a progress bar of 0 percent" {
            New-clNovaHtmlSummaryCard -Title 'None' -Value 0 -Percent 0 | Should -Match 'width: 0%'
        }

        It "Shows the tooltip & the note" {
            $Html = New-clNovaHtmlSummaryCard -Title 'T' -Value 1 -Tooltip 'The tooltip' -Note 'The note'

            $Html | Should -Match 'title="The tooltip"'
            $Html | Should -Match 'The note'
        }

        It "Makes the card a link with Url" {
            $Html = New-clNovaHtmlSummaryCard -Title 'Docs' -Value 'x' -Url 'https://learn.microsoft.com/en-us/lifecycle/products/'

            $Html | Should -Match '<a class="stretched-link" href="https://learn\.microsoft\.com/en-us/lifecycle/products/" target="_blank" rel="noopener noreferrer">Docs</a>'
        }

        It "Does not accept a script url" {
            { New-clNovaHtmlSummaryCard -Title 'Bad' -Value 'x' -Url 'javascript:alert(1)' } | Should -Throw
        }

        It "Encodes the text" {
            $Html = New-clNovaHtmlSummaryCard -Title '<b>T</b>' -Value '<i>V</i>' -Note '<u>N</u>' -Tooltip '"<x>"'

            $Html | Should -Not -Match '<b>T</b>|<i>V</i>|<u>N</u>'
            $Html | Should -Match '&lt;b&gt;T&lt;/b&gt;'
        }

    }

    Context "[ New-clNovaHtmlSummaryCardSet ] rows with the same number of cards" {

        It "Places [ <Count> ] cards in [ <Rows> ] row(s) of [ <PerRow> ] cards" -ForEach $CardCases {

            $Cards  = 1..$Count | ForEach-Object { @{ Title = "Card $_"; Value = $_ } }
            $Html   = New-clNovaHtmlSummaryCardSet -Card $Cards

            ([regex]::Matches($Html, 'class="psn-card-col"')).Count | Should -Be $Count
            $Html | Should -Match "--psn-cols-xl: $PerRow;"
            $Html | Should -Match "data-psn-rows=`"$Rows`""

        }

        It "Accepts hashtables & objects, from the pipeline" {
            $Html = @(
                @{ Title = 'One'; Value = 1; Percent = 50; Color = 'Success' }
                [PSCustomObject]@{ Title = 'Two'; Value = 2; Icon = 'server' }
            ) | New-clNovaHtmlSummaryCardSet

            $Html | Should -Match 'One'
            $Html | Should -Match 'Two'
            $Html | Should -Match 'psn-c-success'
        }

        It "Uses MaxPerRow" {
            $Cards = 1..6 | ForEach-Object { @{ Title = "Card $_"; Value = $_ } }

            New-clNovaHtmlSummaryCardSet -Card $Cards -MaxPerRow 6 | Should -Match '--psn-cols-xl: 6;'
        }

        It "Writes an error when a card does not have a title" {
            { New-clNovaHtmlSummaryCardSet -Title $null -Card @(@{ Value = 1 }) } | Should -Throw
        }

    }

    Context "[ New-clNovaHtmlTable ] the table" {

        It "Shows the properties in the order of Property" {
            $Html = $Data | New-clNovaHtmlTable -Property Count, Name

            $Html | Should -Match '<th scope="col">Count</th><th scope="col">Name</th>'
            $Html | Should -Not -Match '<th scope="col">Status</th>'
        }

        It "Shows the first 8 properties by default" {
            $Wide   = [PSCustomObject]@{ A1 = 1; A2 = 2; A3 = 3; A4 = 4; A5 = 5; A6 = 6; A7 = 7; A8 = 8; A9 = 9; A10 = 10 }
            $Html   = $Wide | New-clNovaHtmlTable

            ([regex]::Matches($Html, '<th scope="col">')).Count | Should -Be 8
        }

        It "Creates a row for every object" {
            ([regex]::Matches(($Data | New-clNovaHtmlTable -Property Name), '<tr><td>')).Count | Should -Be 3
        }

        It "Uses the column names" {
            $Html = $Data | New-clNovaHtmlTable -Property Name -ColumnName @{ Name = 'Computer Name' }

            $Html | Should -Match '<th scope="col">Computer Name</th>'
        }

        It "Colors the values of StatusMap" {
            $Html = $Data | New-clNovaHtmlTable -Property Name, Status -StatusMap @{ Status = @{ Yes = 'Success'; No = 'Danger' } }

            $Html | Should -Match '<span class="psn-badge psn-c-success">Yes</span>'
            $Html | Should -Match '<span class="psn-badge psn-c-danger">No</span>'
            $Html | Should -Not -Match 'psn-badge psn-c-[a-z]+">Maybe'
        }

        It "Shows dates in the format of DateFormat & sorts them as ISO dates" {
            $Html = $Data | New-clNovaHtmlTable -Property Date -DateFormat 'dd MMM yyyy'

            $Html | Should -Match '<td data-sort="2026-03-01T10:30:00">01 Mar 2026</td>'
        }

        It "Shows an empty cell for a null value" {
            $Html = $Data | Where-Object Name -eq 'Bravo' | New-clNovaHtmlTable -Property Date, Tags

            $Html | Should -Match '<tr><td></td><td></td></tr>'
        }

        It "Joins the items of a list" {
            ($Data | Where-Object Name -eq 'Charlie' | New-clNovaHtmlTable -Property Tags) | Should -Match '<td>a; b</td>'
        }

        It "Encodes the values" {
            $Html = [PSCustomObject]@{ Name = '<script>alert(1)</script>' } | New-clNovaHtmlTable -Property Name

            $Html | Should -Not -Match '<script>alert'
            $Html | Should -Match '&lt;script&gt;'
        }

        It "Accepts hashtables" {
            (@{ Name = 'FromHash' } | New-clNovaHtmlTable -Property Name) | Should -Match '<td>FromHash</td>'
        }

        It "Shows the title, the notes, & the page size" {
            $Html = $Data | New-clNovaHtmlTable -Property Name -Title 'My Table' -Note 'First note' -PageSize 50

            $Html | Should -Match 'My Table'
            $Html | Should -Match '<li>First note</li>'
            $Html | Should -Match 'data-page-size="50"'
            $Html | Should -Match '<option value="50" selected>50</option>'
        }

        It "Shows 10 rows per page by default" {
            $Default = $Data | New-clNovaHtmlTable -Property Name

            $Default | Should -Match 'data-page-size="10"'
            $Default | Should -Match '<option value="10" selected>10</option>'
            $Default | Should -Match '<option value="25">25</option>[\s\S]*<option value="50">50</option>[\s\S]*<option value="0">All</option>'
            $Default | Should -Not -Match '<option value="100"'
        }

        It "Adds a page size that is not one of the choices" {
            ($Data | New-clNovaHtmlTable -Property Name -PageSize 7) | Should -Match '<option value="7" selected>7</option>'
        }

        It "Creates a table without rows" {
            $Html = New-clNovaHtmlTable -InputObject @() -Property Name

            $Html | Should -Match '<th scope="col">Name</th>'
        }

    }

    Context "[ New-clNovaHtmlReport ] the page" {

        BeforeAll {
            $Cards = 1..8 | ForEach-Object { @{ Title = "Card $_"; Value = $_; Icon = 'server' } }
            $Html  = $Data | New-clNovaHtmlReport -Title 'My Report' -Subtitle 'Data from here' -SummaryCard $Cards -Property Name, Count, Status -TableTitle 'Things'
        }

        It "Returns the HTML text when Path is not used" {
            $Html | Should -BeOfType [string]
            $Html | Should -Match '^<!DOCTYPE html>'
        }

        It "Has the title, the heading, & the subtitle" {
            $Html | Should -Match '<title>My Report</title>'
            $Html | Should -Match '<h1 class="h3 mb-0 text-gray-800">My Report</h1>'
            $Html | Should -Match 'Data from here'
        }

        It "Is mobile friendly" {
            $Html | Should -Match '<meta name="viewport" content="width=device-width, initial-scale=1'
            $Html | Should -Match '@media \(max-width: 767\.98px\)'
        }

        It "Has the dark sidebar & header & an off white body" {
            $Html | Should -Match '--psn-sidebar-bg: #212529'
            $Html | Should -Match '--psn-topbar-bg: #212529'
            $Html | Should -Match '--psn-page-bg: #f4f3ee'
        }

        It "Has the summary cards & the table" {
            $Html | Should -Match 'class="psn-card-grid"'
            $Html | Should -Match 'class="psn-datatable"'
            $Html | Should -Match 'Things'
        }

        It "Highlights the whole row on hover & sorts every column" {
            $Html | Should -Match 'tbody > tr:hover > \*'
            $Html | Should -Match "SortBy\(Index\)"
        }

        It "Embeds Bootstrap so the report works offline" {
            $Html | Should -Not -Match 'cdn\.jsdelivr\.net/npm/bootstrap@[0-9.]+/dist'
            $Html | Should -Match 'Bootstrap\s+v5\.3'
        }

        It "Shows no table title unless TableTitle is used" {
            $Html | Should -Match 'Things'
            ($Data | New-clNovaHtmlReport -Property Name) | Should -Not -Match '<div class="card-header'
        }

        It "Does not show the generated time in the header" {
            $Html | Should -Not -Match 'psn-topbar-meta'
            $Html | Should -Not -Match 'psn-topbar-title'
            $Html | Should -Not -Match 'Generated <strong>'
        }

        It "Replaces the icon & the name with BrandLogoPath" {
            $Logo = Join-Path -Path $TestDrive -ChildPath 'logo.png'
            [System.IO.File]::WriteAllBytes($Logo, [byte[]](137, 80, 78, 71, 13, 10, 26, 10))

            $Branded = $Data | New-clNovaHtmlReport -BrandText 'Contoso' -BrandLogoPath $Logo

            $Branded | Should -Match '<img class="psn-brand-logo" src="data:image/png;base64,iVBORw0KGgo=" alt="Contoso">'
            $Branded | Should -Not -Match 'psn-sidebar-text">Contoso<'
        }

        It "Shows a different logo when the sidebar is collapsed with BrandLogoCollapsedPath" {
            $Logo = Join-Path -Path $TestDrive -ChildPath 'logo.png'
            $Small = Join-Path -Path $TestDrive -ChildPath 'small.png'
            [System.IO.File]::WriteAllBytes($Logo, [byte[]](137, 80, 78, 71, 13, 10, 26, 10))
            [System.IO.File]::WriteAllBytes($Small, [byte[]](137, 80, 78, 71, 13, 10, 26, 11))

            $Branded = $Data | New-clNovaHtmlReport -BrandText 'Contoso' -BrandLogoPath $Logo -BrandLogoCollapsedPath $Small

            $Branded | Should -Match 'class="psn-brand-logo psn-brand-logo-expanded" src="data:image/png;base64,iVBORw0KGgo="'
            $Branded | Should -Match 'class="psn-brand-logo-collapsed" src="data:image/png;base64,iVBORw0KGgs="'
        }

        It "Uses FaviconPath as the icon of the browser tab" {
            $Icon = Join-Path -Path $TestDrive -ChildPath 'tab.ico'
            [System.IO.File]::WriteAllBytes($Icon, [byte[]](0, 0, 1, 0, 1, 0))

            ($Data | New-clNovaHtmlReport -FaviconPath $Icon) | Should -Match '<link rel="icon" href="data:image/x-icon;base64,AAABAAEA">'
        }

        It "Writes an error when the logo does not exist or is not an image" {
            { $Data | New-clNovaHtmlReport -BrandLogoPath (Join-Path -Path $TestDrive -ChildPath 'missing.png') } | Should -Throw '*was not found*'

            $Text = Join-Path -Path $TestDrive -ChildPath 'logo.txt'
            Set-Content -Path $Text -Value 'text'
            { $Data | New-clNovaHtmlReport -BrandLogoPath $Text } | Should -Throw '*must be a png*'
        }

        It "Shows the icon & the name without a logo" {
            $Html | Should -Match 'psn-sidebar-text">Celerium.Nova<'
            $Html | Should -Not -Match '<img class="psn-brand-logo"'
        }

        It "Does not show a footer unless Footer is used" {
            $Html | Should -Not -Match 'psn-footer">'
            $Html | Should -Not -Match 'Created with'
            ($Data | New-clNovaHtmlReport -Footer 'My footer') | Should -Match '<footer class="psn-footer">My footer</footer>'
        }

        It "Does not leave a template token in the page" {
            $Html | Should -Not -Match '\{\{\w+\}\}'
        }

        It "Links the Bootstrap CDN files with -ResourceMode Cdn" {
            $Cdn = $Data | New-clNovaHtmlReport -ResourceMode Cdn

            $Cdn | Should -Match '<link rel="stylesheet" href="https://cdn\.jsdelivr\.net/npm/bootstrap@5\.3\.\d+/dist/css/bootstrap\.min\.css" integrity="sha384-[A-Za-z0-9+/=]+" crossorigin="anonymous">'
            $Cdn | Should -Match '<script src="https://cdn\.jsdelivr\.net/npm/bootstrap@5\.3\.\d+/dist/js/bootstrap\.bundle\.min\.js" integrity="sha384-'
            $Cdn.Length | Should -BeLessThan $Html.Length
        }

        It "Shows the navigation items" {
            $Nav = $Data | New-clNovaHtmlReport -NavigationItem @(
                @{ Heading = 'Help'; Text = 'Docs'; Url = 'https://example.invalid/docs'; Icon = 'info-circle' }
                @{ Heading = 'Help'; Text = 'Bad'; Url = 'javascript:alert(1)' }
            )

            $Nav | Should -Match 'psn-sidebar-heading">Help<'
            $Nav | Should -Match 'href="https://example\.invalid/docs" target="_blank" rel="noopener noreferrer"'
            $Nav | Should -Not -Match 'href="javascript:'
        }

        It "Encodes the title" {
            ($Data | New-clNovaHtmlReport -Title '<script>x</script>') | Should -Not -Match '<script>x</script>'
        }

        It "Saves the report to Path & returns the file" {
            $Path   = Join-Path -Path $TestDrive -ChildPath 'folder/report.html'
            $File   = $Data | New-clNovaHtmlReport -Path $Path

            $File           | Should -BeOfType [System.IO.FileInfo]
            $Path           | Should -Exist
            [System.IO.File]::ReadAllText($Path) | Should -Match '^<!DOCTYPE html>'
        }

        It "Saves the report as UTF8 without a byte order mark" {
            $Path = Join-Path -Path $TestDrive -ChildPath 'bom.html'
            $null = $Data | New-clNovaHtmlReport -Path $Path

            $Bytes = [System.IO.File]::ReadAllBytes($Path)
            ($Bytes[0] -eq 239 -and $Bytes[1] -eq 187) | Should -BeFalse
        }

        It "Does not save the report with -WhatIf" {
            $Path = Join-Path -Path $TestDrive -ChildPath 'whatif.html'
            $null = $Data | New-clNovaHtmlReport -Path $Path -WhatIf

            $Path | Should -Not -Exist
        }

        It "Creates a report without data" {
            New-clNovaHtmlReport -Title 'Empty' | Should -Match '<title>Empty</title>'
        }

    }

}
