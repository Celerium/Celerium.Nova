# Shared helpers for the Celerium.Nova Pester tests
# This file is dot-sourced by each test file & is not a test file itself

function Get-TestRootPath {
    # The tests folder lives directly under the repository root
    return (Split-Path -Path $PSScriptRoot -Parent)
}

function Get-TestModulePath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,

        [Parameter(Mandatory = $true)]
        [string]$Version,

        [Parameter(Mandatory = $true)]
        [ValidateSet('built', 'notBuilt')]
        [string]$BuildTarget
    )

    $RootPath = Get-TestRootPath

    switch ($BuildTarget) {
        'built'     { return Join-Path -Path (Join-Path -Path (Join-Path -Path $RootPath -ChildPath 'build') -ChildPath $ModuleName) -ChildPath $Version }
        'notBuilt'  { return Join-Path -Path $RootPath -ChildPath $ModuleName }
    }
}

function Get-TestMockModuleName {
    <#
        Returns the name of the module that defines a command, this is the value to use with [ Mock -ModuleName ]

        Nested .ps1 files of the notBuilt module are dot-sourced into the root module & the built module is a single
        psm1, so both targets resolve to the root module. Resolving it per command keeps the tests correct
        if the module layout ever changes. Aliases are resolved to the command they point at
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$CommandName
    )

    $Command = Get-Command -Name $CommandName -ErrorAction Stop | Select-Object -First 1
    if ($Command.CommandType -eq 'Alias') { $Command = $Command.ResolvedCommand }

    return $Command.ModuleName
}

function Remove-TestState {
    # Removes the global variables the tests create. Mock bodies share data with the test through global variables
    # that start with CeleriumNovaTest
    $TestVariables = @(Get-Variable -Scope Global -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^CeleriumNovaTest\w*$' })

    foreach ($TestVariable in $TestVariables) {
        Remove-Variable -Name $TestVariable.Name -Scope Global -Force -ErrorAction SilentlyContinue
    }
}

function Import-TestModule {
    # Imports the module that is being tested
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,

        [Parameter(Mandatory = $true)]
        [string]$Version,

        [Parameter(Mandatory = $true)]
        [ValidateSet('built', 'notBuilt')]
        [string]$BuildTarget
    )

    $ModulePath = Get-TestModulePath -ModuleName $ModuleName -Version $Version -BuildTarget $BuildTarget
    $ModulePsd1 = Join-Path -Path $ModulePath -ChildPath "$ModuleName.psd1"

    if (Get-Module -Name $ModuleName) { Remove-Module -Name $ModuleName -Force }

    Import-Module -Name $ModulePsd1 -Force -ErrorAction Stop *> $null
}

function Remove-TestModule {
    param ([string]$ModuleName)

    Remove-TestState

    if (Get-Module -Name $ModuleName) { Remove-Module -Name $ModuleName -Force }
}

function Test-IsWindowsPlatform {
    return ($PSEdition -eq 'Desktop' -or $IsWindows)
}

function Get-TestScriptAst {
    # Parses a script & returns the abstract syntax tree
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $ParseErrors = $null
    $Tokens      = $null
    $Ast         = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$Tokens, [ref]$ParseErrors)

    return [PSCustomObject]@{
        Ast         = $Ast
        ParseErrors = @($ParseErrors)
    }
}

function Get-TestModuleFile {
    # Every script file of the source module (Private & Public)
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    $ModuleRoot = Join-Path -Path (Get-TestRootPath) -ChildPath $ModuleName

    return @(foreach ($Folder in 'Private', 'Public') {
        Get-ChildItem -Path (Join-Path -Path $ModuleRoot -ChildPath $Folder) -Filter *.ps1 -File -Recurse
    })
}

