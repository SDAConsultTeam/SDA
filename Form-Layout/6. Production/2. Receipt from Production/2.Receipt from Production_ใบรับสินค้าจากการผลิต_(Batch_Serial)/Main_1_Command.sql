-- ============================================================
-- Report: 2.Receipt from Production_ใบรับสินค้าจากการผลิต_(Batch_Serial).rpt
Path:   6. Production\2. Receipt from Production\2.Receipt from Production_ใบรับสินค้าจากการผลิต_(Batch_Serial).rpt
Extracted: 2026-04-09 15:22:54
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
OIGN.DocEntry,
NNM1.BeginStr,
NNM1.SeriesName,
OIGN.DocNum,
OIGN.DocDate,
PNNM.BeginStr As 'OderBeginStr',
PNNM.SeriesName As 'OderSeries',
OWOR.DocNum As 'OderNo.',
OWOR.ItemCode AS 'Production_No',
OWOR.ProdName,
OWOR.PlannedQty,
OWOR.Warehouse,
(IGN1.VisOrder+1) AS 'No.',
IGN1.ItemCode,
IGN1.Dscription,
IGN1.Quantity,
IGN1.UomCode,
IGN1.WhsCode,
OIGN.Comments,
CASE WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
     WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
END AS 'GLN_H'

FROM OIGN
LEFT JOIN IGN1 ON OIGN.DocEntry = IGN1.DocEntry --and IGN1.BaseRef =
LEFT JOIN NNM1 ON OIGN.Series = NNM1.Series 
LEFT JOIN OPRJ ON IGN1.Project = OPRJ.PrjCode
LEFT JOIN OWOR ON IGN1.BaseEntry = OWOR.DocEntry
LEFT JOIN NNM1 PNNM ON OWOR.Series = PNNM.Series
LEFT JOIN OWHS ON OIGN.U_SLD_LVatbranch = OWHS.GlblLocNum
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OIGN.U_SLD_LVatBranch = BRANCH.Code

WHERE 
OIGN.DocEntry = '{?DocKey@}'
AND IGN1.BaseType = '202'

ORDER BY (IGN1.VisOrder+1)
