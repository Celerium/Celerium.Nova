---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaCardLayout.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/21/2026
parent: Internal
PlatyPS schema version: 2024-05-01
title: Get-clNovaCardLayout
---

# Get-clNovaCardLayout

## SYNOPSIS

Calculates how many summary cards are placed in each row

## SYNTAX

### __AllParameterSets

```
Get-clNovaCardLayout [-Count] <int> [[-MaxPerRow] <int>] [[-MaxPerRowTablet] <int>]
```

## DESCRIPTION

The Get-clNovaCardLayout cmdlet calculates the number of summary cards per row so that
every row has the same number of cards

    2 rows with 6 cards  -> 3 cards on the top row & 3 on the bottom row
    3 rows with 12 cards -> 4 cards on each of the 3 rows

The number of rows is the minimum number of rows needed with the MaxPerRow limit.
The cards
per row is then the number of cards divided by the rows.
When the cards can not be divided
evenly (7 cards) the last row is shorter

The layout is calculated for desktops (Xl), tablets (Md), & phones (Sm)

This is an internal helper function that is used by the public functions

## EXAMPLES

### EXAMPLE 1

```powershell
Get-clNovaCardLayout -Count 6
```

Returns a layout of 2 rows with 3 cards per row for desktops

### EXAMPLE 2

```powershell
Get-clNovaCardLayout -Count 12 -MaxPerRow 4
```

Returns a layout of 3 rows with 4 cards per row for desktops

## PARAMETERS

### -Count

The number of summary cards

```yaml
Type: System.Int32
DefaultValue: 0
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

### -MaxPerRow

The most cards that are allowed on one row of a desktop screen

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

### -MaxPerRowTablet

The most cards that are allowed on one row of a tablet screen

Default value: 2

```yaml
Type: System.Int32
DefaultValue: 2
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

N\A


## RELATED LINKS

- [https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaCardLayout.html](https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaCardLayout.html)