<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Update-HtmlResources.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        DATE:    2025-11-17
        EMAIL:   celerium@Celerium.org

    TODO:

.SYNOPSIS
    Downloads the latest third party files used by the Celerium.Nova HTML reports

.DESCRIPTION
    The Update-HtmlResources script downloads the latest version of the third party files that are embedded in
    (or linked from) the HTML reports created by the Celerium.Nova module

        - Bootstrap (css & js bundle) - https://getbootstrap.com
        - Bootstrap Icons (svg)       - https://icons.getbootstrap.com

    The files are saved in build\HtmlReport\vendor & build\HtmlReport\icons together with a resources.json file that
    lists the versions, the CDN links, & the SRI hashes of the files. The Celerium.Nova module reads the files so that a
    report works offline & can also be created using the Bootstrap CDN links

    The report layout is based on the SB Admin 2 theme (https://github.com/StartBootstrap/startbootstrap-sb-admin-2)
    which is ported to Bootstrap 5.3 in build\HtmlReport\css\Celerium.Nova.css

    The script works on Windows PowerShell 5.1 & PowerShell 7+

.PARAMETER OutputPath
    The folder the files are saved in

    By default build\HtmlReport is used

.PARAMETER IconName
    The Bootstrap Icons that are downloaded

    The icons are used by the report templates & by the Icon property of the summary cards

.PARAMETER BootstrapVersion
    The version of Bootstrap to download

    By default the latest version published to npm is used

.EXAMPLE
    .\Update-HtmlResources.ps1

    Downloads the latest Bootstrap & Bootstrap Icons files

.EXAMPLE
    .\Update-HtmlResources.ps1 -BootstrapVersion 5.3.8 -Verbose

    Downloads Bootstrap 5.3.8 & the latest icons while showing progress information

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
        [string]$OutputPath = (Join-Path -Path $PSScriptRoot -ChildPath 'HtmlReport'),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$IconName = @(
            'activity', 'apple', 'arrow-down', 'arrow-up', 'bar-chart-line', 'bell', 'box-arrow-up-right', 'building', 'calendar-event',
            'calendar-x', 'check-circle-fill', 'chevron-left', 'chevron-right', 'clipboard-data', 'clock-history', 'cloud', 'collection', 'cpu', 'diagram-3', 'disc',
            'download', 'envelope', 'exclamation-triangle-fill', 'file-earmark-text', 'file-earmark-spreadsheet', 'filter', 'gear', 'globe', 'hdd', 'hdd-network',
            'house', 'info-circle', 'laptop', 'list', 'pause-circle', 'pc-display', 'people', 'person', 'puzzle', 'question-circle-fill', 'search', 'server', 'shield-check',
            'shield-exclamation', 'shield-x', 'speedometer2', 'table', 'tag', 'telephone', 'tools', 'ubuntu', 'unlock', 'windows', 'x-circle-fill'
        ),

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$BootstrapVersion = 'latest'
    )

#EndRegion  [ Parameters ]

Write-Verbose ''
Write-Verbose "START - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

#Region     [ Prerequisites ]

$StartDate = Get-Date

if ($PSEdition -eq 'Desktop') {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}

$Utf8NoBom      = [System.Text.UTF8Encoding]::new($false)
$VendorPath     = Join-Path -Path (Join-Path -Path $OutputPath -ChildPath 'vendor') -ChildPath 'bootstrap'
$IconPath       = Join-Path -Path $OutputPath -ChildPath 'icons'

function Get-FileSriHash {
    # SRI value of a file, used for the integrity attribute of the CDN links
    param ([string]$Path)

    $Sha384 = [System.Security.Cryptography.SHA384]::Create()
    try     { return 'sha384-' + [Convert]::ToBase64String($Sha384.ComputeHash([System.IO.File]::ReadAllBytes($Path))) }
    finally { $Sha384.Dispose() }
}

#EndRegion  [ Prerequisites ]

Write-Verbose " - (1/3) - $(Get-Date -Format MM-dd-HH:mm) - Finding the latest versions"

#Region     [ Versions ]

try {

    if ($BootstrapVersion -eq 'latest') {
        $BootstrapVersion = (Invoke-RestMethod -Uri 'https://registry.npmjs.org/bootstrap/latest' -UseBasicParsing -ErrorAction Stop).version
    }

    $IconsVersion = (Invoke-RestMethod -Uri 'https://registry.npmjs.org/bootstrap-icons/latest' -UseBasicParsing -ErrorAction Stop).version

    Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - Bootstrap [ $BootstrapVersion ] & Bootstrap Icons [ $IconsVersion ]"

}
catch {
    Write-Error $_
    exit 1
}

#EndRegion  [ Versions ]

Write-Verbose " - (2/3) - $(Get-Date -Format MM-dd-HH:mm) - Downloading files"

#Region     [ Download ]

try {

    foreach ($Folder in $VendorPath, $IconPath) {
        if (-not (Test-Path -Path $Folder -PathType Container)) { New-Item -Path $Folder -ItemType Directory -Force > $null }
    }

    $BootstrapFiles = @{
        'bootstrap.min.css'         = "https://cdn.jsdelivr.net/npm/bootstrap@$BootstrapVersion/dist/css/bootstrap.min.css"
        'bootstrap.bundle.min.js'   = "https://cdn.jsdelivr.net/npm/bootstrap@$BootstrapVersion/dist/js/bootstrap.bundle.min.js"
    }

    $Sri = [ordered]@{}

    foreach ($FileName in ($BootstrapFiles.Keys | Sort-Object)) {

        $FilePath = Join-Path -Path $VendorPath -ChildPath $FileName

        if ($PSCmdlet.ShouldProcess($FilePath, 'Download')) {
            Invoke-WebRequest -Uri $BootstrapFiles[$FileName] -OutFile $FilePath -UseBasicParsing -ErrorAction Stop
            $Sri[$FileName] = Get-FileSriHash -Path $FilePath
        }

    }

    $Icons = @()

    foreach ($Name in ($IconName | Sort-Object -Unique)) {

        $FilePath = Join-Path -Path $IconPath -ChildPath "$Name.svg"

        if ($PSCmdlet.ShouldProcess($FilePath, 'Download')) {
            try {
                Invoke-WebRequest -Uri "https://cdn.jsdelivr.net/npm/bootstrap-icons@$IconsVersion/icons/$Name.svg" -OutFile $FilePath -UseBasicParsing -ErrorAction Stop
                $Icons += $Name
            }
            catch { Write-Warning " -       - $(Get-Date -Format MM-dd-HH:mm) - The [ $Name ] icon could not be downloaded - $($_.Exception.Message)" }
        }

    }

}
catch {
    Write-Error $_
    exit 1
}

#EndRegion  [ Download ]

Write-Verbose " - (3/3) - $(Get-Date -Format MM-dd-HH:mm) - Writing resources.json"

#Region     [ Manifest ]

$Manifest = [ordered]@{
    Bootstrap = [ordered]@{
        Version     = $BootstrapVersion
        Css         = [ordered]@{ File = 'vendor/bootstrap/bootstrap.min.css'; Cdn = "https://cdn.jsdelivr.net/npm/bootstrap@$BootstrapVersion/dist/css/bootstrap.min.css"; Integrity = $Sri['bootstrap.min.css'] }
        Js          = [ordered]@{ File = 'vendor/bootstrap/bootstrap.bundle.min.js'; Cdn = "https://cdn.jsdelivr.net/npm/bootstrap@$BootstrapVersion/dist/js/bootstrap.bundle.min.js"; Integrity = $Sri['bootstrap.bundle.min.js'] }
        License     = 'MIT'
    }
    BootstrapIcons = [ordered]@{
        Version     = $IconsVersion
        Icons       = @($Icons)
        License     = 'MIT'
    }
    Theme = [ordered]@{
        Name        = 'SB Admin 2'
        Version     = '4.1.4'
        Source      = 'https://github.com/StartBootstrap/startbootstrap-sb-admin-2'
        Note        = 'Ported to Bootstrap 5.3 in css/Celerium.Nova.css'
        License     = 'MIT'
    }
    Updated = (Get-Date).ToString('yyyy-MM-dd')
}

$ManifestPath = Join-Path -Path $OutputPath -ChildPath 'resources.json'

if ($PSCmdlet.ShouldProcess($ManifestPath, 'Write')) {
    [System.IO.File]::WriteAllText($ManifestPath, (($Manifest | ConvertTo-Json -Depth 6) + "`n"), $Utf8NoBom)
}

#EndRegion  [ Manifest ]

Write-Verbose ''
Write-Verbose "END - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$TimeToComplete = New-TimeSpan -Start $StartDate -End (Get-Date)
Write-Verbose 'Time to complete'
Write-Verbose ($TimeToComplete | Select-Object * -ExcludeProperty Ticks,Total*,Milli* | Out-String)
