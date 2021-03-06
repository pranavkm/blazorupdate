git config --global user.email "prkrishn+bot@hotmail.com"
git config --global user.name "Pranav K (bot)"

$GITHUB_ACTOR="$env:GITHUB_ACTOR"
$GITHUB_TOKEN="$env:GITHUB_TOKEN"

$env:GITHUB_USER="$GITHUB_ACTOR"
$baseUrl = "https://jenkins.mono-project.com/job/archive-mono/job/3.2-wasm/lastSuccessfulBuild/Azure/"

$content = Invoke-WebRequest -Uri $baseUrl
$match = $content -match ('<a href="(processDownloadRequest/sdks/wasm/mono-wasm-([^\.]+)\.zip)">')

if (!$match) {
    Write-Error "Unable to find the artifact in $content"
    return 1
}

$archivePath = $Matches[1]
$commitHash = $Matches[2]

$tempDir = [IO.Path]::Combine('/tmp', 'blazor-mono', [IO.Path]::GetRandomFileName())
$downloadPath = Join-Path $tempDir 'mono.zip'
$MonoRootDir = [IO.Path]::Combine($tempDir, [IO.Path]::GetRandomFileName())
[IO.Directory]::CreateDirectory($MonoRootDir)

Invoke-WebRequest "${baseUrl}${archivePath}" -OutFile $downloadPath

Add-Type -Assembly System.IO.Compression.FileSystem | Out-Null
[IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $MonoRootDir)

git clone "https://@github.com/dotnet/Blazor" --depth 1
cd Blazor
git checkout master -B update-mono
./UpgradeMono.ps1 -MonoRootDir $MonoRootDir

git remote set-url origin "https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/dotnet/Blazor"
git add .
git commit -m "Updating build to commit https://github.com/mono/mono/commit/$commitHash"
git push origin +update-mono:update-mono

hub pull-request -b master -h update-mono --no-edit -l "auto-merge" -r  "SteveSandersonMS,javiercn,mkArtakMSFT"
