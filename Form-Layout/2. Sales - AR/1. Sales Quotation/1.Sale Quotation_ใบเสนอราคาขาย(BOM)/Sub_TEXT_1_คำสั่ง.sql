-- ============================================================
-- Report: 1.Sale Quotation_ใบเสนอราคาขาย.rpt
Path:   2. Sales - AR\1. Sales Quotation\1.Sale Quotation_ใบเสนอราคาขาย.rpt
Extracted: 2026-04-09 15:22:33
-- Source: Subreport [TEXT]
-- Table:  คำสั่ง
-- ============================================================

SELECT DISTINCT
OQUT.DocEntry,
(QUT1.VisOrder+1) AS 'No.',
CAST(QUT10.LineText AS NVARCHAR(200)) AS 'Text',
QUT10.OrderNum

FROM OQUT
LEFT JOIN QUT1 ON OQUT.DocEntry = QUT1.DocEntry
LEFT JOIN QUT10 ON OQUT.DocEntry = QUT10.DocEntry AND QUT1.VisOrder = QUT10.AftLineNum

ORDER BY QUT10.OrderNum
