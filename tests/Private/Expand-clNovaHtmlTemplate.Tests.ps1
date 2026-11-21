<#
.NOTES
    Copyright 1990-2025 Celerium

    NAME: Expand-clNovaHtmlTemplate.Tests.ps1
    Type: PowerShell

        AUTHOR:  David Schulte
        EMAIL:   celerium@Celerium.org

.SYNOPSIS
    Pester tests for the internal HTML report helper functions

.DESCRIPTION
    Pester tests for Expand-clNovaHtmlTemplate, ConvertTo-clNovaHtmlEncoded, Get-clNovaHtmlIcon,
    Get-clNovaHtmlResource, & Get-clNovaResourcePath

.PARAMETER ModuleName
    The name of the local module to import

    Default value: Celerium.Nova

.PARAMETER Version
    The version of the local module to import

.PARAMETER BuildTarget
    Which version of the module to run tests against

    Allowed values:
        'built', 'notBuilt'

.EXAMPLE
    Invoke-Pester -Path .\Expand-clNovaHtmlTemplate.Tests.ps1

.INPUTS
    N/A

.OUTPUTS
    N/A

.LINK
    https://celerium.org

#>

<############################################################################################
                                        Code
############################################################################################>
#Requires -Version 5.1
#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='6.0.0' }

#Region     [ Parameters ]

#Available in Discovery & Run
[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ModuleName = 'Celerium.Nova',

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [ValidateSet('built', 'notBuilt')]
    [string]$BuildTarget
)

#EndRegion  [ Parameters ]

#Region     [ Prerequisites ]

    BeforeDiscovery {

        $PesterTestName = (Get-Item -Path $PSCommandPath).Name

        $ResourceCases = @(
            @{ Name = 'templates/Page.html' }
            @{ Name = 'templates/Sidebar.html' }
            @{ Name = 'templates/Topbar.html' }
            @{ Name = 'templates/SummaryCard.html' }
            @{ Name = 'templates/Table.html' }
            @{ Name = 'css/Celerium.Nova.css' }
            @{ Name = 'js/Celerium.Nova.js' }
            @{ Name = 'resources.json' }
            @{ Name = 'logo/logo.png' }
            @{ Name = 'logo/logo-collapse.png' }
            @{ Name = 'logo/logo.ico' }
            @{ Name = 'vendor/bootstrap/bootstrap.min.css' }
            @{ Name = 'vendor/bootstrap/bootstrap.bundle.min.js' }
        )

    }

    BeforeAll {

        $TestsPath = $PSScriptRoot
        while ($TestsPath -and -not (Test-Path -Path (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1'))) { $TestsPath = Split-Path -Path $TestsPath -Parent }
        . (Join-Path -Path $TestsPath -ChildPath 'TestHelper.ps1')

        Import-TestModule -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget

    }

    AfterAll {
        Remove-TestModule -ModuleName $ModuleName
    }

#EndRegion  [ Prerequisites ]

Describe "Testing the [ $BuildTarget ] version of [ $ModuleName ] with [ $PesterTestName ]" {

    Context "[ Expand-clNovaHtmlTemplate ] replacing tokens" {

        It "Replaces every {{Name}} token" {
            Expand-clNovaHtmlTemplate -Template '<h1>{{Title}}</h1><p>{{Body}}</p>' -Token @{ Title = 'A'; Body = 'B' } | Should -Be '<h1>A</h1><p>B</p>'
        }

        It "Replaces a token that is used more than once" {
            Expand-clNovaHtmlTemplate -Template '{{Name}}-{{Name}}' -Token @{ Name = 'x' } | Should -Be 'x-x'
        }

        It "Replaces a token without a value with an empty string" {
            Expand-clNovaHtmlTemplate -Template 'a{{Missing}}b' -Token @{ Other = 'x' } | Should -Be 'ab'
        }

        It "Does not replace a token that is part of a value" {
            Expand-clNovaHtmlTemplate -Template '{{First}}{{Second}}' -Token @{ First = '{{Second}}'; Second = 'x' } | Should -Be '{{Second}}x'
        }

        It "Keeps dollar signs & backslashes of a value" {
            Expand-clNovaHtmlTemplate -Template '{{Value}}' -Token @{ Value = 'C:\Temp $1 $&' } | Should -Be 'C:\Temp $1 $&'
        }

    }

    Context "[ ConvertTo-clNovaHtmlEncoded ] encoding text" {

        It "Encodes the characters that can change HTML" {
            ConvertTo-clNovaHtmlEncoded -InputObject '<script>alert("x") & ''y''</script>' | Should -Not -Match '[<>"]'
            ConvertTo-clNovaHtmlEncoded -InputObject 'A & B' | Should -Be 'A &amp; B'
        }

        It "Returns an empty string for a null value" {
            ConvertTo-clNovaHtmlEncoded -InputObject $null | Should -BeExactly ''
        }

        It "Encodes the string value of an object" {
            ConvertTo-clNovaHtmlEncoded -InputObject 42 | Should -Be '42'
        }

        It "Encodes every item of the pipeline" {
            @('a<b', 'c>d') | ConvertTo-clNovaHtmlEncoded | Should -Be @('a&lt;b', 'c&gt;d')
        }

    }

    Context "[ Get-clNovaResourcePath & Get-clNovaHtmlResource ] report resources" {

        It "Finds the resource [ <Name> ]" -ForEach $ResourceCases {
            (Get-clNovaHtmlResource -Name $Name) | Should -Not -BeNullOrEmpty
        }

        It "Writes an error when a resource does not exist" {
            { Get-clNovaHtmlResource -Name 'templates/DoesNotExist.html' } | Should -Throw
        }

        It "Reads the resources of another folder when ResourcePath is used" {
            $Folder = Join-Path -Path $TestDrive -ChildPath 'Custom'
            New-Item -Path (Join-Path -Path $Folder -ChildPath 'templates') -ItemType Directory -Force > $null
            Set-Content -Path (Join-Path -Path $Folder -ChildPath 'templates/Page.html') -Value 'custom page' -NoNewline

            Get-clNovaHtmlResource -Name 'templates/Page.html' -ResourcePath $Folder | Should -Be 'custom page'
        }

        It "Lists the Bootstrap version & CDN links in resources.json" {
            $Resources = Get-clNovaHtmlResource -Name 'resources.json' | ConvertFrom-Json

            [version]$Resources.Bootstrap.Version | Should -BeGreaterOrEqual ([version]'5.3.0')
            $Resources.Bootstrap.Css.Cdn | Should -Match '^https://.*bootstrap@5\.3'
            $Resources.Bootstrap.Css.Integrity | Should -Match '^sha384-'
            $Resources.Bootstrap.Js.Integrity | Should -Match '^sha384-'
        }

    }

    Context "[ Get-clNovaHtmlIcon ] inline icons" {

        It "Returns an inline svg that is hidden from screen readers" {
            $Svg = Get-clNovaHtmlIcon -Name 'server'

            $Svg | Should -Match '^<svg'
            $Svg | Should -Match 'psn-icon'
            $Svg | Should -Match 'aria-hidden="true"'
        }

        It "Returns the info icon for an icon that does not exist" {
            Get-clNovaHtmlIcon -Name 'does-not-exist' | Should -Be (Get-clNovaHtmlIcon -Name 'info-circle')
        }

        It "Does not read a file outside of the icons folder" {
            Get-clNovaHtmlIcon -Name '../templates/Page' | Should -Be (Get-clNovaHtmlIcon -Name 'info-circle')
        }

    }

}
