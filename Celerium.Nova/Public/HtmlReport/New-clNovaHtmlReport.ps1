function New-clNovaHtmlReport {
<#
    .SYNOPSIS
        Creates a modern, mobile friendly HTML report from PowerShell objects

    .DESCRIPTION
        The New-clNovaHtmlReport cmdlet turns any PowerShell objects into a single HTML file with
        a dark sidebar & header, an off white body, summary cards, & a sortable, searchable table

        The design is based on SB Admin 2 (ported to Bootstrap 5.3) & works on desktops
        (Windows, Linux, & macOS) as well as on Android & iOS phones & tablets

        By default everything needed (Bootstrap, the theme, the icons, & the scripts) is embedded in the
        file so the report works offline. Use -ResourceMode Cdn to link the Bootstrap 5.3 CDN files instead
        which makes the file smaller

        The pieces of the report are also available as separate functions which can be used to build
        other reports
            - New-clNovaHtmlSummaryCardSet & New-clNovaHtmlSummaryCard
            - New-clNovaHtmlTable

    .PARAMETER InputObject
        The objects shown in the table of the report

    .PARAMETER Path
        The file to save the report to. The folder is created when it does not exist

        When it is not used the HTML text is returned instead

    .PARAMETER Title
        The title of the report, shown in the header, the page title, & as the heading

    .PARAMETER Subtitle
        A line of text shown next to the heading such as where the data came from

    .PARAMETER Property
        The properties shown as table columns

        By default the first 8 properties of the first object are used

    .PARAMETER ColumnName
        Hashtable of a property name & the column title to show for it

    .PARAMETER StatusMap
        Colors the values of a column as a status badge, see New-clNovaHtmlTable

        Example:
            @{ Support = @{ Yes = 'Success'; 'Ending Soon' = 'Warning'; No = 'Danger' } }

    .PARAMETER SummaryCard
        The summary cards shown above the table. Hashtables or objects with the properties of
        New-clNovaHtmlSummaryCard (Title, Value, Note, Percent, Color, Icon, Tooltip, & Url)

        The cards are laid out in rows that all have the same number of cards

    .PARAMETER MaxCardsPerRow
        The most summary cards on one row of a desktop screen

        Default value: 4

    .PARAMETER TableTitle
        The title shown in the header of the table

    .PARAMETER TableNote
        Notes shown in a list below the table

    .PARAMETER PageSize
        The number of table rows shown per page, 0 shows all rows

        Default value: 10

    .PARAMETER NavigationItem
        The links of the sidebar. Hashtables or objects with the properties Text, Url, Icon, & Heading

        Items with the same Heading are grouped under it. By default links to the summary & the table are shown

        Example:
            @{ Heading = 'Help'; Text = 'Documentation'; Url = 'https://celerium.org'; Icon = 'info-circle' }

    .PARAMETER BrandText
        The name shown at the top of the sidebar

        Default value: Celerium.Nova

    .PARAMETER BrandIcon
        The name of the Bootstrap Icon shown next to the name at the top of the sidebar

        Default value: speedometer2

    .PARAMETER BrandLogoPath
        The path of a logo image (png, jpg, gif, svg, or webp) that replaces the icon & the name at the top of the sidebar

        The logo is embedded in the report, so it is also shown when the computer is offline. The icon & the name
        are used as the alternative text. When the sidebar is collapsed only the left part (the symbol) of the logo is shown
        unless BrandLogoCollapsedPath is used

    .PARAMETER BrandLogoCollapsedPath
        The path of the logo image that is shown at the top of the sidebar when the sidebar is collapsed

        Only used with BrandLogoPath. BrandLogoPath is shown when the sidebar is expanded. A square image works best

    .PARAMETER FaviconPath
        The path of the icon (ico, png, or svg) that is shown on the browser tab

        The icon is embedded in the report. By default an icon of BrandIcon is used
    .PARAMETER BrandUrl
        The link of the name at the top of the sidebar

        Default value: #

    .PARAMETER Description
        The description meta tag of the page

    .PARAMETER Author
        The author meta tag of the page

    .PARAMETER Footer
        Text shown at the bottom of the page

        By default no footer is shown

    .PARAMETER ResourceMode
        How Bootstrap is added to the report

        Acceptable values:
            'Embedded','Cdn'

        Embedded places the files in the report so it works offline (default). Cdn links the Bootstrap 5.3
        files of the jsDelivr CDN, an internet connection is needed to view the report

    .PARAMETER ResourcePath
        The HtmlReport folder to read the templates, css, js, & icons from

        By default the folder of the module is used. Use this to change the look of the report

    .EXAMPLE
        Get-Service | New-clNovaHtmlReport -Title 'Services' -Property Name, Status, StartType -Path .\Services.html

        Creates an HTML report of the services & saves it to Services.html

    .EXAMPLE
        $Cards = @(
            @{ Title = 'Running'; Value = 120; Color = 'Success'; Icon = 'check-circle-fill' }
            @{ Title = 'Stopped'; Value = 80; Color = 'Danger'; Icon = 'x-circle-fill' }
        )
        $Services | New-clNovaHtmlReport -Title 'Services' -SummaryCard $Cards -StatusMap @{ Status = @{ Running = 'Success'; Stopped = 'Danger' } } -Path .\Services.html

        Creates a report with 2 summary cards & colors the Status column

    .EXAMPLE
        $Html = Get-Process | New-clNovaHtmlReport -Title 'Processes' -ResourceMode Cdn

        Returns the HTML text of a report that links to the Bootstrap CDN files

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Nova/site/HtmlReport/New-clNovaHtmlReport.html
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string], [System.IO.FileInfo])]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [AllowNull()]
        [object[]]$InputObject,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Title = 'Celerium.Nova Report',

        [Parameter(Mandatory = $false)]
        [string]$Subtitle,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Property,

        [Parameter(Mandatory = $false)]
        [System.Collections.IDictionary]$ColumnName,

        [Parameter(Mandatory = $false)]
        [System.Collections.IDictionary]$StatusMap,

        [Parameter(Mandatory = $false)]
        [object[]]$SummaryCard,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 12)]
        [int]$MaxCardsPerRow = 4,

        [Parameter(Mandatory = $false)]
        [string]$TableTitle,

        [Parameter(Mandatory = $false)]
        [string[]]$TableNote,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100000)]
        [int]$PageSize = 10,

        [Parameter(Mandatory = $false)]
        [object[]]$NavigationItem,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$BrandText = 'Celerium.Nova',

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$BrandIcon = 'speedometer2',

        [Parameter(Mandatory = $false)]
        [string]$BrandLogoPath,

        [Parameter(Mandatory = $false)]
        [string]$BrandLogoCollapsedPath,

        [Parameter(Mandatory = $false)]
        [string]$FaviconPath,

        [Parameter(Mandatory = $false)]
        [ValidatePattern('^(https?://|mailto:|#|\./|/)')]
        [string]$BrandUrl = '#',

        [Parameter(Mandatory = $false)]
        [string]$Description,

        [Parameter(Mandatory = $false)]
        [string]$Author = 'Celerium.Nova',

        [Parameter(Mandatory = $false)]
        [string]$Footer,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Embedded', 'Cdn')]
        [string]$ResourceMode = 'Embedded',

        [Parameter(Mandatory = $false)]
        [string]$ResourcePath
    )

    begin {
        $Rows = [System.Collections.Generic.List[object]]::new()
    }

    process {
        foreach ($Item in $InputObject) { if ($null -ne $Item) { $Rows.Add($Item) } }
    }

    end {

        $Culture        = [System.Globalization.CultureInfo]::InvariantCulture
        $GeneratedAt    = [datetime]::Now.ToString('yyyy-MM-dd h:mmtt', $Culture).ToLowerInvariant()
        $ModuleVersion  = $null
        $LoadedModule   = @(Get-Module -Name Celerium.Nova)[0]
        if ($LoadedModule) { $ModuleVersion = $LoadedModule.Version.ToString() }
        $Generator      = if ($ModuleVersion) { "Celerium.Nova $ModuleVersion" } else { 'Celerium.Nova' }

        $Resources      = Get-clNovaHtmlResource -Name 'resources.json' -ResourcePath $ResourcePath | ConvertFrom-Json

        #Region     [ Resources ]

        $RemoveSourceMap = { param ([string]$Text) [regex]::Replace($Text, '(?m)^\s*(/\*#|//#) sourceMappingURL=.*$', '') }

        if ($ResourceMode -eq 'Cdn') {
            $BootstrapCss   = '    <link rel="stylesheet" href="{0}" integrity="{1}" crossorigin="anonymous">' -f $Resources.Bootstrap.Css.Cdn, $Resources.Bootstrap.Css.Integrity
            $BootstrapJs    = '    <script src="{0}" integrity="{1}" crossorigin="anonymous"></script>' -f $Resources.Bootstrap.Js.Cdn, $Resources.Bootstrap.Js.Integrity
        }
        else {
            $BootstrapCss   = "    <style>`n{0}`n    </style>" -f (& $RemoveSourceMap (Get-clNovaHtmlResource -Name $Resources.Bootstrap.Css.File -ResourcePath $ResourcePath)).Trim()
            $BootstrapJs    = "    <script>`n{0}`n    </script>" -f (& $RemoveSourceMap (Get-clNovaHtmlResource -Name $Resources.Bootstrap.Js.File -ResourcePath $ResourcePath)).Trim()
        }

        $Css = (Get-clNovaHtmlResource -Name 'css/Celerium.Nova.css' -ResourcePath $ResourcePath).Trim()
        $Js  = (Get-clNovaHtmlResource -Name 'js/Celerium.Nova.js' -ResourcePath $ResourcePath).Trim()

        # The favicon is embedded as well, an svg favicon of the brand icon is used when there is no FaviconPath
        $FaviconHtml = ''
        $BrandSvg    = Get-clNovaHtmlIcon -Name $BrandIcon -ResourcePath $ResourcePath
        if ($FaviconPath) {
            $FaviconUri  = ConvertTo-clNovaHtmlDataUri -Path $FaviconPath
            $FaviconHtml = '    <link rel="icon" href="{0}">' -f $FaviconUri
        }
        elseif ($BrandSvg) {
            $FaviconSvg  = [regex]::Replace($BrandSvg, 'fill="currentColor"', 'fill="#212529"')
            $FaviconHtml = '    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml;base64,{0}">' -f [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($FaviconSvg))
        }

        #EndRegion  [ Resources ]

        #Region     [ Summary cards & table ]

        $CardsHtml = ''
        if ($SummaryCard) {
            $CardsHtml = New-clNovaHtmlSummaryCardSet -Card $SummaryCard -MaxPerRow $MaxCardsPerRow -ResourcePath $ResourcePath
        }

        $TableParameters = @{
            Title       = $TableTitle
            Id          = 'psn-table'
            PageSize    = $PageSize
            Note        = $TableNote
        }
        if ($ResourcePath)  { $TableParameters['ResourcePath'] = $ResourcePath }
        if ($Property)      { $TableParameters['Property'] = $Property }
        if ($ColumnName)    { $TableParameters['ColumnName'] = $ColumnName }
        if ($StatusMap)     { $TableParameters['StatusMap'] = $StatusMap }

        $TableHtml = New-clNovaHtmlTable -InputObject $Rows.ToArray() @TableParameters

        #EndRegion  [ Summary cards & table ]

        #Region     [ Sidebar ]

        if (-not $NavigationItem) {

            $NavigationItem = @()
            if ($CardsHtml) { $NavigationItem += @{ Heading = 'Report'; Text = 'Summary'; Url = '#psn-summary'; Icon = 'speedometer2' } }
            $NavigationItem += @{ Heading = 'Report'; Text = 'Data'; Url = '#psn-table-card'; Icon = 'table' }

        }

        $NavigationHtml     = [System.Text.StringBuilder]::new()
        $PreviousHeading    = $null

        foreach ($Item in $NavigationItem) {

            $ItemValues = @{ Text = $null; Url = '#'; Icon = 'info-circle'; Heading = $null }

            foreach ($Name in 'Text', 'Url', 'Icon', 'Heading') {

                $ItemValue = $null
                if ($Item -is [System.Collections.IDictionary]) { if ($Item.Contains($Name)) { $ItemValue = $Item[$Name] } }
                elseif ($Item.PSObject.Properties[$Name])       { $ItemValue = $Item.PSObject.Properties[$Name].Value }

                if ($ItemValue) { $ItemValues[$Name] = [string]$ItemValue }

            }

            $ItemText       = $ItemValues['Text']
            $ItemUrl        = $ItemValues['Url']
            $ItemIcon       = $ItemValues['Icon']
            $ItemHeading    = $ItemValues['Heading']

            if (-not $ItemText) { continue }
            if ($ItemUrl -notmatch '^(https?://|mailto:|#|\./|/)') { $ItemUrl = '#' }

            if ($ItemHeading -and $ItemHeading -ne $PreviousHeading) {
                [void]$NavigationHtml.AppendLine(('                    <div class="psn-sidebar-heading">{0}</div>' -f (ConvertTo-clNovaHtmlEncoded -InputObject $ItemHeading)))
                $PreviousHeading = $ItemHeading
            }

            $External   = if ($ItemUrl -match '^https?://') { ' target="_blank" rel="noopener noreferrer"' } else { '' }
            $EncodedText = ConvertTo-clNovaHtmlEncoded -InputObject $ItemText

            [void]$NavigationHtml.AppendLine(('                    <a class="nav-link" href="{0}"{1} title="{2}">{3}<span class="psn-sidebar-text">{2}</span></a>' -f (ConvertTo-clNovaHtmlEncoded -InputObject $ItemUrl), $External, $EncodedText, (Get-clNovaHtmlIcon -Name $ItemIcon -ResourcePath $ResourcePath)))

        }

        $SidebarTemplate = Get-clNovaHtmlResource -Name 'templates/Sidebar.html' -ResourcePath $ResourcePath

        $BrandContent = '{0}{1}                    <span class="psn-sidebar-text">{2}</span>' -f $BrandSvg, "`n", (ConvertTo-clNovaHtmlEncoded -InputObject $BrandText)

        if ($BrandLogoPath) {

            # The logos are embedded in the page so they are also shown when the computer is offline
            $LogoAlt  = ConvertTo-clNovaHtmlEncoded -InputObject $BrandText
            $LogoData = ConvertTo-clNovaHtmlDataUri -Path $BrandLogoPath

            if ($BrandLogoCollapsedPath) {
                $CollapsedData = ConvertTo-clNovaHtmlDataUri -Path $BrandLogoCollapsedPath
                $BrandContent  = '<img class="psn-brand-logo psn-brand-logo-expanded" src="{0}" alt="{2}">{3}                    <img class="psn-brand-logo-collapsed" src="{1}" alt="{2}">' -f $LogoData, $CollapsedData, $LogoAlt, "`n"
            }
            else {
                $BrandContent  = '<img class="psn-brand-logo" src="{0}" alt="{1}">' -f $LogoData, $LogoAlt
            }

        }

        $SidebarHtml = Expand-clNovaHtmlTemplate -Template $SidebarTemplate -Token @{
            BrandUrl            = ConvertTo-clNovaHtmlEncoded -InputObject $BrandUrl
            BrandText           = ConvertTo-clNovaHtmlEncoded -InputObject $BrandText
            BrandContent        = $BrandContent
            NavigationItems     = $NavigationHtml.ToString().TrimEnd()
            FooterLabel         = 'Generated At:'
            FooterValue         = ConvertTo-clNovaHtmlEncoded -InputObject $GeneratedAt
        }

        #EndRegion  [ Sidebar ]

        $TopbarTemplate = Get-clNovaHtmlResource -Name 'templates/Topbar.html' -ResourcePath $ResourcePath

        $TopbarHtml = Expand-clNovaHtmlTemplate -Template $TopbarTemplate -Token @{
            ToggleIcon  = Get-clNovaHtmlIcon -Name 'list' -ResourcePath $ResourcePath
        }

        $FooterHtml = ''
        if ($Footer) { $FooterHtml = '            <footer class="psn-footer">{0}</footer>' -f (ConvertTo-clNovaHtmlEncoded -InputObject $Footer) }

        $PageTemplate = Get-clNovaHtmlResource -Name 'templates/Page.html' -ResourcePath $ResourcePath

        $Html = Expand-clNovaHtmlTemplate -Template $PageTemplate -Token @{
            Description     = ConvertTo-clNovaHtmlEncoded -InputObject $(if ($Description) { $Description } else { $Title })
            Author          = ConvertTo-clNovaHtmlEncoded -InputObject $Author
            Generator       = ConvertTo-clNovaHtmlEncoded -InputObject $Generator
            Title           = ConvertTo-clNovaHtmlEncoded -InputObject $Title
            Heading         = ConvertTo-clNovaHtmlEncoded -InputObject $Title
            Subtitle        = ConvertTo-clNovaHtmlEncoded -InputObject $Subtitle
            Favicon         = $FaviconHtml
            BootstrapCss    = $BootstrapCss
            BootstrapJs     = $BootstrapJs
            Css             = $Css
            Js              = $Js
            Sidebar         = $SidebarHtml
            Topbar          = $TopbarHtml
            SummaryCards    = $CardsHtml
            Body            = $TableHtml
            Footer          = $FooterHtml
        }

        if (-not $Path) { return $Html }

        $FullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

        if ($PSCmdlet.ShouldProcess($FullPath, 'Create the HTML report')) {

            $Folder = Split-Path -Path $FullPath -Parent
            if ($Folder -and -not (Test-Path -Path $Folder -PathType Container)) { New-Item -Path $Folder -ItemType Directory -Force > $null }

            [System.IO.File]::WriteAllText($FullPath, $Html, [System.Text.UTF8Encoding]::new($false))

            return (Get-Item -Path $FullPath)

        }

    }

}
