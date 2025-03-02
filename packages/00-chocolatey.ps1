try {
	$null = Get-Command choco -ErrorAction Stop
	Write-Host "✅ Chocolatey already installed."
} catch {
	Write-Host "📦 Chocolatey not found. Installing Chocolatey..."
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
	Write-Host "✅ Chocolatey installed successfully."
}

