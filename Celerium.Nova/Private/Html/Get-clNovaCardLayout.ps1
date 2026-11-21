function Get-clNovaCardLayout {
<#
    .SYNOPSIS
        Calculates how many summary cards are placed in each row

    .DESCRIPTION
        The Get-clNovaCardLayout cmdlet calculates the number of summary cards per row so that
        every row has the same number of cards

            2 rows with 6 cards  -> 3 cards on the top row & 3 on the bottom row
            3 rows with 12 cards -> 4 cards on each of the 3 rows

        The number of rows is the minimum number of rows needed with the MaxPerRow limit. The cards
        per row is then the number of cards divided by the rows. When the cards can not be divided
        evenly (7 cards) the last row is shorter

        The layout is calculated for desktops (Xl), tablets (Md), & phones (Sm)

        This is an internal helper function that is used by the public functions

    .PARAMETER Count
        The number of summary cards

    .PARAMETER MaxPerRow
        The most cards that are allowed on one row of a desktop screen

        Default value: 4

    .PARAMETER MaxPerRowTablet
        The most cards that are allowed on one row of a tablet screen

        Default value: 2

    .EXAMPLE
        Get-clNovaCardLayout -Count 6

        Returns a layout of 2 rows with 3 cards per row for desktops

    .EXAMPLE
        Get-clNovaCardLayout -Count 12 -MaxPerRow 4

        Returns a layout of 3 rows with 4 cards per row for desktops

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/Internal/Get-clNovaCardLayout.html
#>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 1000)]
        [int]$Count,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 12)]
        [int]$MaxPerRow = 4,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 6)]
        [int]$MaxPerRowTablet = 2
    )

    function Get-clNovaEvenColumn {
        param (
            [int]$ItemCount,
            [int]$Limit
        )

        if ($ItemCount -le 0)       { return 1 }
        if ($ItemCount -le $Limit)  { return $ItemCount }

        $MinimumRows = [int][Math]::Ceiling($ItemCount / $Limit)

        # One more row than the minimum is allowed to find a layout where every row is full
        foreach ($Rows in $MinimumRows, ($MinimumRows + 1)) {
            if ($ItemCount % $Rows -eq 0 -and ($ItemCount / $Rows) -le $Limit) { return [int]($ItemCount / $Rows) }
        }

        return [int][Math]::Ceiling($ItemCount / $MinimumRows)
    }

    $Xl = Get-clNovaEvenColumn -ItemCount $Count -Limit $MaxPerRow
    $Md = Get-clNovaEvenColumn -ItemCount $Count -Limit $MaxPerRowTablet

    [PSCustomObject]@{
        Count       = $Count
        Xl          = $Xl
        Md          = $Md
        Sm          = 1
        Rows        = if ($Count -eq 0) { 0 } else { [int][Math]::Ceiling($Count / $Xl) }
    }

}
