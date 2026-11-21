<h1 align="center">
  <br>
  <a href="http://Celerium.org"><img src="https://raw.githubusercontent.com/Celerium/Celerium.Nova/main/.github/images/Celerium_PoSHGallery_Celerium.Nova.png" alt="_CeleriumNova" width="200"></a>
  <br>
  Celerium.Nova_Examples
  <br>
</h1>

---

## Examples

- :book: Project documentation can be found on [Github Pages](https://celerium.github.io/Celerium.Nova/)

:warning: Please note that the following examples are provided **"AS IS"** and only serve as a proof of concept to show possible uses of the [Celerium.Nova](https://github.com/Celerium/Celerium.Nova) PowerShell module.

The examples work the same in Windows PowerShell 5.1 and PowerShell 7+ on Windows, Linux, and macOS.

| Example | What it shows | Functions used |
|---------|---------------|----------------|
| [New-HtmlReportExample.ps1](New-HtmlReportExample.ps1) | Turn any PowerShell objects into a modern, offline friendly HTML report with summary cards & a sortable table, or build the pieces separately | `New-clNovaHtmlReport`, `New-clNovaHtmlSummaryCardSet`, `New-clNovaHtmlSummaryCard`, `New-clNovaHtmlTable` |

### Before you run an example

1. Install the module with `Install-Module -Name Celerium.Nova`. The examples import the module by name. To use a local copy of the repository, import it first (the examples then use the loaded module):

   ```powershell
   Import-Module -Name ./Celerium.Nova/Celerium.Nova.psd1 -Force
   ```

2. Run an example. They do not need any credentials:

   ```powershell
   ./examples/New-HtmlReportExample.ps1 -OutputPath ./Reports
   ```

Use `Get-Help ./examples/<script>.ps1 -Full` to see every parameter of an example.

---

## Buy me a coffee

Whether you use this project, have learned something from it, or just like it, please consider supporting it by buying me a coffee, so I can dedicate more time on open-source projects like this :)

<a href="https://www.buymeacoffee.com/Celerium" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg" alt="Buy Me A Coffee" style="width:150px;height:50px;"></a>

---
