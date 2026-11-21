---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaResourcePath.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/20/2026
parent: Internal
PlatyPS schema version: 2024-05-01
title: Get-clNovaResourcePath
---

# Get-clNovaResourcePath

## SYNOPSIS

Finds a resource file (template, css, js, icon, or data file) of the module

## SYNTAX

### __AllParameterSets

```
Get-clNovaResourcePath [-RelativePath] <string> [[-SearchPath] <string>]
```

## DESCRIPTION

The Get-clNovaResourcePath cmdlet finds the full path of a resource file that is
shipped with the module

The module is used from two places & the resources are in a different place in each
    - Source module  : build\HtmlReport (next to the module folder)
    - Built module   : <module folder>\HtmlReport

The folders above the file that calls the function are searched for the relative path,
first as <folder>\<RelativePath> & then as <folder>\build\<RelativePath>

This is an internal helper function that is used by the public functions

## EXAMPLES

### EXAMPLE 1

```powershell
Get-clNovaResourcePath -RelativePath 'HtmlReport/templates/Page.html'
```

Returns the full path of the Page.html report template

### EXAMPLE 2

```powershell
Get-clNovaResourcePath -RelativePath 'HtmlReport/missing.json' -ErrorAction SilentlyContinue
```

Returns nothing when the resource does not exist

## PARAMETERS

### -RelativePath

The path of the resource relative to the root of the resources

Example:
    HtmlReport/templates/Page.html
    HtmlReport/css/Celerium.Nova.css

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

### -SearchPath

The folder the search starts from & works up from

By default the folder of this file is used

```yaml
Type: System.String
DefaultValue: $PSScriptRoot
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

- [https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaResourcePath.html](https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaResourcePath.html)