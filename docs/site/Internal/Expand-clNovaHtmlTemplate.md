---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/Internal/Expand-clNovaHtmlTemplate.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/21/2026
parent: Internal
PlatyPS schema version: 2024-05-01
title: Expand-clNovaHtmlTemplate
---

# Expand-clNovaHtmlTemplate

## SYNOPSIS

Replaces the {{Name}} tokens of an HTML template with values

## SYNTAX

### __AllParameterSets

```
Expand-clNovaHtmlTemplate [-Template] <string> [-Token] <IDictionary>
```

## DESCRIPTION

The Expand-clNovaHtmlTemplate cmdlet replaces every {{Name}} token of a template with
the value of the same name in the Token hashtable

The tokens are replaced in one pass, so a {{Name}} text inside of a value is never
replaced again.
A token without a value is replaced with an empty string

The values are NOT encoded, encode text values with ConvertTo-clNovaHtmlEncoded before
adding them to the Token hashtable

This is an internal helper function that is used by the public functions

## EXAMPLES

### EXAMPLE 1

```powershell
{{Title}}</h1>' -Token @{ Title = 'Report' }
```

Returns <h1>Report</h1>

## PARAMETERS

### -Template

The text with the {{Name}} tokens

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

### -Token

Hashtable of token names & the values to replace them with

Example:
    @{ Title = 'Report'; Body = '<p>Text</p>' }

```yaml
Type: System.Collections.IDictionary
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

- [https://celerium.github.io/Celerium.Nova/site/Internal/Expand-clNovaHtmlTemplate.html](https://celerium.github.io/Celerium.Nova/site/Internal/Expand-clNovaHtmlTemplate.html)