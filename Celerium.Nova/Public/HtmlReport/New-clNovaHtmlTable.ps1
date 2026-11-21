function New-clNovaHtmlTable {
<#
    .SYNOPSIS
        Creates the HTML of a sortable, searchable table card from PowerShell objects

    .DESCRIPTION
        The New-clNovaHtmlTable cmdlet converts PowerShell objects into the HTML of a table card
        for an HTML report

        The table
            - Can be sorted by clicking any column header (numbers, dates, & text are sorted correctly)
            - Can be searched & shows a configurable number of rows per page
            - Highlights the entire row when the mouse is over it
            - Scrolls sideways on small screens instead of breaking the page

        Only the properties in the Property parameter are shown (in that order). When it is not
        used the first 8 properties of the first object are shown so that the table fits on a typical
        monitor without a lot of horizontal scrolling

        All values are HTML encoded. The sorting, search, & paging are done by the script of the Celerium.Nova
        report (build\HtmlReport\js\Celerium.Nova.js) which New-clNovaHtmlReport adds to the page

    .PARAMETER InputObject
        The objects to show in the table, hashtables are also accepted

    .PARAMETER Property
        The names of the properties to show as columns

        By default the first 8 properties of the first object are used

    .PARAMETER ColumnName
        Hashtable of a property name & the column title to show for it

        Example:
            @{ OSVersion = 'OS Version'; EndOfSupport = 'End Of Support' }

    .PARAMETER StatusMap
        Colors the values of a column as a status badge

        Hashtable of a property name & a hashtable of values & colors

        Acceptable colors:
            'Primary','Success','Info','Warning','Danger','Secondary','Dark'

        Example:
            @{ Support = @{ Yes = 'Success'; 'Ending Soon' = 'Warning'; No = 'Danger' } }

    .PARAMETER Title
        The title shown in the header of the table card

    .PARAMETER Id
        The HTML id of the table

        Default value: psn-table

    .PARAMETER PageSize
        The number of rows shown per page, 0 shows all rows

        Default value: 10

    .PARAMETER Note
        Notes that are shown in a list below the table

    .PARAMETER DateFormat
        The format of date values

        Default value: yyyy-MM-dd HH:mm

    .PARAMETER ResourcePath
        The HtmlReport folder to read the templates from

        By default the folder of the module is used

    .EXAMPLE
        Get-Process | Select-Object -First 50 | New-clNovaHtmlTable -Property Name, Id, CPU -Title 'Processes'

        Returns the HTML of a table card that shows the Name, Id, & CPU of 50 processes

    .EXAMPLE
        $Data | New-clNovaHtmlTable -Property ComputerName, Support -StatusMap @{ Support = @{ Yes = 'Success'; No = 'Danger' } }

        Returns the HTML of a table where the Support column is shown as green & red badges

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlTable.html
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Only returns HTML text, nothing is changed')]
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [AllowNull()]
        [object[]]$InputObject,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Property,

        [Parameter(Mandatory = $false)]
        [System.Collections.IDictionary]$ColumnName,

        [Parameter(Mandatory = $false)]
        [System.Collections.IDictionary]$StatusMap,

        [Parameter(Mandatory = $false)]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [ValidatePattern('^[A-Za-z][A-Za-z0-9_-]*$')]
        [string]$Id = 'psn-table',

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100000)]
        [int]$PageSize = 10,

        [Parameter(Mandatory = $false)]
        [string[]]$Note,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$DateFormat = 'yyyy-MM-dd HH:mm',

        [Parameter(Mandatory = $false)]
        [string]$ResourcePath
    )

    begin {
        $Rows = [System.Collections.Generic.List[object]]::new()
    }

    process {
        foreach ($Item in $InputObject) {
            if ($null -eq $Item) { continue }
            if ($Item -is [System.Collections.IDictionary]) { $Item = [PSCustomObject]$Item }
            $Rows.Add($Item)
        }
    }

    end {

        $Culture        = [System.Globalization.CultureInfo]::InvariantCulture
        $Colors         = 'primary', 'success', 'info', 'warning', 'danger', 'secondary', 'dark'

        $Columns = $Property
        if (-not $Columns) {
            $Columns = if ($Rows.Count -gt 0) { @(@($Rows[0].PSObject.Properties.Name)[0..7] | Where-Object { $_ }) } else { @() }
        }

        # Headers
        $HeaderHtml = foreach ($Name in $Columns) {

            $Text = if ($ColumnName -and $ColumnName.Contains($Name)) { [string]$ColumnName[$Name] } else { $Name }

            '<th scope="col">{0}</th>' -f (ConvertTo-clNovaHtmlEncoded -InputObject $Text)

        }

        # Rows
        $RowHtml = [System.Text.StringBuilder]::new()

        foreach ($Row in $Rows) {

            [void]$RowHtml.Append('                                <tr>')

            foreach ($Name in $Columns) {

                $Member     = $Row.PSObject.Properties[$Name]
                $Value      = if ($Member) { $Member.Value } else { $null }
                $SortValue  = $null

                if ($Value -is [datetime]) {
                    $Text       = $Value.ToString($DateFormat, $Culture)
                    $SortValue  = $Value.ToString('yyyy-MM-ddTHH:mm:ss', $Culture)
                }
                elseif ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
                    $Text = (@($Value | ForEach-Object { "$_" }) -join '; ')
                }
                elseif ($null -eq $Value) { $Text = '' }
                else {
                    $Text = [string]::Format($Culture, '{0}', $Value)
                }

                $Encoded    = ConvertTo-clNovaHtmlEncoded -InputObject $Text
                $Color      = $null

                if ($StatusMap -and $StatusMap.Contains($Name) -and $StatusMap[$Name] -is [System.Collections.IDictionary] -and $Text -ne '' -and $StatusMap[$Name].Contains($Text)) {
                    $Color = ([string]$StatusMap[$Name][$Text]).ToLowerInvariant()
                    if ($Color -notin $Colors) { $Color = 'secondary' }
                    $Encoded = '<span class="psn-badge psn-c-{0}">{1}</span>' -f $Color, $Encoded
                }

                $SortAttribute = if ($null -ne $SortValue) { ' data-sort="{0}"' -f $SortValue } else { '' }

                [void]$RowHtml.Append('<td').Append($SortAttribute).Append('>').Append($Encoded).Append('</td>')

            }

            [void]$RowHtml.AppendLine('</tr>')

        }

        # Page size choices
        $Sizes = @(10, 25, 50, 0)
        if ($PageSize -notin $Sizes) { $Sizes = @($PageSize) + $Sizes | Sort-Object { if ($_ -eq 0) { [int]::MaxValue } else { $_ } } }

        $SizeOptions = foreach ($Size in $Sizes) {
            $Label = if ($Size -eq 0) { 'All' } else { "$Size" }
            '                                <option value="{0}"{1}>{2}</option>' -f $Size, $(if ($Size -eq $PageSize) { ' selected' } else { '' }), $Label
        }

        $HeaderCard = ''
        if ($Title) { $HeaderCard = '            <div class="card-header py-3">{0}</div>{1}' -f (ConvertTo-clNovaHtmlEncoded -InputObject $Title), "`n" }

        $NotesHtml = ''
        if ($Note) {
            $NotesHtml = '                <ul class="psn-table-notes">{0}{1}                </ul>{0}' -f "`n", ((@($Note | ForEach-Object { '                    <li>{0}</li>{1}' -f (ConvertTo-clNovaHtmlEncoded -InputObject $_), "`n" })) -join '')
        }

        $Template = Get-clNovaHtmlResource -Name 'templates/Table.html' -ResourcePath $ResourcePath

        $Tokens = @{
            Id                  = ConvertTo-clNovaHtmlEncoded -InputObject $Id
            CardHeader          = $HeaderCard
            PageSize            = $PageSize
            PageSizeOptions     = ($SizeOptions -join "`n")
            Headers             = ($HeaderHtml -join '')
            Rows                = $RowHtml.ToString().TrimEnd()
            Notes               = $NotesHtml
        }

        return (Expand-clNovaHtmlTemplate -Template $Template -Token $Tokens)

    }

}
