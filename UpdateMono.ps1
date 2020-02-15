git config --global user.email "prkrishn+bot@hotmail.com"
git config --global user.name "Pranav K (bot)"


curl https://raw.githubusercontent.com/pranavkm/blazor/prkrishn/build/UpgradeMono.ps1 -o /tmp/UpgradeMono.ps1
git clone https://github.com/dotnet/Blazor -b master
cd Blazor

git checkout -B update-mono
/tmp/UpgradeMono.ps1 -repoRoot $PWD -commitChanges

# Workaround for `hub` auth error https://github.com/github/hub/issues/2149#issuecomment-513214342
export GITHUB_USER="$GITHUB_ACTOR"

git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"
git push origin +update-mono

$command ="hub pull-request -b update-mono -h master --no-edit"
Write-Host $command
. $command
