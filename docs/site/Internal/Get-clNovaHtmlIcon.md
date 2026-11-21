---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaHtmlIcon.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/21/2026
parent: Internal
PlatyPS schema version: 2024-05-01
title: Get-clNovaHtmlIcon
---

# Get-clNovaHtmlIcon

## SYNOPSIS

Gets an inline SVG icon for an HTML report

## SYNTAX

### __AllParameterSets

```
Get-clNovaHtmlIcon [-Name] <string> [[-ResourcePath] <string>]
```

## DESCRIPTION

The Get-clNovaHtmlIcon cmdlet returns a Bootstrap Icon as inline SVG so that the icon
works in an offline report & does not need a font or an internet connection

The icons are the svg files in the icons folder of the report resources
(build\HtmlReport\icons).
The Update-HtmlResources.ps1 build script downloads them

When the icon does not exist the info-circle icon is returned.
An empty string
is returned when there are no icons at all

This is an internal helper function that is used by the public functions

## EXAMPLES

### EXAMPLE 1

```powershell
Get-clNovaHtmlIcon -Name 'server'
```

Returns the SVG of the server icon

## PARAMETERS

### -Name

The name of the Bootstrap Icon without the .svg extension

Example:
    server
    check-circle-fill

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

### -ResourcePath

The HtmlReport folder to read the icons from

By default the folder of the module is used

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

- [https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaHtmlIcon.html](https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaHtmlIcon.html)