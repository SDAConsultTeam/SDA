-- ============================================================
-- Report: 2.AP Down Payment Invoice_ใบจ่ายเงินมัดจำใบกำกับภาษี.rpt
Path:   3. Purchasing - AP\6. AP Down Payment Invoice\2.AP Down Payment Invoice_ใบจ่ายเงินมัดจำใบกำกับภาษี.rpt
Extracted: 2026-04-09 15:22:45
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT Distinct
DPO12.StreetB     AS '1Bill',
    DPO12.StreetNoB   AS '2Bill',
    DPO12.BlockB      AS '3Bill',
    DPO12.CityB       AS '4Bill',
    DPO12.CountyB     AS '5Bill',
    DPO12.ZipCodeB    AS '6Bill',
        DPO12.StreetS     AS '1Ship',
    DPO12.StreetNoS   AS '2Ship',
    DPO12.BlockS      AS '3Ship',
    DPO12.CityS       AS '4Ship',
    DPO12.CountyS     AS '5Ship',
    DPO12.ZipCodeS    AS '6Ship',
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND ODPO.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ODPO.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND ODPO.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND ODPO.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ODPO.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND ODPO.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND ODPO.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND ODPO.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE
 WHEN ODPO.Printed = 'N' AND ODPO.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ODPO.Printed = 'N' AND ODPO.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN ODPO.Printed = 'Y' AND ODPO.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN ODPO.Printed = 'Y' AND ODPO.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
NNM1.BeginStr,
ODPO.DocEntry,
ODPO.DocNum,
ODPO.DocDate,
ODPO.CardCode,
DPO1.unitmsr,
ODPO.NumAtCard,
(DPO1.VisOrder) As 'No.',
DPO1.LineNum as 'Line Num',
DPO1.LineType as 'LineType',
ODPO.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1,
OCRD.Fax,
ODPO.LicTradNum,
OCTG.PymntGroup,
ODPO.DocDueDate,
DPO1.ItemCode,
DPO1.Dscription as 'Dscription' ,
DPO1.Quantity,
ODPO.Comments,
ODPO.DocCur,
DPO1.PriceBefDi,
CASE WHEN ODPO.DocCur = 'THB' THEN DPO1.LineTotal ELSE DPO1.TotalFrgn END AS 'LineTotal',
CASE WHEN ODPO.DocCur = 'THB' THEN ODPO.VatSum ELSE ODPO.VatSumFC END AS 'VatSum',
CASE WHEN ODPO.DocCur = 'THB' THEN ODPO.DocTotal ELSE ODPO.DocTotalFC END AS 'DocTotal',
CASE WHEN ODPO.DocCur = 'THB' THEN ODPO.DpmAmnt ELSE ODPO.DpmAmntFC END AS 'DpmAmnt',
SUM(CASE WHEN ODPO.DocCur = 'THB' THEN DPO1.LineTotal ELSE DPO1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
ODPO.dpmprcnt,
VPM1.CheckNum,
VPM1.[CheckSum] ,
VPM1.DueDate As 'Check Date',
SUM(OVPM.CashSum) As 'CashSum',
SUM(OVPM.TrsfrSum) As 'TrsfrSum',
ODSC.BankName,
ODPO.Printed,
DPO1.Project,
OCPR.E_MailL,
OCPR.Tel1,
OCPR.Name

FROM ODPO
INNER JOIN DPO1 ON ODPO.DocEntry = DPO1.DocEntry
LEFT JOIN DPO12 ON ODPO.DocEntry = DPO12.DocEntry
LEFT JOIN NNM1 ON ODPO.Series = NNM1.Series 
LEFT JOIN OCRD ON ODPO.CardCode = OCRD.CardCode
LEFT JOIN OCPR ON ODPO.CntctCode = OCPR.CntctCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ODPO.PayToCode = CRD1.[Address] AND CRD1.AdresType ='B')
LEFT JOIN OSLP ON ODPO.SlpCode = OSLP.SlpCode 
LEFT JOIN OCTG ON ODPO.GroupNum = OCTG.GroupNum 
LEFT JOIN OHEM ON ODPO.OwnerCode = OHEM.empID
LEFT JOIN OUSR ON ODPO.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON ODPO.Project = OPRJ.PrjCode
LEFT JOIN OVPM ON odpo.ReceiptNum = OVPM.docentry
LEFT JOIN VPM1 ON OVPM.docentry = VPM1.DocNum
LEFT JOIN VPM2 ON OVPM.DocEntry = VPM2.DocEntry
LEFT JOIN ODSC ON VPM1.BankCode = ODSC.BankCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ODPO.U_SLD_LVatBranch = BRANCH.Code,oadm


WHERE ODPO.DocEntry  = {?DocKey@}


GROUP BY

CONCAT(OCPR.FirstName,' ',OCPR.LastName) ,
CASE WHEN BRANCH.Code = '00000' AND ODPO.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ODPO.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND ODPO.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND ODPO.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END  ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ODPO.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND ODPO.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND ODPO.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND ODPO.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END  ,
 CASE
 WHEN ODPO.Printed = 'N' AND ODPO.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ODPO.Printed = 'N' AND ODPO.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN ODPO.Printed = 'Y' AND ODPO.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN ODPO.Printed = 'Y' AND ODPO.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END ,
NNM1.BeginStr,
ODPO.DocEntry,
ODPO.DocNum,
ODPO.DocDate,
ODPO.CardCode,
DPO1.unitmsr,
ODPO.NumAtCard,
(DPO1.VisOrder),
DPO1.LineNum,
DPO1.LineType,
ODPO.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END ,
OCRD.Phone1,
OCRD.Fax,
ODPO.LicTradNum,
OCTG.PymntGroup,
ODPO.DocDueDate,
DPO1.ItemCode,
DPO1.Dscription,
DPO1.Quantity,
ODPO.Comments,
ODPO.DocCur,
DPO1.PriceBefDi,
CASE WHEN ODPO.DocCur = 'THB' THEN DPO1.LineTotal ELSE DPO1.TotalFrgn END,
CASE WHEN ODPO.DocCur = 'THB' THEN ODPO.VatSum ELSE ODPO.VatSumFC END,
CASE WHEN ODPO.DocCur = 'THB' THEN ODPO.DocTotal ELSE ODPO.DocTotalFC END,
CASE WHEN ODPO.DocCur = 'THB' THEN ODPO.DpmAmnt ELSE ODPO.DpmAmntFC END,
ODPO.dpmprcnt,
VPM1.CheckNum,
VPM1.[CheckSum],
VPM1.DueDate,
ODSC.BankName,
ODPO.Printed,
DPO1.Project,
OCPR.E_MailL,
OCPR.Tel1,
OCPR.Name

Order by 'No.' , 'Line Num'
