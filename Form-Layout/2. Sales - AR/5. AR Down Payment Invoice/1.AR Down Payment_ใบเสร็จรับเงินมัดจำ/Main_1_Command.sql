SELECT Distinct
DPI12.StreetB     AS '1Bill',
    DPI12.StreetNoB   AS '2Bill',
    DPI12.BlockB      AS '3Bill',
    DPI12.CityB       AS '4Bill',
    DPI12.CountyB     AS '5Bill',
    DPI12.ZipCodeB    AS '6Bill',
        DPI12.StreetS     AS '1Ship',
    DPI12.StreetNoS   AS '2Ship',
    DPI12.BlockS      AS '3Ship',
    DPI12.CityS       AS '4Ship',
    DPI12.CountyS     AS '5Ship',
    DPI12.ZipCodeS    AS '6Ship',
OCPR.Cellolar AS 'Phone2',
OCPR.E_MailL,
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND ODPI.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ODPI.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND ODPI.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND ODPI.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ODPI.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND ODPI.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND ODPI.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND ODPI.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE
 WHEN ODPI.Printed = 'N' AND ODPI.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ODPI.Printed = 'N' AND ODPI.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN ODPI.Printed = 'Y' AND ODPI.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN ODPI.Printed = 'Y' AND ODPI.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
NNM1.BeginStr,
ODPI.DocEntry,
ODPI.DocNum,
ODPI.DocDate,
ODPI.CardCode,
DPI1.unitmsr,
ODPI.NumAtCard,
(DPI1.VisOrder) As 'No.',
DPI1.LineNum as 'Line No.', 
ODPI.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CRD1.GlblLocNum,
OCRD.Phone1,
ISNULL(OCRD.Phone2,'') As 'Phone2',
OCRD.Fax,
ODPI.LicTradNum,
OCTG.PymntGroup,
ODPI.DocDueDate,
DPI1.ItemCode,
DPI1.Dscription as 'Dscription' ,
DPI1.Quantity,
ODPI.Comments,
ODPI.DocCur,
DPI1.PriceBefDi,
CASE WHEN ODPI.DocCur = 'THB' THEN DPI1.LineTotal ELSE DPI1.TotalFrgn END AS 'LineTotal',
CASE WHEN ODPI.DocCur = 'THB' THEN ODPI.VatSum ELSE ODPI.VatSumFC END AS 'VatSum',
CASE WHEN ODPI.DocCur = 'THB' THEN ODPI.DocTotal ELSE ODPI.DocTotalFC END AS 'DocTotal',
CASE WHEN ODPI.DocCur = 'THB' THEN ODPI.DpmAmnt ELSE ODPI.DpmAmntFC END AS 'DpmAmnt',
SUM(CASE WHEN ODPI.DocCur = 'THB' THEN DPI1.LineTotal ELSE DPI1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
ODPI.dpmprcnt,
RCT1.CheckNum,
RCT1.[CheckSum],
RCT1.DueDate As 'Check Date',
SUM(ORCT.CashSum) OVER() As 'CashSum',
SUM(ORCT.TrsfrSum) OVER() As 'TrsfrSum',
ODSC.BankName,
DPI1.LineType
FROM ODPI
INNER JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
LEFT JOIN DPI12 ON ODPI.DocEntry = DPI12.DocEntry
LEFT JOIN NNM1 ON ODPI.Series = NNM1.Series 
LEFT JOIN OCRD ON ODPI.CardCode = OCRD.CardCode 
LEFT JOIN OCPR ON ODPI.CntctCode = OCPR.CntctCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ODPI.PayToCode = CRD1.[Address] AND CRD1.AdresType ='B')
LEFT JOIN OSLP ON ODPI.SlpCode = OSLP.SlpCode 
LEFT JOIN OCTG ON ODPI.GroupNum = OCTG.GroupNum 
LEFT JOIN OHEM ON ODPI.OwnerCode = OHEM.empID
LEFT JOIN OUSR ON ODPI.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON DPI1.Project = OPRJ.PrjCode
LEFT JOIN ORCT ON ODPI.ReceiptNum = ORCT.DocEntry
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN RCT2 ON ORCT.DocNum = RCT2.DocEntry
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ODPI.U_SLD_LVatBranch = BRANCH.Code , oadm
WHERE ODPI.DocEntry  = {?DocKey@}
Order by 'No.' , 'Line No.'
