---
external help file: Celerium.Nova-help.xml
Module Name: Celerium.Nova
online version: https://github.com/Celerium/Celerium.Nova
schema: 2.0.0
title: Home
has_children: true
layout: default
nav_order: 1
---

<h1 align="center">
  <br>
  <a href="http://Celerium.org"><img src="https://raw.githubusercontent.com/Celerium/Celerium.Nova/main/.github/images/Celerium_PoSHGallery_Celerium.Nova.png" alt="_CeleriumNova" width="200"></a>
  <br>
  Celerium.Nova
  <br>
</h1>

[![GitHub_CI][GitHub_CI-shield]][GitHub_CI-url]
[![GitHub_Docs][GitHub_Docs-shield]][GitHub_Docs-url]
[![GitHub_PSScriptAnalyzer][GitHub_PSScriptAnalyzer-shield]][GitHub_PSScriptAnalyzer-url]
[![GitHub_Pages][GitHub_Pages-shield]][GitHub_Pages-url]

[![PoshGallery_Version][PoshGallery_Version-shield]][PoshGallery_Version-url]
[![PoshGallery_Platforms][PoshGallery_Platforms-shield]][PoshGallery_Platforms-url]
[![PoshGallery_Downloads][PoshGallery_Downloads-shield]][PoshGallery_Downloads-url]
[![codeSize][codeSize-shield]][codeSize-url]

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]

[![Blog][Website-shield]][Website-url]
[![GitHub_License][GitHub_License-shield]][GitHub_License-url]

---

## Buy me a coffee

Whether you use this project, have learned something from it, or just like it, please consider supporting it by buying me a coffee, so I can dedicate more time on open-source projects like this :)

<a href="https://www.buymeacoffee.com/Celerium" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg" alt="Buy Me A Coffee" style="width:150px;height:50px;"></a>

---

<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://celerium.org">
    <img src="https://raw.githubusercontent.com/Celerium/Celerium.Nova/main/.github/images/Celerium_PoSHGitHub_Celerium.Nova.png" alt="Logo">
  </a>

  <p align="center">
    <a href="https://www.powershellgallery.com/packages/Celerium.Nova" target="_blank">PowerShell Gallery</a>
    ·
    <a href="https://github.com/Celerium/Celerium.Nova/issues/new/choose" target="_blank">Report Bug</a>
    ·
    <a href="https://github.com/Celerium/Celerium.Nova/issues/new/choose" target="_blank">Request Feature</a>
  </p>
</div>

---

## Table of contents

- [About The Project](#about-the-project)
- [Install](#install)
- [HTML reports](#html-reports)
- [Using Celerium.Nova in your own functions](#using-Celerium.Nova-in-your-own-functions)
- [Project layout](#project-layout)
- [Building & testing](#building--testing)
- [Contributing](#contributing)
- [License](#license)

---

## About The Project

Celerium.Nova is a standalone PowerShell module that turns **any PowerShell objects into modern HTML reports** that work offline, on desktops, & on mobile devices. It works on **Windows PowerShell 5.1** and **PowerShell 7+** (Windows, Linux, & macOS), has no dependencies on other modules, & is made to be used by other functions & scripts to create their reports.

[Back to top](#readme-top)

---

## Install

```powershell
Install-Module -Name Celerium.Nova -Scope CurrentUser
Import-Module -Name Celerium.Nova
```

To use a local copy of this repository instead

```powershell
Import-Module -Name ./Celerium.Nova/Celerium.Nova.psd1 -Force
```

| Function | What it does |
|----------|--------------|
| `New-clNovaHtmlReport` | Creates a complete HTML report from PowerShell objects |
| `New-clNovaHtmlSummaryCardSet` | Creates summary cards that are laid out in evenly filled rows |
| `New-clNovaHtmlSummaryCard` | Creates one summary card |
| `New-clNovaHtmlTable` | Creates a sortable, searchable table from PowerShell objects |

Use `Get-Help <function> -Full` for the help of a function. The [examples](examples/README.md) show how to use them.

[Back to top](#readme-top)

---

## HTML reports

The report functions can be used with the objects of any command.

```powershell
$Cards = @(
    @{ Title = 'Running'; Value = 120; Percent = 60; Color = 'Success'; Icon = 'check-circle-fill' }
    @{ Title = 'Stopped'; Value = 80;  Percent = 40; Color = 'Danger';  Icon = 'x-circle-fill' }
)

Get-Service | Select-Object Name, DisplayName, Status, StartType |
    New-clNovaHtmlReport -Title 'Services' -SummaryCard $Cards -Path .\Services.html `
        -StatusMap @{ Status = @{ Running = 'Success'; Stopped = 'Danger' } }
```

- **Design** - Based on [SB Admin 2 v4.1.4](https://github.com/StartBootstrap/startbootstrap-sb-admin-2) ported to [Bootstrap 5.3](https://getbootstrap.com/docs/5.3/getting-started/introduction/). The sidebar & header are dark (`#212529`) & the body is an off white that is easy on the eyes
- **Offline** - Bootstrap, the theme, the icons (Bootstrap Icons as inline SVG), & the scripts are embedded in the file. Use `-ResourceMode Cdn` with `New-clNovaHtmlReport` to link the Bootstrap 5.3 CDN files (with SRI hashes) instead
- **Mobile friendly** - The layout works on Android, iOS, Windows, & Linux. The sidebar slides over the page on phones. Legacy browsers are not supported
- **Summary cards** - Any number of cards can be used & the layout is scaled to fit them. Every row has the same number of cards: 6 cards are 2 rows of 3, 12 cards are 3 rows of 4 (at most 4 per row on a desktop, 2 on a tablet, & 1 on a phone)
- **Table** - Sortable by any column (numbers, dates, & text), searchable, paged, the whole row is highlighted when the mouse is over it, & the columns are chosen with `-Property`
- **Reusable** - `New-clNovaHtmlSummaryCardSet`, `New-clNovaHtmlSummaryCard`, & `New-clNovaHtmlTable` create the pieces separately so they can be used in other reports. All values are HTML encoded

The templates, css, js, & icons of a report are the source files in [build/HtmlReport](build/HtmlReport). Use `-ResourcePath` to use a customized copy.

[Back to top](#readme-top)

---

## Using Celerium.Nova in your own functions

Add Celerium.Nova as a required module of your own module (`RequiredModules = @('Celerium.Nova')`) or import it in your script, then pass the objects to `New-clNovaHtmlReport`. The function returns the HTML so the caller decides what to do with it, or saves it when `-Path` is used.

```powershell
#Requires -Modules Celerium.Nova

function Get-DiskReport {
    [CmdletBinding()]
    param ([string]$Path = (Join-Path -Path $env:TEMP -ChildPath 'Disks.html'))

    $Disks = Get-Volume | Where-Object DriveLetter | Select-Object DriveLetter, FileSystemLabel, HealthStatus, SizeRemaining, Size

    $Cards = @(
        @{ Title = 'Volumes'; Value = $Disks.Count; Icon = 'hdd'; Color = 'Primary' }
    )

    $Disks | New-clNovaHtmlReport -Title 'Disks' -SummaryCard $Cards -Path $Path
}
```

[Back to top](#readme-top)

---

## Project layout

| Folder | Content |
|--------|---------|
| [Celerium.Nova](Celerium.Nova) | The module. `Public` & `Private` hold the functions |
| [build](build) | Build scripts & the source files of the HTML report (`build/HtmlReport`) |
| [tests](tests) | [Pester](https://pester.dev) tests |
| [examples](examples) | Examples of the functions |
| [docs](docs) | The GitHub pages site that is generated by the scripts in `build` |
| [.github](.github) | GitHub Actions workflows, issue templates, & contributing guides |

[Back to top](#readme-top)

---

## Building & testing

All scripts work on Windows PowerShell 5.1 & PowerShell 7+. The latest version of every prerequisite module (ModuleBuilder, Pester, PSScriptAnalyzer, & Microsoft.PowerShell.PlatyPS) is installed.

```powershell
./build/Install-Prerequisites.ps1
./build/Update-ModuleExports.ps1                       # after a function is added or removed
./build/Invoke-ModuleBuild.ps1 -Version 3.0.0
./build/Invoke-PesterTests.ps1 -Version 3.0.0 -BuildTarget notBuilt
./build/Invoke-PesterTests.ps1 -Version 3.0.0 -BuildTarget built
./build/Invoke-HelpContent.ps1                         # docs (GitHub pages)
./build/Update-HtmlResources.ps1                       # latest Bootstrap & Bootstrap Icons
```

GitHub Actions (`.github/workflows`) build & test the module on Windows PowerShell 5.1, PowerShell 7+ on Windows, Linux, & macOS, run PSScriptAnalyzer, build the documentation, refresh the HTML report resources every week, & publish releases.

[Back to top](#readme-top)

---

## Contributing

See the [Contributing guide](.github/CONTRIBUTING.md). All parameters & variables use PascalCase & the help of a function is placed directly below the function line.

[Back to top](#readme-top)

---

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information. The report design is based on SB Admin 2 & Bootstrap (MIT).

[Back to top](#readme-top)

<!-- MARKDOWN LINKS & IMAGES -->
[GitHub_CI-shield]: https://img.shields.io/github/actions/workflow/status/Celerium/Celerium.Nova/ci.yml?branch=main&label=CI&style=for-the-badge
[GitHub_CI-url]: https://github.com/Celerium/Celerium.Nova/actions/workflows/ci.yml
[GitHub_Docs-shield]: https://img.shields.io/github/actions/workflow/status/Celerium/Celerium.Nova/docs.yml?branch=main&label=Docs&style=for-the-badge
[GitHub_Docs-url]: https://github.com/Celerium/Celerium.Nova/actions/workflows/docs.yml
[GitHub_PSScriptAnalyzer-shield]: https://img.shields.io/github/actions/workflow/status/Celerium/Celerium.Nova/powershell.yml?branch=main&label=PSScriptAnalyzer&style=for-the-badge
[GitHub_PSScriptAnalyzer-url]: https://github.com/Celerium/Celerium.Nova/actions/workflows/powershell.yml
[GitHub_Pages-shield]: https://img.shields.io/badge/GitHub-Pages-blue?style=for-the-badge
[GitHub_Pages-url]: https://celerium.github.io/Celerium.Nova/
[PoshGallery_Version-shield]: https://img.shields.io/powershellgallery/v/Celerium.Nova?include_prereleases&style=for-the-badge
[PoshGallery_Version-url]: https://www.powershellgallery.com/packages/Celerium.Nova
[PoshGallery_Platforms-shield]: https://img.shields.io/powershellgallery/p/Celerium.Nova?style=for-the-badge
[PoshGallery_Platforms-url]: https://www.powershellgallery.com/packages/Celerium.Nova
[PoshGallery_Downloads-shield]: https://img.shields.io/powershellgallery/dt/Celerium.Nova?style=for-the-badge
[PoshGallery_Downloads-url]: https://www.powershellgallery.com/packages/Celerium.Nova
[codeSize-shield]: https://img.shields.io/github/languages/code-size/Celerium/Celerium.Nova?style=for-the-badge
[codeSize-url]: https://github.com/Celerium/Celerium.Nova
[contributors-shield]: https://img.shields.io/github/contributors/Celerium/Celerium.Nova?style=for-the-badge
[contributors-url]: https://github.com/Celerium/Celerium.Nova/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Celerium/Celerium.Nova?style=for-the-badge
[forks-url]: https://github.com/Celerium/Celerium.Nova/network/members
[stars-shield]: https://img.shields.io/github/stars/Celerium/Celerium.Nova?style=for-the-badge
[stars-url]: https://github.com/Celerium/Celerium.Nova/stargazers
[issues-shield]: https://img.shields.io/github/issues/Celerium/Celerium.Nova?style=for-the-badge
[issues-url]: https://github.com/Celerium/Celerium.Nova/issues
[Website-shield]: https://img.shields.io/website?up_message=online&url=https%3A%2F%2Fcelerium.org&style=for-the-badge&label=Blog
[Website-url]: https://celerium.org
[GitHub_License-shield]: https://img.shields.io/github/license/Celerium/Celerium.Nova?style=for-the-badge
[GitHub_License-url]: https://github.com/Celerium/Celerium.Nova/blob/main/LICENSE
