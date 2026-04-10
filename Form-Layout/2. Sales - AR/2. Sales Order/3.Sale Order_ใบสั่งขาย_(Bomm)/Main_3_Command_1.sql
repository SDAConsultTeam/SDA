-- ============================================================
-- Report: 3.Sale Order_ใบสั่งขาย_(Bomm).rpt
Path:   3.Sale Order_ใบสั่งขาย_(Bomm).rpt
Extracted: 2026-04-10 10:22:54
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT picture 
FROM OQUT 
LEFT JOIN OHEM ON OQUT.SlpCode = OHEM.salesPrson
WHERE OQUT.DocEntry  = {?Dockey@}
