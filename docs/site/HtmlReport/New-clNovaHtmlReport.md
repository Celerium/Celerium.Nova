---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlReport.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/20/2026
parent: HtmlReport
PlatyPS schema version: 2024-05-01
title: New-clNovaHtmlReport
---

# New-clNovaHtmlReport

## SYNOPSIS

Creates a modern, mobile friendly HTML report from PowerShell objects

## SYNTAX

### __AllParameterSets

```
New-clNovaHtmlReport [[-InputObject] <Object[]>] [[-Path] <string>] [[-Title] <string>]
 [[-Subtitle] <string>] [[-Property] <string[]>] [[-ColumnName] <IDictionary>]
 [[-StatusMap] <IDictionary>] [[-SummaryCard] <Object[]>] [[-MaxCardsPerRow] <int>]
 [[-TableTitle] <string>] [[-TableNote] <string[]>] [[-PageSize] <int>]
 [[-NavigationItem] <Object[]>] [[-BrandText] <string>] [[-BrandIcon] <string>]
 [[-BrandLogoPath] <string>] [[-BrandLogoCollapsedPath] <string>] [[-FaviconPath] <string>]
 [[-BrandUrl] <string>] [[-Description] <string>] [[-Author] <string>] [[-Footer] <string>]
 [[-ResourceMode] <string>] [[-ResourcePath] <string>] [-WhatIf] [-Confirm]
```

## DESCRIPTION

The New-clNovaHtmlReport cmdlet turns any PowerShell objects into a single HTML file with
a dark sidebar & header, an off white body, summary cards, & a sortable, searchable table

The design is based on SB Admin 2 (ported to Bootstrap 5.3) & works on desktops
(Windows, Linux, & macOS) as well as on Android & iOS phones & tablets

By default everything needed (Bootstrap, the theme, the icons, & the scripts) is embedded in the
file so the report works offline.
Use -ResourceMode Cdn to link the Bootstrap 5.3 CDN files instead
which makes the file smaller

The pieces of the report are also available as separate functions which can be used to build
other reports
    - New-clNovaHtmlSummaryCardSet & New-clNovaHtmlSummaryCard
    - New-clNovaHtmlTable

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Service | New-clNovaHtmlReport -Title 'Services' -Property Name, Status, StartType -Path .\Services.html
```

Creates an HTML report of the services & saves it to Services.html

### EXAMPLE 2

```powershell
$Cards = @(
```

@{ Title = 'Running'; Value = 120; Color = 'Success'; Icon = 'check-circle-fill' }
    @{ Title = 'Stopped'; Value = 80; Color = 'Danger'; Icon = 'x-circle-fill' }
)
$Services | New-clNovaHtmlReport -Title 'Services' -SummaryCard $Cards -StatusMap @{ Status = @{ Running = 'Success'; Stopped = 'Danger' } } -Path .\Services.html

Creates a report with 2 summary cards & colors the Status column

### EXAMPLE 3

```powershell
$Html = Get-Process | New-clNovaHtmlReport -Title 'Processes' -ResourceMode Cdn
```

Returns the HTML text of a report that links to the Bootstrap CDN files

## PARAMETERS

### -Author

The author meta tag of the page

```yaml
Type: System.String
DefaultValue: Celerium.Nova
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 20
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -BrandIcon

The name of the Bootstrap Icon shown next to the name at the top of the sidebar

Default value: speedometer2

```yaml
Type: System.String
DefaultValue: speedometer2
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 14
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -BrandLogoCollapsedPath

The path of the logo image that is shown at the top of the sidebar when the sidebar is collapsed

Only used with BrandLogoPath.
BrandLogoPath is shown when the sidebar is expanded.
A square image works best

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 16
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -BrandLogoPath

The path of a logo image (png, jpg, gif, svg, or webp) that replaces the icon & the name at the top of the sidebar

The logo is embedded in the report, so it is also shown when the computer is offline.
The icon & the name
are used as the alternative text.
When the sidebar is collapsed only the left part (the symbol) of the logo is shown
unless BrandLogoCollapsedPath is used

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 15
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -BrandText

The name shown at the top of the sidebar

Default value: Celerium.Nova

```yaml
Type: System.String
DefaultValue: Celerium.Nova
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 13
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -BrandUrl

The link of the name at the top of the sidebar

Default value: #

```yaml
Type: System.String
DefaultValue: '#'
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 18
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ColumnName

Hashtable of a property name & the column title to show for it

```yaml
Type: System.Collections.IDictionary
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 5
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Description

The description meta tag of the page

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 19
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -FaviconPath

The path of the icon (ico, png, or svg) that is shown on the browser tab

The icon is embedded in the report.
By default an icon of BrandIcon is used

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 17
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Footer

Text shown at the bottom of the page

By default no footer is shown

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 21
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -InputObject

The objects shown in the table of the report

```yaml
Type: System.Object[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -MaxCardsPerRow

The most summary cards on one row of a desktop screen

Default value: 4

```yaml
Type: System.Int32
DefaultValue: 4
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 8
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -NavigationItem

The links of the sidebar.
Hashtables or objects with the properties Text, Url, Icon, & Heading

Items with the same Heading are grouped under it.
By default links to the summary & the table are shown

Example:
    @{ Heading = 'Help'; Text = 'Documentation'; Url = 'https://celerium.org'; Icon = 'info-circle' }

```yaml
Type: System.Object[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 12
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -PageSize

The number of table rows shown per page, 0 shows all rows

Default value: 10

```yaml
Type: System.Int32
DefaultValue: 10
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 11
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Path

The file to save the report to.
The folder is created when it does not exist

When it is not used the HTML text is returned instead

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Property

The properties shown as table columns

By default the first 8 properties of the first object are used

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 4
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourceMode

How Bootstrap is added to the report

Acceptable values:
    'Embedded','Cdn'

Embedded places the files in the report so it works offline (default).
Cdn links the Bootstrap 5.3
files of the jsDelivr CDN, an internet connection is needed to view the report

```yaml
Type: System.String
DefaultValue: Embedded
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 22
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -ResourcePath

The HtmlReport folder to read the templates, css, js, & icons from

By default the folder of the module is used.
Use this to change the look of the report

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 23
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -StatusMap

Colors the values of a column as a status badge, see New-clNovaHtmlTable

Example:
    @{ Support = @{ Yes = 'Success'; 'Ending Soon' = 'Warning'; No = 'Danger' } }

```yaml
Type: System.Collections.IDictionary
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 6
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Subtitle

A line of text shown next to the heading such as where the data came from

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 3
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -SummaryCard

The summary cards shown above the table.
Hashtables or objects with the properties of
New-clNovaHtmlSummaryCard (Title, Value, Note, Percent, Color, Icon, Tooltip, & Url)

The cards are laid out in rows that all have the same number of cards

```yaml
Type: System.Object[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 7
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TableNote

Notes shown in a list below the table

```yaml
Type: System.String[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 10
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -TableTitle

The title shown in the header of the table

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 9
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Title

The title of the report, shown in the header, the page title, & as the heading

```yaml
Type: System.String
DefaultValue: Celerium.Nova Report
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object[]

## OUTPUTS

### System.String

### System.IO.FileInfo

## NOTES

N\A


## RELATED LINKS

- [https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlReport.html](https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlReport.html)