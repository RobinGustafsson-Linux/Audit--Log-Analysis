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

# Look after security problems in logs
$logFindings = Get-ChildItem -Filter "*.log" -Recurse |
Select-String -Pattern "ERROR|FAILED|DENIED" |
Group-Object Path

# Generate CSV files with configurationsfiles
$configInventory = @()
foreach ($file in $configFiles + $ruleFiles) {
    $hasBackup = Test-Path ($file.FullName + ".bak")
    $configInventory += [PSCustomObject]@{
        FileName     = $file.Name
        FullPath     = $file.FullName
        SizeKB       = [math]::Round($file.Length / 1KB, 2)
        LastModified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        FileType     = ($file.Directory.Name)
        HasBackup    = $hasBackup
    }
}
$configInventory | Export-Csv -Path ".\config_inventory.csv" -NoTypeInformation -Encoding UTF8

# The report header
$reportPath = ".\security_audit.txt"
$report = @()

$report += "================================================================================"
$report += "                    SÄKERHETSGRANSKNINGSRAPPORT - TechCorp AB"
$report += "================================================================================"
$report += "Genererad: $now"
$report += "Granskad sökväg: $auditPath"
$report += ""
$report += "FILINVENTERING"
$report += "--------------"
$report += "Totalt antal filer: $($allFiles.Count)"
$report += "Konfigurationsfiler: $($configFiles.Count)"
$report += "Loggfiler: $($logFiles.Count)"
$report += "Backupfiler: $($backupFiles.Count)"
$report += ""
$report += "Filer ändrade senaste 7 dagarna: $($recentFiles.Count)"
foreach ($file in $recentFiles) {
    $report += "- $($file.Name) ($($file.LastWriteTime.ToString('yyyy-MM-dd')))"
}

$report += ""
$report += "SÄKERHETSFYND"
$report += "--------------"
$report += "Antal IP-adresser funna: $($ipMatches.Count)"
$report += "Antal loggfiler med ERROR/FAILED/DENIED: $($logFindings.Count)"
$report += ""
$report += "STÖRSTA LOGGFILER"
$report += "-----------------"
foreach ($log in $largestLogs) {
    $sizeKB = [math]::Round($log.Length / 1KB, 2)
    $report += "- $($log.Name): $sizeKB KB"
}

$report += ""
$report += "FILTYPER OCH TOTAL STORLEK"
$report += "---------------------------"
foreach ($group in $fileGroups) {
    $sizeKB = [math]::Round(($group.Group | Measure-Object Length -Sum).Sum / 1KB, 2)
    $report += "$($group.Name): $($group.Count) filer, totalt $sizeKB KB"
}

$report += ""
$report += "================================================================================"
$report += "SLUT PÅ RAPPORT"
$report += "================================================================================"

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Rapport skapad: $reportPath"
Write-Host "CSV skapad: config_inventory.csv"