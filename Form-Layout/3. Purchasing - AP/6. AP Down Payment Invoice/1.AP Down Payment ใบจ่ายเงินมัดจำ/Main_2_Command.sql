-- ============================================================
-- Report: 1.AP Down Payment Invoice_ใบจ่ายเงินมัดจำ.rpt
Path:   3. Purchasing - AP\6. AP Down Payment Invoice\1.AP Down Payment Invoice_ใบจ่ายเงินมัดจำ.rpt
Extracted: 2026-04-09 15:22:45
-- Source: Main Report
-- Table:  Command
-- ============================================================

select 
oadm.CompnyName,
oadm.AliasName,
oadm.Phone1,
adm1.IntrntAdrs,
oadm.RevOffice,
adm1.Street,
adm1.City,
adm1.ZipCode,
CASE WHEN adm1.GlblLocNum = '00000' THEN N'สำนักงานใหญ่'
  WHEN adm1.GlblLocNum <> '00000' THEN N'สาขาที่ ' + adm1.GlblLocNum
  END as 'Branch Name'
from oadm
left join adm1 on oadm.Country = adm1.Country
