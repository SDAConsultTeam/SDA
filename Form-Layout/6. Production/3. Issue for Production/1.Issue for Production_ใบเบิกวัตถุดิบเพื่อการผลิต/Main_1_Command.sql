-- ============================================================
-- Report: 1.Issue for Production_ใบเบิกวัตถุดิบเพื่อการผลิต.rpt
Path:   6. Production\3. Issue for Production\1.Issue for Production_ใบเบิกวัตถุดิบเพื่อการผลิต.rpt
Extracted: 2026-04-09 15:22:54
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
OIGE.docentry,
PNNM.BeginStr As 'OderBeginStr',
PNNM.SeriesName As 'OderSeries',
OWOR.DocNum As 'OderNo.',
OWOR.ItemCode AS 'Production_No',
OWOR.ProdName,
OWOR.PlannedQty,
OWOR.Warehouse,
NNM1.SeriesName,
OIGE.DocNum,
OIGE.DocDate,
(IGE1.VisOrder+1) AS 'No.',
IGE1.ItemCode,
IGE1.Dscription,
IGE1.Quantity,
IGE1.UomCode,
IGE1.WhsCode,
OWOR.PostDate as 'PostDate' ,
NNM1.BeginStr,
OIGE.Comments,
CASE WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
     WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
END AS 'GLN_H'

FROM OIGE
LEFT JOIN IGE1 ON OIGE.DocEntry = IGE1.DocEntry 
LEFT JOIN NNM1 ON OIGE.Series = NNM1.Series 
LEFT JOIN OWOR ON IGE1.BaseEntry = OWOR.DocEntry
LEFT JOIN NNM1 PNNM ON OWOR.Series = PNNM.Series
LEFT JOIN OPRJ ON OWOR.Project = OPRJ.PrjCode
LEFT JOIN OWHS ON OIGE.U_SLD_LVatbranch = OWHS.GlblLocNum
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OIGE.U_SLD_LVatBranch = BRANCH.Code

WHERE 
OIGE.DocEntry  = {?DocKey@}
AND 
IGE1.BaseType = '202'

ORDER BY (IGE1.VisOrder+1)
