oh-my-posh init pwsh --config $env:NON_THEMES_PATH\non-terminal-minimal.omp.toml | Invoke-Expression

Import-Module -Name Terminal-Icons
Import-Module -Name PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

Enable-PoshTransientPrompt = true