SELECT
CASE WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
     WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
END AS 'GLN_H',
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
OIGN.U_GR_RE,
IGN1.Project

FROM OIGN
LEFT JOIN IGN1 ON OIGN.DocEntry = IGN1.DocEntry
LEFT JOIN NNM1 ON OIGN.Series = NNM1.Series
LEFT JOIN OPRJ ON IGN1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON OIGN.UserSign = OUSR.USERID
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OIGN.U_SLD_LVatBranch = BRANCH.Code

WHERE OIGN.DocEntry = {?Dockey@}
AND IGN1.basetype <> '202'

ORDER BY IGN1.VisOrder
