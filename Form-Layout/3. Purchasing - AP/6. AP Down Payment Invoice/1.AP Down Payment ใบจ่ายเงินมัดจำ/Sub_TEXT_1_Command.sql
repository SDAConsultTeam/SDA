-- ============================================================
-- Report: 1.AP Down Payment Invoice_ใบจ่ายเงินมัดจำ.rpt
Path:   3. Purchasing - AP\6. AP Down Payment Invoice\1.AP Down Payment Invoice_ใบจ่ายเงินมัดจำ.rpt
Extracted: 2026-04-09 15:22:45
-- Source: Subreport [TEXT]
-- Table:  Command
-- ============================================================

SELECT DISTINCT
ODPO.DocEntry,
(DPO1.VisOrder+1) AS 'No.',
CAST(DPO10.LineText AS NVARCHAR(2000)) AS 'Text',
DPO10.OrderNum

FROM ODPO 
LEFT JOIN DPO1 ON ODPO.DocEntry = DPO1.DocEntry 
LEFT JOIN DPO10 ON ODPO.Docentry = DPO10.DocEntry AND DPO1.VisOrder = DPO10.AftLineNum

ORDER BY DPO10.OrderNum
