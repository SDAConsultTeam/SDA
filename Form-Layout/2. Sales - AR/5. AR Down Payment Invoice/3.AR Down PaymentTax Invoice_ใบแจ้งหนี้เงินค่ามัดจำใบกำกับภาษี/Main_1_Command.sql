-- ============================================================
-- Report: 3.AR Down PaymentTax Invoice_ใบแจ้งหนี้เงินค่ามัดจำใบกำกับภาษี.rpt
Path:   2. Sales - AR\5. AR Down Payment Invoice\3.AR Down PaymentTax Invoice_ใบแจ้งหนี้เงินค่ามัดจำใบกำกับภาษี.rpt
Extracted: 2026-04-09 15:22:37
-- Source: Main Report
-- Table:  Command
-- ============================================================

---ใบแจ้ง/ใบกำกับ---
SELECT Distinct
case when OCRD.Phone2 is null then ''
  when OCRD.Phone2 is not null then ', ' + OCRD.Phone2
  END 'Phone2',
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
DPI1.Dscription as 'Dscription',
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
SUM(ORCT.CashSum) As 'CashSum',
SUM(ORCT.TrsfrSum) As 'TrsfrSum',
ODSC.BankName,
DPI1.LineType
FROM ODPI
INNER JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
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
GROUP BY
CONCAT(OCPR.FirstName,' ',OCPR.LastName) ,
CASE WHEN BRANCH.Code = '00000' AND ODPI.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ODPI.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND ODPI.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND ODPI.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END  ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ODPI.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND ODPI.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND ODPI.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND ODPI.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END  ,
 CASE
 WHEN ODPI.Printed = 'N' AND ODPI.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ODPI.Printed = 'N' AND ODPI.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN ODPI.Printed = 'Y' AND ODPI.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN ODPI.Printed = 'Y' AND ODPI.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END ,
NNM1.BeginStr,
ODPI.DocEntry,
ODPI.DocNum,
ODPI.DocDate,
ODPI.CardCode,
DPI1.unitmsr,
ODPI.NumAtCard,
(DPI1.VisOrder),
DPI1.LineNum,
ODPI.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CRD1.GlblLocNum,
OCRD.Phone1,
OCRD.Phone2,
OCRD.Fax,
ODPI.LicTradNum,
OCTG.PymntGroup,
ODPI.DocDueDate,
DPI1.ItemCode,
DPI1.Dscription,
DPI1.Quantity,
ODPI.Comments,
ODPI.DocCur,
DPI1.PriceBefDi,
DPI1.LineTotal,
ODPI.VatSum,
ODPI.VatSumFC,
ODPI.DocTotal,
ODPI.DpmAmnt,
DPI1.TotalFrgn,
ODPI.DocTotalFC,
ODPI.DpmAmntFC,
ODPI.dpmprcnt,
RCT1.CheckNum,
RCT1.[CheckSum],
RCT1.DueDate,
ODSC.BankName,
DPI1.LineType

------------------------
Order by 'No.' , 'Line No.'

