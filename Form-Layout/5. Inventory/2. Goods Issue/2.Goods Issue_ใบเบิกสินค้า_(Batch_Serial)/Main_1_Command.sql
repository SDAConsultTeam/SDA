-- ============================================================
-- Report: 2.Goods Issue_ใบเบิกสินค้า_(Batch_Serial).rpt
Path:   5. Inventory\2. Goods Issue\2.Goods Issue_ใบเบิกสินค้า_(Batch_Serial).rpt
Extracted: 2026-04-09 15:22:49
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT
CASE WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
     WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
END AS 'GLN_H',
OIGE.DocEntry,
OIGE.DocNum,
OIGE.DocDate,
NNM1.BeginStr,
(IGE1.VisOrder+1) AS 'No.',
IGE1.LineNum,
IGE1.ItemCode,
IGE1.Dscription,
IGE1.Quantity,
IGE1.WhsCode,
OIGE.Comments,
IGE1.unitmsr,
OIGE.U_GI_RE,
IGE1.Project

FROM OIGE
INNER JOIN IGE1 IGE1 ON OIGE.DocEntry = IGE1.DocEntry
LEFT JOIN NNM1 ON OIGE.Series = NNM1.Series
LEFT JOIN OPRJ ON IGE1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON OIGE.UserSign = OUSR.USERID
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OIGE.U_SLD_LVatBranch = BRANCH.Code

WHERE OIGE.DocEntry  = {?DocKey@}
AND OIGE.BaseType <> '202'

ORDER BY IGE1.VisOrder
