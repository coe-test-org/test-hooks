# -------------------------------------------------
# Fail-Fast Automated Setup Script
# -------------------------------------------------

# Stop immediately if any command fails
$ErrorActionPreference = "Stop"

try {

    # 1️ Install CLI tool
    Write-Host "Installing CLI tool..."
    powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/edenian-prince/rust-secrets/refs/heads/main/install.ps1 | iex"

    # 2️ Define variables
    $RepoUrl = "https://github.com/edenian-prince/rust-secrets.git"  # <-- replace with your repo URL
    $RepoName = "rust-secrets"                                  # folder name to clone into
    $RepoFile = "examples/example_regex.txt"
    $RepoPath = Join-Path $HOME $RepoName
    $SecretFilePath = Join-Path $RepoPath $RepoFile 

    # 3️ Clone the repo to $HOME
    Write-Host "Cloning repository to $RepoPath..."
    if (Test-Path $RepoPath) {
        Write-Host "Repository folder already exists. Pulling latest changes..."
        Set-Location $RepoPath
        git pull
    } else {
        git clone $RepoUrl $RepoPath
    }

    # 4️ Run git-find install
    Write-Host "Running git-find install..."
    git-find install

    # 5️ Run git-find add-provider and automatically answer 'y'
    # Write 'y' to stdin.txt first
    "y" | Set-Content -Path "stdin.txt"
    
    # Then start the process
    Write-Host "Running git-find add-provider $SecretFilePath..."
    $proc = Start-Process -FilePath "git-find" `
        -ArgumentList "add-provider", "--path", $SecretFilePath `
        -NoNewWindow -RedirectStandardInput "stdin.txt" -Wait -PassThru
    
    $proc.WaitForExit()

    Write-Host "✅ Setup completed successfully!"

} catch {
    Write-Host "ERROR: Script stopped. $_" -ForegroundColor Red
    exit 1
}
