SELECT
    CASE 
        WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
        WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
    END AS 'GLN_H',
    OWTR.DocEntry,
    NNM1.BeginStr + CONVERT(VARCHAR(10), OWTR.DocNum) AS 'DocNum',
    OWTR.DocDate,
    OWTR.DocNum,
    OWTR.Comments AS 'Remark',
    WTR1.BaseRef AS 'TransRefNo',
    WTR1.LineNum + 1 AS 'LineNum',
    WTR1.ItemCode,
    WTR1.Dscription,
    WTR1.Quantity,
    WTR1.unitMsr,
    WTR1.FromWhsCod,
    WTR1.WhsCode,
    WTR1.Project
FROM OWTR
INNER JOIN WTR1 ON OWTR.DocEntry = WTR1.DocEntry 
INNER JOIN NNM1 ON OWTR.Series = NNM1.Series
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OWTR.U_SLD_LVatBranch = BRANCH.Code
WHERE OWTR.DocEntry = {?DocKey@}
