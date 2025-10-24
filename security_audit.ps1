# Date setup
$now = Get-Date "2024-10-14"
$weekAgo = $now.AddDays(-7)

# Network_config catalogry path
$auditPath = "C:\network_configs"
Set-Location $auditPath

# Retrieve the files
$allFiles = Get-ChildItem -Recurse -File
$configFiles = Get-ChildItem -Filter "*.conf" -Recurse
$ruleFiles = Get-ChildItem -Filter "*.rules" -Recurse
$logFiles = Get-ChildItem -Filter "*.log" -Recurse
$backupFiles = Get-ChildItem -Filter "*.bak" -Recurse


# Del A: Inventering
$recentFiles = $allFiles | Where-Object { $_.LastWriteTime -gt $weekAgo } | Sort-Object LastWriteTime -Descending

# Group after file type
$fileGroups = $allFiles | Group-Object -Property Extension

# Fetch large files
$largestLogs = $logFiles | Sort-Object Length -Descending | Select-Object -First 5

# Del B: Säkerhetsgranskning
# Search for IP addresses
$ipMatches = Get-ChildItem -Filter "*.conf" -Recurse |
Select-String -Pattern "\d{1,3}(\.\d{1,3}){3}" |
ForEach-Object { $_.Matches.Value } | Sort-Object -Unique






























# The report header
$reportPath = ".\security_audit.txt"
$report = @()

$report += "================================================================================"
$report += "                    SÄKERHETSGRANSKNINGSRAPPORT - TechCorp AB"
$report += "================================================================================"
