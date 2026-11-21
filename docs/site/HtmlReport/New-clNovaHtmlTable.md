---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlTable.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/21/2026
parent: HtmlReport
PlatyPS schema version: 2024-05-01
title: New-clNovaHtmlTable
---

# New-clNovaHtmlTable

## SYNOPSIS

Creates the HTML of a sortable, searchable table card from PowerShell objects

## SYNTAX

### __AllParameterSets

```
New-clNovaHtmlTable [[-InputObject] <Object[]>] [[-Property] <string[]>]
 [[-ColumnName] <IDictionary>] [[-StatusMap] <IDictionary>] [[-Title] <string>] [[-Id] <string>]
 [[-PageSize] <int>] [[-Note] <string[]>] [[-DateFormat] <string>] [[-ResourcePath] <string>]
```

## DESCRIPTION

The New-clNovaHtmlTable cmdlet converts PowerShell objects into the HTML of a table card
for an HTML report

The table
    - Can be sorted by clicking any column header (numbers, dates, & text are sorted correctly)
    - Can be searched & shows a configurable number of rows per page
    - Highlights the entire row when the mouse is over it
    - Scrolls sideways on small screens instead of breaking the page

Only the properties in the Property parameter are shown (in that order).
When it is not
used the first 8 properties of the first object are shown so that the table fits on a typical
monitor without a lot of horizontal scrolling

All values are HTML encoded.
The sorting, search, & paging are done by the script of the Celerium.Nova
report (build\HtmlReport\js\Celerium.Nova.js) which New-clNovaHtmlReport adds to the page

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Process | Select-Object -First 50 | New-clNovaHtmlTable -Property Name, Id, CPU -Title 'Processes'
```

Returns the HTML of a table card that shows the Name, Id, & CPU of 50 processes

### EXAMPLE 2

```powershell
$Data | New-clNovaHtmlTable -Property ComputerName, Support -StatusMap @{ Support = @{ Yes = 'Success'; No = 'Danger' } }
```

Returns the HTML of a table where the Support column is shown as green & red badges

## PARAMETERS

### -ColumnName

Hashtable of a property name & the column title to show for it

Example:
    @{ OSVersion = 'OS Version'; EndOfSupport = 'End Of Support' }

```yaml
Type: System.Collections.IDictionary
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

### -DateFormat

The format of date values

Default value: yyyy-MM-dd HH:mm

```yaml
Type: System.String
DefaultValue: yyyy-MM-dd HH:mm
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

### -Id

The HTML id of the table

Default value: psn-table

```yaml
Type: System.String
DefaultValue: psn-table
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

### -InputObject

The objects to show in the table, hashtables are also accepted

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

### -Note

Notes that are shown in a list below the table

```yaml
Type: System.String[]
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

### -PageSize

The number of rows shown per page, 0 shows all rows

Default value: 10

```yaml
Type: System.Int32
DefaultValue: 10
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

### -Property

The names of the properties to show as columns

By default the first 8 properties of the first object are used

```yaml
Type: System.String[]
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

### -ResourcePath

The HtmlReport folder to read the templates from

By default the folder of the module is used

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

### -StatusMap

Colors the values of a column as a status badge

Hashtable of a property name & a hashtable of values & colors

Acceptable colors:
    'Primary','Success','Info','Warning','Danger','Secondary','Dark'

Example:
    @{ Support = @{ Yes = 'Success'; 'Ending Soon' = 'Warning'; No = 'Danger' } }

```yaml
Type: System.Collections.IDictionary
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

### -Title

The title shown in the header of the table card

```yaml
Type: System.String
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

- [https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlTable.html](https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlTable.html)