-- ============================================================
-- Report: 3.Sale Order_ใบสั่งขาย_(Bomm).rpt
Path:   3.Sale Order_ใบสั่งขาย_(Bomm).rpt
Extracted: 2026-04-10 10:22:54
-- Source: Subreport [Text]
-- Table:  Command
-- ============================================================

SELECT DISTINCT
ORDR.DocEntry,
(RDR1.VisOrder+1) AS 'No.',
CAST(RDR10.LineText AS NVARCHAR(2000)) AS 'Text',
RDR10.OrderNum

FROM ORDR
LEFT JOIN RDR1 ON ORDR.DocEntry = RDR1.DocEntry
LEFT JOIN RDR10 ON ORDR.DocEntry = RDR10.DocEntry AND RDR1.VisOrder = RDR10.AftLineNum

ORDER BY RDR10.OrderNum

