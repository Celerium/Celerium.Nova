---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/Internal/ConvertTo-clNovaHtmlDataUri.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/20/2026
parent: Internal
PlatyPS schema version: 2024-05-01
title: ConvertTo-clNovaHtmlDataUri
---

# ConvertTo-clNovaHtmlDataUri

## SYNOPSIS

Converts an image file to a data uri that can be embedded in an HTML page

## SYNTAX

### __AllParameterSets

```
ConvertTo-clNovaHtmlDataUri [-Path] <string>
```

## DESCRIPTION

The ConvertTo-clNovaHtmlDataUri cmdlet reads an image file & returns it as a base64 data uri
(data:image/png;base64,...) so the image is part of the HTML file & is also shown when the
computer is offline

The supported files are png, jpg, jpeg, gif, svg, webp, & ico

This is an internal helper function that is used by the public functions

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertTo-clNovaHtmlDataUri -Path .\logo.png
```

Returns data:image/png;base64,iVBORw0KGgo...

## PARAMETERS

### -Path

The path of the image file

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

- [https://celerium.github.io/Celerium.Nova/site/Internal/ConvertTo-clNovaHtmlDataUri.html](https://celerium.github.io/Celerium.Nova/site/Internal/ConvertTo-clNovaHtmlDataUri.html)