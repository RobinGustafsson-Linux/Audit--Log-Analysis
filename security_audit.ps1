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







































# The report header
$reportPath = ".\security_audit.txt"
$report = @()

$report += "================================================================================"
$report += "                    SÄKERHETSGRANSKNINGSRAPPORT - TechCorp AB"
$report += "================================================================================"
