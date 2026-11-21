function Update-HelpContent {
<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Update-HelpContent.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        DATE:    2022-11-26
        EMAIL:   celerium@celerium.org
        Updated: 2025-11-16

    TODO:

.SYNOPSIS
    Updates or creates markdown help files

.DESCRIPTION
    The Update-HelpContent script updates or creates markdown help files which are
    used by both Github pages and as external help.

    The markdown documents created contain metadata that GitHub pages directly use
    to build its entire documentation structure\site.

    The documents are created with the Microsoft.PowerShell.PlatyPS module (v1+) which replaces
    the older platyPS module.

    This also generates the external XML\cab help files
        - The cab file is only created on Windows

.PARAMETER ModuleName
    The name of the module to generate help documents for

    Example: Celerium.Nova

.PARAMETER HelpDocsPath
    Location to store the markdown help docs

    All markdown help docs should be located outside the module folder.
    Reference:
        Yes - "Celerium.Nova\docs"
        NO  - "Celerium.Nova\Celerium.Nova\docs"

    Example: "C:\Celerium\Projects\Celerium.Nova\docs"

.PARAMETER GitHubPageUri
    Base url of the modules github pages

    Example: "https://celerium.github.io/Celerium.Nova"

.PARAMETER ShowHelpDocs
    Opens the directory with the HelpDocs when completed

.EXAMPLE
    .\Update-HelpContent.ps1
        -ModuleName Celerium.Nova
        -HelpDocsPath "C:\Celerium\Projects\Celerium.Nova\docs"
        -GitHubPageUri "https://celerium.github.io/Celerium.Nova"

    Updates markdown docs and external help files

    No progress information is sent to the console while the script is running.

.EXAMPLE
    .\Update-HelpContent.ps1
        -ModuleName Celerium.Nova
        -HelpDocsPath "C:\Celerium\Projects\Celerium.Nova\docs"
        -GitHubPageUri "https://celerium.github.io/Celerium.Nova"
        -verbose

    Updates markdown docs and external help files

    Progress information is sent to the console while the script is running.

.INPUTS
    N/A

.OUTPUTS
    N/A

.LINK
    https://celerium.org

#>

#Region  [ Parameters ]

[CmdletBinding()]
param(
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$HelpDocsPath,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$GitHubPageUri,

        [Parameter(Mandatory=$false)]
        [switch]$ShowHelpDocs
    )

#EndRegion  [ Parameters ]

Write-Verbose ''
Write-Verbose "START - $(Get-Date -Format yyyy-MM-dd-HH:mm) - [ $($PSCmdlet.ParameterSetName) ]"
Write-Verbose ''

Write-Verbose " - (1/4) - $(Get-Date -Format MM-dd-HH:mm) - Configuring prerequisites"

#Region     [ Helper Functions ]

function Repair-CommandMarkdown {
    # Cleans up the markdown of a command so that it renders well on GitHub pages
    param (
        [string]$Path,
        [string[]]$Alias
    )

    $Content = [System.IO.File]::ReadAllText($Path) -replace "`r`n", "`n"

    # Examples are created without a code fence, the first paragraph of an example is the code
    $Content = [regex]::Replace($Content, '(?m)^(### EXAMPLE \d+\n\n)(?!```)([^\n]+(?:\n[^\n]+)*)', {
        param($Match)
        "$($Match.Groups[1].Value)``````powershell`n$($Match.Groups[2].Value)`n``````"
    })

    # Aliases
    if ($Alias.Count -gt 0) {
        $AliasText = ($Alias | ForEach-Object { "- ``$_``" }) -join "`n"
        $Content = $Content -replace '(?s)This cmdlet has the following aliases,\s*\n\s*\{\{ ?Insert list of aliases ?\}\}', "This cmdlet has the following aliases,`n`n$AliasText"
    }
    else { $Content = [regex]::Replace($Content, '(?s)## ALIASES\n.*?(?=\n## )\n', '') }

    # Placeholders that are not used
    $Content = $Content -replace '(?m)^\{\{ ?Fill in the Description ?\}\}\n\n?', ''

    # Links without a title
    $Content = $Content -replace '(?m)^- \[\]\((.+?)\)\s*$', '- [$1]($1)'

    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

#EndRegion  [ Helper Functions ]

#Region     [ Prerequisites ]

$StartDate = Get-Date

#trim trailing slashes from urls
if ($HelpDocsPath[$HelpDocsPath.Length-1] -eq "/" -or $HelpDocsPath[$HelpDocsPath.Length-1] -eq "\") {
    $HelpDocsPath = $HelpDocsPath.Substring(0,$HelpDocsPath.Length-1)
}
if ($GitHubPageUri[$GitHubPageUri.Length-1] -eq "/" -or $GitHubPageUri[$GitHubPageUri.Length-1] -eq "\") {
    $GitHubPageUri = $GitHubPageUri.Substring(0,$GitHubPageUri.Length-1)
}

$ModulePage         = Join-Path -Path $HelpDocsPath -ChildPath "$ModuleName.md"
$TempFolder         = Join-Path -Path $HelpDocsPath -ChildPath "temp"
$SiteStructureFolder= Join-Path -Path $HelpDocsPath -ChildPath "site"
$ExternalHelp       = Join-Path -Path $HelpDocsPath -ChildPath "en-US"
$ExternalHelpCab    = Join-Path -Path $HelpDocsPath -ChildPath "cab"

$DocFolders = $HelpDocsPath,$TempFolder,$SiteStructureFolder,$ExternalHelp,$ExternalHelpCab

Try{

    if (Get-Module -Name Microsoft.PowerShell.PlatyPS -ListAvailable -Verbose:$false) {
        Import-Module -Name Microsoft.PowerShell.PlatyPS -Verbose:$false
    }
    else{
        throw "The Microsoft.PowerShell.PlatyPS module was not found"
    }

    $RootPath = Split-Path -Path $PSScriptRoot -Parent
    $ModulePath = Join-Path -Path $RootPath -ChildPath $ModuleName
    $ModulePsd1 = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"

        if (Test-Path -Path $ModulePsd1 ) {
            Import-Module -Name $ModulePsd1 -Force -Verbose:$false
            $ModuleInfo = Get-Module -Name $ModuleName
            $Commands = Get-Command -Module $ModuleName -ErrorAction Stop | Where-Object {$_.CommandType -eq 'Function'} | Sort-Object Name
            $Aliases = @($ModuleInfo.ExportedAliases.Values)
        }
        else{
            throw "The [ $ModuleName ] module was not found"
        }

    ForEach ($Folder in $DocFolders) {

        if ( ($Folder -ne $HelpDocsPath) -and (Test-Path -Path $Folder -PathType Container) ) {
            Remove-Item -Path $Folder -Force -Recurse
            New-Item -Path $Folder -ItemType Directory > $null
        }
        else{
            if ( (Test-Path -Path $Folder -PathType Container) -eq $false ) {
                New-Item -Path $Folder -ItemType Directory > $null
            }
        }

    }

    # The category of a function is the folder it is in (Private functions are Internal)
    $CategoryMap = @{}
    foreach ($Folder in 'Private', 'Public') {

        $FolderPath = Join-Path -Path $ModulePath -ChildPath $Folder
        if (-not (Test-Path -Path $FolderPath -PathType Container)) { continue }

        foreach ($File in Get-ChildItem -Path $FolderPath -Filter '*.ps1' -Recurse -File) {

            $Ast = [System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$null, [ref]$null)

            foreach ($Statement in ($Ast.EndBlock.Statements | Where-Object { $_ -is [System.Management.Automation.Language.FunctionDefinitionAst] })) {
                $CategoryMap[$Statement.Name] = if ($Folder -eq 'Private') { 'Internal' } else { $File.Directory.Name }
            }

        }

    }

}
Catch{
    Write-Error $_
    exit 1
}

#EndRegion     [ Prerequisites ]

Write-Verbose " - (2/4) - $(Get-Date -Format MM-dd-HH:mm) - Regenerating [ $( ($Commands | Measure-Object).count) ] help documents"

#Region     [ Command help ]

$Categories         = [System.Collections.Generic.HashSet[string]]::new()
$SiteFiles          = [System.Collections.Generic.List[string]]::new()
$HelpVersion        = [version]"$($ModuleInfo.Version).0"

ForEach ( $Cmdlet in $Commands ) {

    $Category = if ($CategoryMap.ContainsKey($Cmdlet.Name)) { $CategoryMap[$Cmdlet.Name] } else { '_Unique' }

    $CategoryPath = Join-Path -Path $SiteStructureFolder -ChildPath $Category
        if ( (Test-Path -Path $CategoryPath -PathType Container) -eq $false ) {
            New-Item -Path $CategoryPath -ItemType Directory > $null
        }

    [void]$Categories.Add($Category)

    $OnlineVersion = "$GitHubPageUri/site/$Category/$($Cmdlet.Name).html"
    $NewMetadata = @{
        'title'         = [string]$Cmdlet.Name
        'parent'        = [string]$Category
    }

    $MarkdownParams = @{
        CommandInfo     = $Cmdlet
        OutputFolder    = $TempFolder
        Metadata        = $NewMetadata
        HelpUri         = $OnlineVersion
        Locale          = 'en-US'
        Force           = $true
    }
    $MarkdownFile = New-MarkdownCommandHelp @MarkdownParams

    $CommandAliases = @($Aliases | Where-Object { $_.Definition -eq $Cmdlet.Name } | ForEach-Object { $_.Name } | Sort-Object)
    Repair-CommandMarkdown -Path $MarkdownFile.FullName -Alias $CommandAliases

    $SitePath = Join-Path -Path $CategoryPath -ChildPath "$($Cmdlet.Name).md"
    Move-Item -Path $MarkdownFile.FullName -Destination $SitePath -Force
    $SiteFiles.Add($SitePath)

}

#EndRegion  [ Command help ]

Write-Verbose " - (3/4) - $(Get-Date -Format MM-dd-HH:mm) - Regenerating module document"

#Region     [ Base module help ]

$CommandHelp = Import-MarkdownCommandHelp -Path @($SiteFiles)

New-MarkdownModuleFile -CommandHelp $CommandHelp -OutputFolder $TempFolder -Locale 'en-US' -HelpVersion $HelpVersion -Force > $null
$TempModulePage = Get-ChildItem -Path $TempFolder -Filter "$ModuleName.md" -Recurse | Select-Object -First 1
if (-not $TempModulePage) { throw "The module page of [ $ModuleName ] was not created" }

Write-Verbose " -       - $(Get-Date -Format MM-dd-HH:mm) - Updating module metadata"

    $ModuleDescription = 'Celerium.Nova is a standalone PowerShell module for Windows PowerShell 5.1 & PowerShell 7+. The New-clNovaHtml* functions turn any PowerShell object into a modern, offline friendly HTML report that other functions & scripts can use.'
    $DownloadLink = "$GitHubPageUri/docs/cab/"

    $Content = [System.IO.File]::ReadAllText($TempModulePage.FullName) -replace "`r`n", "`n"

    #Add GitHub pages parent & the download link of the external help
    $Content = $Content -replace '(?m)^HelpInfoUri:[ \t]*$', "HelpInfoUri: $DownloadLink"
    $Content = $Content -replace '(?m)^document type: module$', "document type: module`nparent: Home"

    #Adjust module description
    $Content = [regex]::Replace($Content, '(?s)(## Description\n\n).*?(\n\n## )', { param($Match) "$($Match.Groups[1].Value)$ModuleDescription$($Match.Groups[2].Value)" })

    #Adjust module uri links
    foreach ($SiteFile in $SiteFiles) {
        $Name       = [System.IO.Path]::GetFileNameWithoutExtension($SiteFile)
        $Category   = Split-Path -Path (Split-Path -Path $SiteFile -Parent) -Leaf
        $Content    = $Content -replace "\]\($([regex]::Escape($Name))\.md\)", "](site/$Category/$Name.md)"
    }

    [System.IO.File]::WriteAllText($ModulePage, $Content, [System.Text.UTF8Encoding]::new($false))

    #Sync the GitHub pages home page with the README
    $ReadmePath = Join-Path -Path $RootPath -ChildPath 'README.md'
    if (Test-Path -Path $ReadmePath -PathType Leaf) {

        $HomeFrontMatter = @"
---
external help file: $ModuleName-help.xml
Module Name: $ModuleName
online version: https://github.com/Celerium/$ModuleName
schema: 2.0.0
title: Home
has_children: true
layout: default
nav_order: 1
---


"@
        # Written without a BOM so that Jekyll can read the front matter
        [System.IO.File]::WriteAllText( (Join-Path -Path $HelpDocsPath -ChildPath 'index.md'), ($HomeFrontMatter + [System.IO.File]::ReadAllText($ReadmePath)), [System.Text.UTF8Encoding]::new($false) )

    }

#EndRegion  [ Base module help ]

#Region     [ Organize Markdown ]

# Every category gets an index page that lists its functions
ForEach ($Category in $Categories) {

    $CategoryPath = Join-Path -Path $SiteStructureFolder -ChildPath $Category

    $CountRows = ForEach ($Cmdlet in ($Commands | Where-Object { $CategoryMap[$_.Name] -eq $Category -or ($Category -eq '_Unique' -and -not $CategoryMap.ContainsKey($_.Name)) })) {
        $Synopsis = (Get-Help -Name $Cmdlet.Name -ErrorAction SilentlyContinue).Synopsis -replace '\|', '\|' -replace '\s+', ' '
        "| [$($Cmdlet.Name)]($($Cmdlet.Name).html) | $Synopsis |"
    }

    $IndexContents = @"
---
title: $Category
has_children: true
---

## $Category - help & documentation

{: .highlight }
Use ``Get-Help <function> -Full`` for the help of a function. The examples of the project are in the [examples folder](https://github.com/Celerium/Celerium.Nova/tree/main/examples)

| **Function** | **Synopsis** |
|--------------|--------------|
$($CountRows -join "`n")

Have a look around and if you would like to contribute please read over the [Contributing guide](https://github.com/Celerium/Celerium.Nova/blob/main/.github/CONTRIBUTING.md)
"@
    New-Item -Path (Join-Path -Path $CategoryPath -ChildPath 'index.md') -ItemType File -Value $IndexContents -Force > $null

}

#EndRegion  [ Organize Markdown ]

Write-Verbose " - (4/4) - $(Get-Date -Format MM-dd-HH:mm) - Regenerating external help"

#Region     [ External Help ]

Export-MamlCommandHelp -CommandHelp $CommandHelp -OutputFolder $TempFolder -Force > $null
$MamlFile = Get-ChildItem -Path $TempFolder -Filter '*-Help.xml' -Recurse | Select-Object -First 1
if (-not $MamlFile) { throw "The external help file of [ $ModuleName ] was not created" }

# Get-Help looks for <ModuleName>-help.xml, the file name is case sensitive on Linux & macOS
Copy-Item -Path $MamlFile.FullName -Destination (Join-Path -Path $ExternalHelp -ChildPath "$ModuleName-help.xml") -Force

if ($IsWindows -or $PSEdition -eq 'Desktop') {

    try { New-HelpCabinetFile -CabinetFilesFolder $ExternalHelp -MarkdownModuleFile $ModulePage -OutputFolder $ExternalHelpCab > $null }
    catch { Write-Warning " -       - $(Get-Date -Format MM-dd-HH:mm) - [ New-HelpCabinetFile ] failed - $($_.Exception.Message)" }

}
else{
    Write-Warning " -       - $(Get-Date -Format MM-dd-HH:mm) - [ New-HelpCabinetFile ] is only run on Windows"
}

#EndRegion  [ External Help ]

Remove-Item -Path $TempFolder -Recurse -Force -ErrorAction SilentlyContinue

if (Get-Module -Name $ModuleName) {
    Remove-Module -Name $ModuleName -Force -Verbose:$false
}

#Open File Explorer to show doc output
if ($ShowHelpDocs) {
    Invoke-Item $HelpDocsPath
}

Write-Verbose ''
Write-Verbose "END - $(Get-Date -Format yyyy-MM-dd-HH:mm)"
Write-Verbose ''

$TimeToComplete = New-TimeSpan -Start $StartDate -End (Get-Date)
Write-Verbose 'Time to complete'
Write-Verbose ($TimeToComplete | Select-Object * -ExcludeProperty Ticks,Total*,Milli* | Out-String)

}
