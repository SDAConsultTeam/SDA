-- ============================================================
-- Report: 3.Sale Order_ใบสั่งขาย_(Bomm).rpt
Path:   3.Sale Order_ใบสั่งขาย_(Bomm).rpt
Extracted: 2026-04-10 10:22:54
-- Source: Main Report
-- Table:  Command
-- ============================================================

select CompnyName,adm1.Street,adm1.Block,adm1.City,adm1.County,adm1.ZipCode,AliasName,Phone1,IntrntAdrs,RevOffice,
CASE WHEN adm1.GlblLocNum = '00000' THEN N'สำนักงานใหญ่'
  WHEN adm1.GlblLocNum <> '00000' THEN N'สาขาที่ ' + adm1.GlblLocNum
  END as 'GLN_H'
from oadm,adm1,ADM2
