---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlSummaryCardSet.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/21/2026
parent: HtmlReport
PlatyPS schema version: 2024-05-01
title: New-clNovaHtmlSummaryCardSet
---

# New-clNovaHtmlSummaryCardSet

## SYNOPSIS

Creates the HTML of a group of summary cards that are laid out in evenly filled rows

## SYNTAX

### __AllParameterSets

```
New-clNovaHtmlSummaryCardSet [-Card] <Object[]> [[-MaxPerRow] <int>] [[-Id] <string>]
 [[-ResourcePath] <string>]
```

## DESCRIPTION

The New-clNovaHtmlSummaryCardSet cmdlet creates the HTML of any number of summary cards &
scales the layout to fit them.
Every row has the same number of cards

    6 cards  -> 2 rows of 3 cards
    12 cards -> 3 rows of 4 cards

At most MaxPerRow cards are placed on one row of a desktop screen, tablets show 2 cards per
row, & phones show 1 card per row.
A row that can not be filled evenly (for example 7 cards)
is centered

Every card is defined by a hashtable or an object with the same properties as the
parameters of New-clNovaHtmlSummaryCard (Title, Value, Note, Percent, Color, Icon, Tooltip, & Url)

## EXAMPLES

### EXAMPLE 1

```powershell
$Cards = 1..6 | ForEach-Object { @{ Title = "Card $_"; Value = $_ } }
New-clNovaHtmlSummaryCardSet -Card $Cards
```

Returns the HTML of 6 cards placed on 2 rows with 3 cards on each row

### EXAMPLE 2

```powershell
$Cards = @(
    @{ Title = 'Supported'; Value = '14 | 61%'; Percent = 61; Color = 'Success'; Icon = 'check-circle-fill' }
    [PSCustomObject]@{ Title = 'Total'; Value = 23; Icon = 'laptop' }
)
$Cards | New-clNovaHtmlSummaryCardSet -MaxPerRow 6
```

Returns the HTML of 2 cards, cards can be sent down the pipeline

## PARAMETERS

### -Card

One or more cards, hashtables or objects with the properties of New-clNovaHtmlSummaryCard

Example:
    @{ Title = 'Total'; Value = 23; Icon = 'laptop' }

```yaml
Type: System.Object[]
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: true
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Id

The HTML id of the group, can be used as an anchor (#psn-summary)

Default value: psn-summary

```yaml
Type: System.String
DefaultValue: psn-summary
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

### -MaxPerRow

The most cards that are placed on one row of a desktop screen

Default value: 4

```yaml
Type: System.Int32
DefaultValue: 4
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
  Position: 3
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

## NOTES

N\A


## RELATED LINKS

- [https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlSummaryCardSet.html](https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlSummaryCardSet.html)