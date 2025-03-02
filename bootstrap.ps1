#!/usr/bin/env pwsh
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$filter = ""
$dry = $false
$skipPackages = $false
$skipConfig = $false
foreach ($arg in $args) {
	if ($arg -eq "--dry") {
		$dry = $true
	}
	elseif ($arg -eq "--skip-packages") {
		$skipPackages = $true
	}
	elseif ($arg -eq "--skip-config") {
		$skipConfig = $true
	}
	else {
		$filter = $arg
	}
}
function Log {
	param([string]$message)
	if ($dry) {
		Write-Host "[DRY_RUN]: $message"
	}
	else {
		Write-Host $message
	}
}
function Execute {
	param([string]$command)
	Log "🔄 Executing: $command"
	if (-not $dry) {
		Invoke-Expression $command
	}
}
function Copy-Directory {
	param([string]$from, [string]$to)
	Push-Location $from
	try {
		$dirs = Get-ChildItem -Directory
		foreach ($dir in $dirs) {
			Execute "Remove-Item -Recurse -Force -ErrorAction SilentlyContinue `"$to\$($dir.Name)`""
			Execute "Copy-Item -Recurse `"$($dir.FullName)`" `"$to\$($dir.Name)`""
		}
	}
	finally {
		Pop-Location
	}
}
function Copy-File {
	param([string]$from, [string]$to)
	$name = Split-Path -Leaf $from
	Execute "Remove-Item -Force -ErrorAction SilentlyContinue `"$to\$name`""
	Execute "Copy-Item `"$from`" `"$to\$name`""
}
Write-Host "🚀 Bootstrap starting from $scriptDir with filter: '$filter'"
if (-not $skipPackages) {
	Log "📦 Installing Packages"
	$packageDir = Join-Path $HOME "packages"
	if (-not (Test-Path $packageDir)) {
		Execute "New-Item -ItemType Directory -Path `"$packageDir`""
		Log "📁 Created package directory: $packageDir"
	}
	$pkgScripts = Get-ChildItem -Path (Join-Path $scriptDir "packages") -File -Recurse |
		Where-Object { $_.Extension -eq ".ps1" } |
		Sort-Object Name
	foreach ($pkgScript in $pkgScripts) {
		if ($filter -and $pkgScript -notmatch $filter) {
			Log "🔍 Filtering out: $($pkgScript.FullName)"
			continue
		}
		Execute ". `"$($pkgScript.FullName)`""
	}
}
else {
	Log "⭐️ Skipping Packages"
}
if (-not $skipConfig) {
	Log "⚙️ Applying Configuration"

	Copy-File config/Microsoft.PowerShell_profile.ps1 (Split-Path -Parent $PROFILE)
}
else {
	Log "⭐️ Skipping Configuration"
}

Log "✅ Bootstrap complete!"
