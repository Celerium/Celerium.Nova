function ConvertTo-clNovaHtmlEncoded {
<#
    .SYNOPSIS
        Encodes text so that it can safely be placed in HTML

    .DESCRIPTION
        The ConvertTo-clNovaHtmlEncoded cmdlet HTML encodes the string value of an object so that
        characters such as < > & " ' are shown as text & can not change the HTML of a report

        A null value returns an empty string

        This is an internal helper function that is used by the public functions

    .PARAMETER InputObject
        The value to encode, the string value of the object is encoded

    .EXAMPLE
        ConvertTo-clNovaHtmlEncoded -InputObject '<b>Server & Client</b>'

        Returns &lt;b&gt;Server &amp; Client&lt;/b&gt;

    .EXAMPLE
        'DC01', 'A&B' | ConvertTo-clNovaHtmlEncoded

        Returns the encoded value of every item sent down the pipeline

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/Internal/ConvertTo-clNovaHtmlEncoded.html
#>

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 0)]
        [AllowNull()]
        [AllowEmptyString()]
        [object]$InputObject
    )

    process {

        if ($null -eq $InputObject) { return '' }

        [System.Net.WebUtility]::HtmlEncode([string]$InputObject)

    }

}
