---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlSummaryCard.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/21/2026
parent: HtmlReport
PlatyPS schema version: 2024-05-01
title: New-clNovaHtmlSummaryCard
---

# New-clNovaHtmlSummaryCard

## SYNOPSIS

Creates the HTML of one summary card

## SYNTAX

### __AllParameterSets

```
New-clNovaHtmlSummaryCard [-Title] <string> [-Value] <Object> [[-Note] <string>]
 [[-Percent] <double>] [[-Color] <string>] [[-Icon] <string>] [[-Tooltip] <string>]
 [[-Url] <string>] [[-ResourcePath] <string>]
```

## DESCRIPTION

The New-clNovaHtmlSummaryCard cmdlet creates the HTML of a single summary card for an HTML
report.
A summary card shows one quick fact about the data in the report such as a
total, a percentage, or a link

A card can show a progress bar (Percent), a small note, an icon, & a tooltip.
A card
with a Url is a link

The cards are placed on the page with New-clNovaHtmlSummaryCardSet which creates evenly
filled rows of cards.
The HTML needs the Celerium.Nova report css to look right, use
New-clNovaHtmlReport to create a complete page

## EXAMPLES

### EXAMPLE 1

```powershell
New-clNovaHtmlSummaryCard -Title 'Total Computers' -Value 23 -Icon 'laptop' -Color Primary
```

Returns the HTML of a card that shows the total number of computers

### EXAMPLE 2

```powershell
New-clNovaHtmlSummaryCard -Title 'Supported' -Value '14 | 61%' -Percent 61 -Color Success -Icon 'check-circle-fill' -Tooltip 'Systems Microsoft supports'
```

Returns the HTML of a card with a progress bar that is 61% full

### EXAMPLE 3

```powershell
New-clNovaHtmlSummaryCard -Title 'Microsoft Lifecycles' -Value 'learn.microsoft.com' -Url 'https://learn.microsoft.com/en-us/lifecycle/products/' -Color Info
```

Returns the HTML of a card that opens the Microsoft lifecycle pages

## PARAMETERS

### -Color

The color of the card border, title, & progress bar

Acceptable values:
    'Primary','Success','Info','Warning','Danger','Secondary','Dark'

Default value: Primary

```yaml
Type: System.String
DefaultValue: Primary
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

### -Icon

The name of a Bootstrap Icon to show on the card

Default value: clipboard-data

Icons that can be used are listed in build\HtmlReport\resources.json

```yaml
Type: System.String
DefaultValue: clipboard-data
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

### -Note

A small line of text shown below the value

```yaml
Type: System.String
DefaultValue: ''
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

### -Percent

Shows a progress bar that is filled with this percentage (0 - 100)

```yaml
Type: System.Double
DefaultValue: 0
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

### -ResourcePath

The HtmlReport folder to read the templates & icons from

By default the folder of the module is used

```yaml
Type: System.String
DefaultValue: ''
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

### -Title

The title of the card

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Tooltip

The text that is shown when the mouse is over the card

```yaml
Type: System.String
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

### -Url

Makes the card a link.
Only http, https, mailto, & page (#) links are allowed

```yaml
Type: System.String
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

### -Value

The main value of the card such as a total or text like [ 14 | 61% ]

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: true
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

## OUTPUTS

### System.String

## NOTES

N\A


## RELATED LINKS

- [https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlSummaryCard.html](https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlSummaryCard.html)