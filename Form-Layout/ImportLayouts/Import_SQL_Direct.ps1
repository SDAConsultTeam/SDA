# ============================================================
# Batch Import Crystal Layouts to SAP B1 (SQL Direct)
# Reads RPT_Import_Map.xlsx -> INSERT into RDOC
# Maps ObjectType -> TypeCode (Items variant by default)
# ============================================================
param(
    [string]$Server     = "SLD-C072",
    [string]$CompanyDB  = "SBO_SDA",
    [string]$DBUser     = "sa",
    [string]$DBPassword = "1q2w3e4r",
    [string]$MapFile    = "$PSScriptRoot\RPT_Import_Map.xlsx",
    [string]$RptRoot    = "$PSScriptRoot\..",
    [string]$LogFile    = "$PSScriptRoot\Import_SQL_Log.txt",
    [string]$Author     = "SDA",
    [ValidateSet("Update","Skip","Insert")]
    [string]$OnDuplicate = "Update",
    [string]$FilterFileName = "",
    [switch]$UseFileNameAsDocName,
    [switch]$DryRun
)

# Load DB plugin
. "$PSScriptRoot\DB-MSSQL.ps1"

# ObjectType -> TypeCode (RTYP.CODE) mapping
$TypeCodeMap = @{
    "30"         = "JDT2"   # Journal Entry
    "23"         = "QUT2"   # Sales Quotation (Items)
    "17"         = "RDR2"   # Sales Order (Items)
    "15"         = "DLN2"   # Delivery (Items)
    "16"         = "RDN2"   # Returns (Items)
    "203"        = "DPI2"   # AR Down Payment (Items)
    "13"         = "INV2"   # AR Invoice (Items)
    "14"         = "RIN2"   # AR Credit Note (Items)
    "1470000113" = "PRQ2"   # Purchase Request (Items)
    "540000405"  = "PQT2"   # Purchase Quotation (Items)
    "22"         = "POR2"   # Purchase Order (Items)
    "20"         = "PDN2"   # Goods Receipt PO (Items)
    "21"         = "RPD2"   # Goods Return (Items)
    "204"        = "DPO2"   # AP Down Payment (Items)
    "18"         = "PCH2"   # AP Invoice (Items)
    "19"         = "RPC2"   # AP Credit Note (Items)
    "69"         = "IPF1"   # Landed Costs
    "24"         = "RCT1"   # Incoming Payment
    "46"         = "VPM1"   # Outgoing Payment
    "59"         = "IGN1"   # Goods Receipt
    "60"         = "IGE1"   # Goods Issue
    "67"         = "WTR1"   # Inventory Transfer
    "1250000001" = "WTQ1"   # Inventory Transfer Request
    "1470000065" = "INC1"   # Inventory Counting
    "162"        = ""       # Inventory Revaluation - no clear RTYP code, skip
    "202"        = "WOR1"   # Production Order
}

function Write-Log {
    param([string]$Msg, [string]$Level = "INFO")
    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Msg
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
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
            No=$ws.Cells.Item($r,1).Value2; Module=$ws.Cells.Item($r,2).Value2
            RPT_FileName=$ws.Cells.Item($r,3).Value2; RPT_Folder=$ws.Cells.Item($r,4).Value2
            ObjectType=$ws.Cells.Item($r,8).Value2; FormMenuUID=$ws.Cells.Item($r,9).Value2
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

Write-Log "=== Start SQL Direct Import ==="
Write-Log "MapFile: $MapFile"
Write-Log "DryRun : $DryRun"

$mapRows = Read-MapExcel -Path $MapFile
Write-Log "Loaded $($mapRows.Count) mapping rows"

$conn = New-DBConnection -Server $Server -Database $CompanyDB -User $DBUser -Password $DBPassword

# Pre-fetch max sequence per TypeCode to avoid query per row
$maxSeqMap = @{}
$seqCmd = $conn.CreateCommand()
$seqCmd.CommandText = "SELECT TypeCode, MAX(CAST(SUBSTRING(DocCode, LEN(TypeCode)+1, 4) AS INT)) AS MaxSeq FROM RDOC WHERE LEN(DocCode)>=5 AND $DB_ISNUM(SUBSTRING(DocCode, LEN(TypeCode)+1, 4))=1 GROUP BY TypeCode"
$rdr = $seqCmd.ExecuteReader()
while ($rdr.Read()) {
    $tc = [string]$rdr["TypeCode"]
    $maxSeqMap[$tc] = [int]$rdr["MaxSeq"]
}
$rdr.Close()
Write-Log "Pre-loaded max sequences for $($maxSeqMap.Count) TypeCodes"

$ok = 0; $fail = 0; $skip = 0
foreach ($row in $mapRows) {
    if ($FilterFileName -and ($row.RPT_FileName -notlike "*$FilterFileName*")) { continue }
    $rptPath = Join-Path $RptRoot (Join-Path $row.RPT_Folder $row.RPT_FileName)
    $objType = [string]$row.ObjectType
    if ($UseFileNameAsDocName) {
        $layoutName = [System.IO.Path]::GetFileNameWithoutExtension($row.RPT_FileName)
    } else {
        $layoutName = if ([string]::IsNullOrWhiteSpace($row.LayoutName)) { $row.RPT_FileName } else { [string]$row.LayoutName }
    }

    if (-not (Test-Path $rptPath)) {
        Write-Log "SKIP MISSING file: $rptPath" "WARN"; $skip++; continue
    }
    if ([string]::IsNullOrWhiteSpace($objType) -or $objType -eq "-") {
        Write-Log "SKIP no ObjectType: $($row.RPT_FileName)" "WARN"; $skip++; continue
    }
    $typeCode = $TypeCodeMap[$objType]
    if ([string]::IsNullOrWhiteSpace($typeCode)) {
        Write-Log "SKIP unmapped ObjectType=$objType : $($row.RPT_FileName)" "WARN"; $skip++; continue
    }

    try {
        $bytes = [System.IO.File]::ReadAllBytes($rptPath)
        $md5 = [System.Security.Cryptography.MD5]::Create()
        $hash = [BitConverter]::ToString($md5.ComputeHash($bytes)).Replace("-","")
        $md5.Dispose()

        # Check if this layout already exists (match on DocName + TypeCode + Author)
        $chk = $conn.CreateCommand()
        $chk.CommandText = Convert-DBSql "SELECT DocCode FROM RDOC WHERE DocName=@n AND TypeCode=@t AND Author=@a"
        Add-DBParam $chk "${DB_PARAM}n" $layoutName
        Add-DBParam $chk "${DB_PARAM}t" $typeCode
        Add-DBParam $chk "${DB_PARAM}a" $Author
        $existingCode = $chk.ExecuteScalar()

        $action = ""; $docCode = ""
        if ($existingCode) {
            switch ($OnDuplicate) {
                "Skip"   { Write-Log ("SKIP exists [{0,3}] {1} (DocCode={2})" -f $row.No, $row.RPT_FileName, $existingCode) "WARN"; $skip++; continue }
                "Insert" { $maxSeqMap[$typeCode]++; $docCode = "{0}{1:D4}" -f $typeCode, $maxSeqMap[$typeCode]; $action = "INSERT (dup allowed)" }
                "Update" { $docCode = [string]$existingCode; $action = "UPDATE" }
            }
        } else {
            if (-not $maxSeqMap.ContainsKey($typeCode)) { $maxSeqMap[$typeCode] = 0 }
            $maxSeqMap[$typeCode]++
            $docCode = "{0}{1:D4}" -f $typeCode, $maxSeqMap[$typeCode]
            $action = "INSERT"
        }

        if ($DryRun) {
            Write-Log ("DRYRUN [{0,3}] {1} -> {2} DocCode={3} TypeCode={4} Bytes={5} Hash={6}" -f $row.No, $row.RPT_FileName, $action, $docCode, $typeCode, $bytes.Length, $hash.Substring(0,8))
            $ok++; continue
        }

        if ($action -eq "UPDATE") {
            $sql = "UPDATE RDOC SET Template=@Template, RptHash=@RptHash, UpdateDate=$DB_NOW WHERE DocCode=@DocCode"
        } else {
            $sql = "INSERT INTO RDOC (DocCode,DocName,Author,Notes,Width,Height,LMargin,RMargin,TMargin,BMargin,CanChange,PaperSize,Oreint,GridSize,GridType,ShowGrid,SnapGrid,TypeCode,FrgnReport,CanSort,LeaderCode,FollowCode,SwapOnScrn,ScreenFont,ScrFOffset,SwpInEmail,EmailFont,EmFOffset,QString,QType,RobjCode,ExtName,ExtOnErr,NumRepArs,AlgnFooter,TimeFormat,DateFormat,NumCopy,GbiSupport,Use1stPrtr,Shading,Template,Category,CreateDate,Status,B1Version,CRVersion,Local,UseSysPref,ForMobile,TypeDetail,IsIMCE,CsUrl,RptHash) VALUES (@DocCode,@DocName,@Author,'',595,842,10,30,10,10,'Y','A4','P',10,'1','Y','Y',@TypeCode,'N','Y','','','N','Arial',-1,'N','Arial',-1,'','R',0,'','S',-1,'N','0','0',1,'N','N','Y',@Template,'C',$DB_NOW,'A','','','','Y','Y','','N','',@RptHash)"
        }

        $cmd = $conn.CreateCommand()
        $cmd.CommandText = Convert-DBSql $sql
        Add-DBParam $cmd "${DB_PARAM}DocCode" $docCode
        if ($action -ne "UPDATE") {
            Add-DBParam $cmd "${DB_PARAM}DocName" $layoutName
            Add-DBParam $cmd "${DB_PARAM}Author" $Author
            Add-DBParam $cmd "${DB_PARAM}TypeCode" $typeCode
        }
        Add-BlobParam $cmd "${DB_PARAM}Template" $bytes
        Add-DBParam $cmd "${DB_PARAM}RptHash" $hash

        [void]$cmd.ExecuteNonQuery()
        Write-Log ("{0} [{1,3}] {2} -> DocCode={3} ({4} bytes, {5})" -f $action, $row.No, $row.RPT_FileName, $docCode, $bytes.Length, $layoutName)
        $ok++
    } catch {
        Write-Log ("FAIL [{0,3}] {1}: {2}" -f $row.No, $row.RPT_FileName, $_.Exception.Message) "ERROR"
        $fail++
        # Roll back the seq increment if it wasn't actually used
        $maxSeqMap[$typeCode]--
    }
}
$conn.Close()
Write-Log "=== Summary: OK=$ok FAIL=$fail SKIP=$skip ==="