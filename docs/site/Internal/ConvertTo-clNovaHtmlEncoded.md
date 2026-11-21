---
document type: cmdlet
external help file: Celerium.Nova-Help.xml
HelpUri: https://celerium.github.io/Celerium.Nova/site/Internal/ConvertTo-clNovaHtmlEncoded.html
Locale: en-US
Module Name: Celerium.Nova
ms.date: 11/20/2026
parent: Internal
PlatyPS schema version: 2024-05-01
title: ConvertTo-clNovaHtmlEncoded
---

# ConvertTo-clNovaHtmlEncoded

## SYNOPSIS

Encodes text so that it can safely be placed in HTML

## SYNTAX

### __AllParameterSets

```
ConvertTo-clNovaHtmlEncoded [[-InputObject] <Object>]
```

## DESCRIPTION

The ConvertTo-clNovaHtmlEncoded cmdlet HTML encodes the string value of an object so that
characters such as < > & " ' are shown as text & can not change the HTML of a report

A null value returns an empty string

This is an internal helper function that is used by the public functions

## EXAMPLES

### EXAMPLE 1

```powershell
Server & Client</b>'
```

Returns &lt;b&gt;Server &amp; Client&lt;/b&gt;

### EXAMPLE 2

```powershell
'DC01', 'A&B' | ConvertTo-clNovaHtmlEncoded
```

Returns the encoded value of every item sent down the pipeline

## PARAMETERS

### -InputObject

The value to encode, the string value of the object is encoded

```yaml
Type: System.Object
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object

## OUTPUTS

### System.String

## NOTES

N\A


## RELATED LINKS

- [https://celerium.github.io/Celerium.Nova/site/Internal/ConvertTo-clNovaHtmlEncoded.html](https://celerium.github.io/Celerium.Nova/site/Internal/ConvertTo-clNovaHtmlEncoded.html)