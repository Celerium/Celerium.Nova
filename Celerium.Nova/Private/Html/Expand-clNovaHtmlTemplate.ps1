function Expand-clNovaHtmlTemplate {
<#
    .SYNOPSIS
        Replaces the {{Name}} tokens of an HTML template with values

    .DESCRIPTION
        The Expand-clNovaHtmlTemplate cmdlet replaces every {{Name}} token of a template with
        the value of the same name in the Token hashtable

        The tokens are replaced in one pass, so a {{Name}} text inside of a value is never
        replaced again. A token without a value is replaced with an empty string

        The values are NOT encoded, encode text values with ConvertTo-clNovaHtmlEncoded before
        adding them to the Token hashtable

        This is an internal helper function that is used by the public functions

    .PARAMETER Template
        The text with the {{Name}} tokens

    .PARAMETER Token
        Hashtable of token names & the values to replace them with

        Example:
            @{ Title = 'Report'; Body = '<p>Text</p>' }

    .EXAMPLE
        Expand-clNovaHtmlTemplate -Template '<h1>{{Title}}</h1>' -Token @{ Title = 'Report' }

        Returns <h1>Report</h1>

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/Internal/Expand-clNovaHtmlTemplate.html
#>

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Template,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Token
    )

    $Values = $Token

    $Evaluator = [System.Text.RegularExpressions.MatchEvaluator]{
        param ($Match)

        $Name = $Match.Groups[1].Value

        if ($Values.Contains($Name) -and $null -ne $Values[$Name]) { return [string]$Values[$Name] }

        return ''
    }

    return [regex]::Replace($Template, '\{\{(\w+)\}\}', $Evaluator)

}
