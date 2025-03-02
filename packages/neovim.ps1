#!/usr/bin/env pwsh

try {
    $nvimInstalled = choco list --local-only neovim | Select-String "neovim"
    
    if ($nvimInstalled) {
        Write-Host "✅ Neovim is already installed."
    } else {
        throw "Neovim not found"
    }
} catch {
    Write-Host "📦 Installing Neovim..."
    Invoke-Expression "choco install neovim -y"
    Write-Host "✅ Neovim installed successfully."
}
