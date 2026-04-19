-- ============================================================
-- Report: 2.Goods Receipt_ใบรับสินค้า_(Batch_Serial).rpt
Path:   5. Inventory\1. Goods Receipt\2.Goods Receipt_ใบรับสินค้า_(Batch_Serial).rpt
Extracted: 2026-04-09 15:22:49
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT
BRANCH.[Code] As 'BranchCode',
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_Building As 'Building',
BRANCH.U_SLD_Steet As 'Street',
BRANCH.U_SLD_Block As 'Block',
BRANCH.U_SLD_City As 'City',
BRANCH.U_SLD_County As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
OIGN.DocEntry,
OIGN.DocNum,
OIGN.DocDate,
NNM1.BeginStr,
(IGN1.VisOrder+1) As 'No.',
IGN1.ItemCode,
IGN1.Dscription,
IGN1.Quantity,
IGN1.UomCode,
IGN1.WhsCode,
OIGN.comments,
CAST(IGN10.LineText As NVARCHAR(200)) As 'Text',
OIGN.U_GR_RE,
IGN1.Project

FROM OIGN
LEFT JOIN IGN1 ON OIGN.DocEntry = IGN1.DocEntry
LEFT JOIN IGN10 ON OIGN.Docentry = IGN10.DocEntry AND IGN1.VisOrder = IGN10.AftLineNum
LEFT JOIN NNM1 ON OIGN.Series = NNM1.Series
LEFT JOIN OPRJ ON IGN1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON OIGN.UserSign = OUSR.USERID
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OIGN.U_SLD_LVatBranch = BRANCH.Code

WHERE OIGN.DocEntry = {?Dockey@}
AND IGN1.basetype <> '202'

ORDER BY IGN1.VisOrder
