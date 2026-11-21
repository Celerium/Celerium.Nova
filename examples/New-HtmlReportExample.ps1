#Requires -Version 5.1

<#
.SYNOPSIS
    Creates modern HTML reports from any PowerShell objects

.DESCRIPTION
    The New-HtmlReportExample.ps1 script is a read-only example that shows how the HTML report functions of the
    Celerium.Nova module turn PowerShell objects into a single HTML file with a dark sidebar & header, an off white body,
    summary cards, & a sortable, searchable table:

        1. Creates a report of the services of the computer with New-clNovaHtmlReport (the quick way)
        2. Shows how the pieces can be created separately & combined for other reports
           (New-clNovaHtmlSummaryCardSet, New-clNovaHtmlSummaryCard, & New-clNovaHtmlTable)

    The reports work offline, on desktops (Windows, Linux, & macOS), & on Android & iOS. Bootstrap, the theme,
    & the icons are embedded in the file. Use -ResourceMode Cdn to link the Bootstrap 5.3 CDN files instead

    The summary cards are placed in rows that all have the same number of cards (6 cards are 2 rows of 3
    cards, 12 cards are 3 rows of 4 cards)

    It works on Windows PowerShell 5.1 & PowerShell 7+ on Windows, Linux, & macOS

.PARAMETER OutputPath
    The folder the reports are saved in

    Default value: the current directory

.PARAMETER ResourceMode
    How Bootstrap is added to the reports

    Allowed values:
        'Embedded', 'Cdn'

    Default value: Embedded

.EXAMPLE
    ./New-HtmlReportExample.ps1

    Creates Services-Report.html in the current directory

.EXAMPLE
    ./New-HtmlReportExample.ps1 -OutputPath ./Reports -ResourceMode Cdn

    Creates the reports in the Reports folder & links the Bootstrap CDN files

.NOTES
    Only the services of the current computer are read

.LINK
    https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlReport.html

.LINK
    https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlSummaryCardSet.html

.LINK
    https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlTable.html
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$OutputPath = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Embedded', 'Cdn')]
    [string]$ResourceMode = 'Embedded'
)

# Import the module by name. To use a local copy of the repository instead run something like:
# Import-Module -Name 'C:\Path\To\Celerium.Nova\Celerium.Nova\Celerium.Nova.psd1' -Force
if (-not (Get-Module -Name Celerium.Nova)) { Import-Module -Name Celerium.Nova -ErrorAction Stop }

# Services only exist on Windows, other systems show the processes
if (Get-Command -Name Get-Service -ErrorAction SilentlyContinue) {
    $Data = @(Get-Service | Select-Object -Property Name, DisplayName, Status, StartType)
}
else {
    $Data = @(Get-Process | Select-Object -Property Name, Id, CPU)
}

if (-not (Test-Path -Path $OutputPath -PathType Container)) { New-Item -Path $OutputPath -ItemType Directory -Force > $null }

#Region     [ 1. The quick way ]

$Running = @($Data | Where-Object { $_.Status -eq 'Running' }).Count
$Stopped = @($Data | Where-Object { $_.Status -eq 'Stopped' }).Count

$Cards = @(
    @{ Title = 'Total';     Value = $Data.Count; Icon = 'server';              Color = 'Primary'; Tooltip = 'Everything that was found' }
    @{ Title = 'Running';   Value = $Running;    Icon = 'check-circle-fill';   Color = 'Success'; Percent = [Math]::Round(($Running / [Math]::Max($Data.Count, 1)) * 100) }
    @{ Title = 'Stopped';   Value = $Stopped;    Icon = 'x-circle-fill';       Color = 'Danger';  Percent = [Math]::Round(($Stopped / [Math]::Max($Data.Count, 1)) * 100) }
)

$ReportParameters = @{
    Path            = Join-Path -Path $OutputPath -ChildPath 'Services-Report.html'
    Title           = 'Services Report'
    Subtitle        = "Data gathered from $([System.Environment]::MachineName)"
    SummaryCard     = $Cards
    StatusMap       = @{ Status = @{ Running = 'Success'; Stopped = 'Danger' } }
    TableTitle      = "Services ($($Data.Count))"
    TableNote       = 'Click a column header to sort the table'
    ResourceMode    = $ResourceMode
}

$Data | New-clNovaHtmlReport @ReportParameters

#EndRegion  [ 1. The quick way ]

#Region     [ 2. The pieces ]

# The same functions can be used to add a report to any other HTML page
$CardHtml   = New-clNovaHtmlSummaryCardSet -Card $Cards -MaxPerRow 3
$TableHtml  = $Data | New-clNovaHtmlTable -Property Name, Status, StartType -Title 'Only the table' -PageSize 10

Write-Host "Summary cards HTML: $($CardHtml.Length) characters, table HTML: $($TableHtml.Length) characters"

#EndRegion  [ 2. The pieces ]
