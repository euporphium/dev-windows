#!/usr/bin/env pwsh

try {
    $installed = choco list --local-only mingw | Select-String "mingw"
    
    if ($installed) {
        Write-Host "✅ MinGW is already installed."
    } else {
        throw "MinGW not found"
    }
} catch {
    Write-Host "📦 Installing MinGW..."
    Invoke-Expression "choco install mingw -y"
    Write-Host "✅ MinGW installed successfully."
}
