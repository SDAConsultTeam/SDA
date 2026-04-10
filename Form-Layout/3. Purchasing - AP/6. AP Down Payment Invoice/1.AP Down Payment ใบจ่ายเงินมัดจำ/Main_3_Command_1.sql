-- ============================================================
-- Report: 1.AP Down Payment Invoice_ใบจ่ายเงินมัดจำ.rpt
Path:   3. Purchasing - AP\6. AP Down Payment Invoice\1.AP Down Payment Invoice_ใบจ่ายเงินมัดจำ.rpt
Extracted: 2026-04-09 15:22:45
-- Source: Main Report
-- Table:  Command_1
-- ============================================================

SELECT picture,
ODPO.DocEntry
FROM ODPO
LEFT JOIN OHEM ON ODPO.UserSign = OHEM.userId
WHERE ODPO.DocEntry  = {?DocKey@}
