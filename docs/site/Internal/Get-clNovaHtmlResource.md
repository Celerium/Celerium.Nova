---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaHtmlResource.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/20/2026
parent: Internal
PlatyPS schema version: 2024-05-01
title: Get-clNovaHtmlResource
---

# Get-clNovaHtmlResource

## SYNOPSIS

Gets the content of a file used to build an HTML report

## SYNTAX

### __AllParameterSets

```
Get-clNovaHtmlResource [-Name] <string> [[-ResourcePath] <string>]
```

## DESCRIPTION

The Get-clNovaHtmlResource cmdlet reads a template, css, js, or other text file that
is used to build an HTML report

The files are in the HtmlReport folder of the module (build\HtmlReport in the source
module).
A different folder can be used with the ResourcePath parameter

This is an internal helper function that is used by the public functions

## EXAMPLES

### EXAMPLE 1

```powershell
Get-clNovaHtmlResource -Name 'templates/Page.html'
```

Returns the text of the Page.html report template

### EXAMPLE 2

```powershell
Get-clNovaHtmlResource -Name 'css/Celerium.Nova.css' -ResourcePath 'C:\Branding\HtmlReport'
```

Returns the css from a custom HtmlReport folder

## PARAMETERS

### -Name

The path of the file relative to the HtmlReport folder

Example:
    templates/Page.html
    css/Celerium.Nova.css

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

The HtmlReport folder to read the file from

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

- [https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaHtmlResource.html](https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaHtmlResource.html)