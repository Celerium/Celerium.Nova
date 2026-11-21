function New-clNovaHtmlSummaryCard {
<#
    .SYNOPSIS
        Creates the HTML of one summary card

    .DESCRIPTION
        The New-clNovaHtmlSummaryCard cmdlet creates the HTML of a single summary card for an HTML
        report. A summary card shows one quick fact about the data in the report such as a
        total, a percentage, or a link

        A card can show a progress bar (Percent), a small note, an icon, & a tooltip. A card
        with a Url is a link

        The cards are placed on the page with New-clNovaHtmlSummaryCardSet which creates evenly
        filled rows of cards. The HTML needs the Celerium.Nova report css to look right, use
        New-clNovaHtmlReport to create a complete page

    .PARAMETER Title
        The title of the card

    .PARAMETER Value
        The main value of the card such as a total or text like [ 14 | 61% ]

    .PARAMETER Note
        A small line of text shown below the value

    .PARAMETER Percent
        Shows a progress bar that is filled with this percentage (0 - 100)

    .PARAMETER Color
        The color of the card border, title, & progress bar

        Acceptable values:
            'Primary','Success','Info','Warning','Danger','Secondary','Dark'

        Default value: Primary

    .PARAMETER Icon
        The name of a Bootstrap Icon to show on the card

        Default value: clipboard-data

        Icons that can be used are listed in build\HtmlReport\resources.json

    .PARAMETER Tooltip
        The text that is shown when the mouse is over the card

    .PARAMETER Url
        Makes the card a link. Only http, https, mailto, & page (#) links are allowed

    .PARAMETER ResourcePath
        The HtmlReport folder to read the templates & icons from

        By default the folder of the module is used

    .EXAMPLE
        New-clNovaHtmlSummaryCard -Title 'Total Computers' -Value 23 -Icon 'laptop' -Color Primary

        Returns the HTML of a card that shows the total number of computers

    .EXAMPLE
        New-clNovaHtmlSummaryCard -Title 'Supported' -Value '14 | 61%' -Percent 61 -Color Success -Icon 'check-circle-fill' -Tooltip 'Systems Microsoft supports'

        Returns the HTML of a card with a progress bar that is 61% full

    .EXAMPLE
        New-clNovaHtmlSummaryCard -Title 'Microsoft Lifecycles' -Value 'learn.microsoft.com' -Url 'https://learn.microsoft.com/en-us/lifecycle/products/' -Color Info

        Returns the HTML of a card that opens the Microsoft lifecycle pages

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlSummaryCard.html
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Only returns HTML text, nothing is changed')]
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [object]$Value,

        [Parameter(Mandatory = $false)]
        [string]$Note,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [double]$Percent,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Primary', 'Success', 'Info', 'Warning', 'Danger', 'Secondary', 'Dark')]
        [string]$Color = 'Primary',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Icon = 'clipboard-data',

        [Parameter(Mandatory = $false)]
        [string]$Tooltip,

        [Parameter(Mandatory = $false)]
        [ValidatePattern('^(https?://|mailto:|#|\./|/)')]
        [string]$Url,

        [Parameter(Mandatory = $false)]
        [string]$ResourcePath
    )

    $Template = Get-clNovaHtmlResource -Name 'templates/SummaryCard.html' -ResourcePath $ResourcePath

    $TitleHtml = ConvertTo-clNovaHtmlEncoded -InputObject $Title
    if ($Url) {
        $TitleHtml = '<a class="stretched-link" href="{0}" target="_blank" rel="noopener noreferrer">{1}</a>' -f (ConvertTo-clNovaHtmlEncoded -InputObject $Url), $TitleHtml
    }

    $ProgressHtml = ''
    if ($PSBoundParameters.ContainsKey('Percent')) {
        $Width        = [Math]::Round($Percent, 1).ToString([System.Globalization.CultureInfo]::InvariantCulture)
        $ProgressHtml = '                            <div class="progress mt-2" role="progressbar" aria-label="{0}" aria-valuenow="{1}" aria-valuemin="0" aria-valuemax="100"><div class="progress-bar" style="width: {1}%"></div></div>{2}' -f (ConvertTo-clNovaHtmlEncoded -InputObject $Title), $Width, "`n"
    }

    $NoteHtml = ''
    if ($Note) {
        $NoteHtml = '                            <div class="psn-card-note mt-1">{0}</div>{1}' -f (ConvertTo-clNovaHtmlEncoded -InputObject $Note), "`n"
    }

    $TooltipAttribute = ''
    if ($Tooltip) { $TooltipAttribute = ' title="{0}"' -f (ConvertTo-clNovaHtmlEncoded -InputObject $Tooltip) }

    $Tokens = @{
        ColorClass          = 'psn-c-' + $Color.ToLowerInvariant()
        TooltipAttribute    = $TooltipAttribute
        Title               = $TitleHtml
        Value               = ConvertTo-clNovaHtmlEncoded -InputObject $Value
        Progress            = $ProgressHtml
        Note                = $NoteHtml
        Icon                = Get-clNovaHtmlIcon -Name $Icon -ResourcePath $ResourcePath
    }

    return (Expand-clNovaHtmlTemplate -Template $Template -Token $Tokens)

}
