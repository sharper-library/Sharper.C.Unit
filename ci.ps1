$TestsRegex = '\.Tests$'

function AllProjects() {
    Get-ChildItem */project.json
}

function PackageProjects() {
    AllProjects | Where {$_.Directory.Name -notmatch $TestsRegex}
}

function TestProjects() {
    AllProjects | Where {$_.Directory.Name -match $TestsRegex}
}

function CleanCmd() {
    AllProjects | %{$_.Directory} | %{
        if (Test-Path $_/bin) {Remove-Item -Recurse $_/bin}
        if (Test-Path $_/obj) {Remove-Item -Recurse $_/obj}
    }
}

function RestoreCmd() {
    dnu restore
}

function InstallCmd() {
    nuget sources add -Name Sharper.C -Source $env:SHARPER_C_FEED
    dnvm install latest
    dnu restore
}

function BuildCmd() {
    $env:DNX_BUILD_VERSION =
        'build-{0}' -f ($env:APPVEYOR_BUILD_NUMBER.PadLeft(5, '0'))
    dnu pack --configuration Release (PackageProjects)
}

function TestCmd() {
    $codes = (TestProjects) | %{dnx -p $_ test | Write-Host; $LASTEXITCODE}
    $code = ($codes | Measure-Object -Sum).Sum
    exit $code
}

function RegisterCmd() {
    PackageProjects | %{
        Get-ChildItem -Recurse *.nupkg | %{dnu packages add $_}
    }
}

function RunCommand($name) {
    switch ($name) {
        clean {CleanCmd}
        restore {RestoreCmd}
        install {InstallCmd}
        build {BuildCmd}
        test {TestCmd}
        register {RegisterCmd}
    }
}

$args | %{RunCommand $_}
