function New-clNovaHtmlSummaryCardSet {
<#
    .SYNOPSIS
        Creates the HTML of a group of summary cards that are laid out in evenly filled rows

    .DESCRIPTION
        The New-clNovaHtmlSummaryCardSet cmdlet creates the HTML of any number of summary cards &
        scales the layout to fit them. Every row has the same number of cards

            6 cards  -> 2 rows of 3 cards
            12 cards -> 3 rows of 4 cards

        At most MaxPerRow cards are placed on one row of a desktop screen, tablets show 2 cards per
        row, & phones show 1 card per row. A row that can not be filled evenly (for example 7 cards)
        is centered

        Every card is defined by a hashtable or an object with the same properties as the
        parameters of New-clNovaHtmlSummaryCard (Title, Value, Note, Percent, Color, Icon, Tooltip, & Url)

    .PARAMETER Card
        One or more cards, hashtables or objects with the properties of New-clNovaHtmlSummaryCard

        Example:
            @{ Title = 'Total'; Value = 23; Icon = 'laptop' }

    .PARAMETER MaxPerRow
        The most cards that are placed on one row of a desktop screen

        Default value: 4

    .PARAMETER Id
        The HTML id of the group, can be used as an anchor (#psn-summary)

        Default value: psn-summary

    .PARAMETER ResourcePath
        The HtmlReport folder to read the templates & icons from

        By default the folder of the module is used

    .EXAMPLE
        $Cards = 1..6 | ForEach-Object { @{ Title = "Card $_"; Value = $_ } }
        New-clNovaHtmlSummaryCardSet -Card $Cards

        Returns the HTML of 6 cards placed on 2 rows with 3 cards on each row

    .EXAMPLE
        $Cards = @(
            @{ Title = 'Supported'; Value = '14 | 61%'; Percent = 61; Color = 'Success'; Icon = 'check-circle-fill' }
            [PSCustomObject]@{ Title = 'Total'; Value = 23; Icon = 'laptop' }
        )
        $Cards | New-clNovaHtmlSummaryCardSet -MaxPerRow 6

        Returns the HTML of 2 cards, cards can be sent down the pipeline

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlSummaryCardSet.html
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Only returns HTML text, nothing is changed')]
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [object[]]$Card,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 12)]
        [int]$MaxPerRow = 4,

        [Parameter(Mandatory = $false)]
        [ValidatePattern('^[A-Za-z][A-Za-z0-9_-]*$')]
        [string]$Id = 'psn-summary',

        [Parameter(Mandatory = $false)]
        [string]$ResourcePath
    )

    begin {
        $AllCards = [System.Collections.Generic.List[object]]::new()
    }

    process {
        foreach ($Item in $Card) { if ($null -ne $Item) { $AllCards.Add($Item) } }
    }

    end {

        if ($AllCards.Count -eq 0) { return '' }

        $CardParameters = 'Title', 'Value', 'Note', 'Percent', 'Color', 'Icon', 'Tooltip', 'Url'

        $CardHtml = foreach ($Item in $AllCards) {

            $Splat = @{}

            foreach ($Name in $CardParameters) {

                $Property = $null

                if ($Item -is [System.Collections.IDictionary]) { if ($Item.Contains($Name)) { $Property = $Item[$Name] } else { continue } }
                elseif ($Item.PSObject.Properties[$Name])       { $Property = $Item.PSObject.Properties[$Name].Value }
                else                                            { continue }

                if ($null -ne $Property -and "$Property" -ne '' -or $Name -eq 'Value') { $Splat[$Name] = $Property }

            }

            if (-not $Splat.ContainsKey('Value')) { $Splat['Value'] = '' }
            if ($ResourcePath) { $Splat['ResourcePath'] = $ResourcePath }

            New-clNovaHtmlSummaryCard @Splat

        }

        $Layout = Get-clNovaCardLayout -Count $AllCards.Count -MaxPerRow $MaxPerRow

        $Style = '--psn-cols-xl: {0}; --psn-cols-md: {1}; --psn-cols-sm: {2};' -f $Layout.Xl, $Layout.Md, $Layout.Sm

        return ('        <section class="psn-card-grid" id="{0}" style="{1}" data-psn-cards="{2}" data-psn-rows="{3}" aria-label="Summary">{4}{5}{4}        </section>{4}' -f (ConvertTo-clNovaHtmlEncoded -InputObject $Id), $Style, $Layout.Count, $Layout.Rows, "`n", ($CardHtml -join ''))

    }

}
