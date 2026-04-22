# ============================================================
# Rollback: Delete layouts in RDOC that match rows in Excel mapping
# Reads RPT_Import_Map.xlsx -> deletes matching rows by (DocName + TypeCode + Author)
# ============================================================
param(
    [string]$Server     = "SLD-C072",
    [string]$CompanyDB  = "SBO_SDA",
    [string]$DBUser     = "sa",
    [string]$DBPassword = "1q2w3e4r",
    [string]$MapFile    = "C:\SDA\SDA\Form-Layout\ImportLayouts\Config\RPT_Import_Map.xlsx",
    [string]$Author     = "SDA",
    [switch]$DryRun,
    [switch]$Force
)

# Same ObjectType -> TypeCode map as Import_SQL_Direct.ps1
$TypeCodeMap = @{
    "30"         = "JDT2"
    "23"         = "QUT2"
    "17"         = "RDR2"
    "15"         = "DLN2"
    "16"         = "RDN2"
    "203"        = "DPI2"
    "13"         = "INV2"
    "14"         = "RIN2"
    "1470000113" = "PRQ2"
    "540000405"  = "PQT2"
    "22"         = "POR2"
    "20"         = "PDN2"
    "21"         = "RPD2"
    "204"        = "DPO2"
    "18"         = "PCH2"
    "19"         = "RPC2"
    "69"         = "IPF1"
    "24"         = "RCT1"
    "46"         = "VPM1"
    "59"         = "IGN1"
    "60"         = "IGE1"
    "67"         = "WTR1"
    "1250000001" = "WTQ1"
    "1470000065" = "INC1"
    "162"        = ""
    "202"        = "WOR1"
}

function Read-MapExcel {
    param([string]$Path)
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false; $excel.DisplayAlerts = $false
    $wb = $excel.Workbooks.Open($Path, 0, $true)
    $ws = $wb.Worksheets.Item("RPT_MAP")
    $rows = $ws.UsedRange.Rows.Count
    $list = @()
    for ($r = 2; $r -le $rows; $r++) {
        $item = [PSCustomObject]@{
            No=$ws.Cells.Item($r,1).Value2
            RPT_FileName=$ws.Cells.Item($r,3).Value2
            ObjectType=$ws.Cells.Item($r,8).Value2
            LayoutName=$ws.Cells.Item($r,10).Value2
        }
        if ($item.RPT_FileName) { $list += $item }
    }
    $wb.Close($false); $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ws) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wb) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [GC]::Collect()
    return $list
}

Write-Host "=== Rollback layouts from Excel mapping ===" -ForegroundColor Cyan
Write-Host "MapFile: $MapFile"
Write-Host "Author : $Author"
Write-Host ""

$mapRows = Read-MapExcel -Path $MapFile
Write-Host "Loaded $($mapRows.Count) mapping rows"

$cs = "Server=$Server;Database=$CompanyDB;User ID=$DBUser;Password=$DBPassword;Connection Timeout=10;"
$conn = New-Object System.Data.SqlClient.SqlConnection $cs
$conn.Open()

$toDelete = @()
$skipped = 0
foreach ($row in $mapRows) {
    $objType = [string]$row.ObjectType
    $layoutName = if ([string]::IsNullOrWhiteSpace($row.LayoutName)) { $row.RPT_FileName } else { [string]$row.LayoutName }
    if ([string]::IsNullOrWhiteSpace($objType) -or $objType -eq "-") { $skipped++; continue }
    $typeCode = $TypeCodeMap[$objType]
    if ([string]::IsNullOrWhiteSpace($typeCode)) { $skipped++; continue }

    $chk = $conn.CreateCommand()
    $chk.CommandText = "SELECT DocCode FROM RDOC WHERE DocName=@n AND TypeCode=@t AND Author=@a"
    [void]$chk.Parameters.AddWithValue("@n", $layoutName)
    [void]$chk.Parameters.AddWithValue("@t", $typeCode)
    [void]$chk.Parameters.AddWithValue("@a", $Author)
    $existingCode = $chk.ExecuteScalar()
    if ($existingCode) {
        $toDelete += [PSCustomObject]@{ No=$row.No; DocCode=$existingCode; TypeCode=$typeCode; DocName=$layoutName }
    }
}

Write-Host ""
Write-Host "=== Preview: $($toDelete.Count) row(s) to delete ===" -ForegroundColor Yellow
$toDelete | Format-Table No,DocCode,TypeCode,DocName -AutoSize

if ($toDelete.Count -eq 0) {
    Write-Host "Nothing to delete." -ForegroundColor Green
    $conn.Close()
    return
}

if ($DryRun) {
    Write-Host "DryRun mode - no changes made." -ForegroundColor Cyan
    $conn.Close()
    return
}

if (-not $Force) {
    $ans = Read-Host "Delete these $($toDelete.Count) rows from RDOC? Type 'yes' to confirm"
    if ($ans -ne "yes") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        $conn.Close()
        return
    }
}

$deleted = 0
foreach ($row in $toDelete) {
    $del = $conn.CreateCommand()
    $del.CommandText = "DELETE FROM RDOC WHERE DocCode=@c"
    [void]$del.Parameters.AddWithValue("@c", $row.DocCode)
    $n = $del.ExecuteNonQuery()
    if ($n -gt 0) {
        Write-Host ("DELETED {0} ({1})" -f $row.DocCode, $row.DocName) -ForegroundColor Green
        $deleted++
    }
}
$conn.Close()

Write-Host ""
Write-Host "=== Summary: Deleted=$deleted / Matched=$($toDelete.Count) / Skipped(no mapping)=$skipped ===" -ForegroundColor Cyan
