-- ============================================================
-- Report: 2.Inventory Transfer_ใบโอนสินค้า_TH_(Batch_Serial) - Copy - Copy.rpt
Path:   5. Inventory\4. Inventory Transfer\2.Inventory Transfer_ใบโอนสินค้า_TH_(Batch_Serial) - Copy - Copy.rpt
Extracted: 2026-04-09 15:22:51
-- Source: Main Report
-- Table:  Command
-- ============================================================



select CompnyName,adm1.Street,adm1.Block,adm1.City,adm1.County,adm1.ZipCode,AliasName,Phone1,IntrntAdrs,RevOffice,
CASE WHEN adm1.GlblLocNum = '00000' THEN N'สำนักงานใหญ่'
  WHEN adm1.GlblLocNum <> '00000' THEN N'สาขาที่ ' + adm1.GlblLocNum
  END as 'GLN_H'
from oadm,adm1,ADM2