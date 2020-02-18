git config --global user.email "prkrishn+bot@hotmail.com"
git config --global user.name "Pranav K (bot)"

$baseUrl = "https://jenkins.mono-project.com/job/test-mono-mainline-wasm/$buildNumber/label=ubuntu-1804-amd64/Azure/"
$content = Invoke-WebRequest -Uri $baseUrl
$match = $content -match ('<a href="(processDownloadRequest/(\d+)/.*?)"')

if (!$match) {
    Write-Error "Unable to find the artifact in $content"
    return 1
}

$archivePath = $Matches[1]
$buildNumber = $Matches[2]

$tempDir = [IO.Path]::Combine($env:Temp, 'blazor-mono', [IO.Path]::GetRandomFileName())
$downloadPath = Join-Path $tempDir 'mono.zip'
$MonoRootDir = [IO.Path]::Combine($tempDir, [IO.Path]::GetRandomFileName())
[IO.Directory]::CreateDirectory($MonoRootDir)

Invoke-WebRequest "${baseUrl}${archivePath}" -OutFile $downloadPath

Add-Type -Assembly System.IO.Compression.FileSystem | Out-Null
[IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $MonoRootDir)


git clone https://github.com/pranavkm/Blazor
cd Blazor
./UpgradeMono.ps1 -MonoRootDir $MonoRootDir

git add .
git commit -m "Updating build to https://jenkins.mono-project.com/job/test-mono-mainline-wasm/$buildNumber"

$command ="hub pull-request -b update-mono -h master --no-edit"
Write-Host $command
. $command
