-- ============================================================
-- Report: 1.AP Down Payment Invoice_ใบจ่ายเงินมัดจำ.rpt
Path:   3. Purchasing - AP\6. AP Down Payment Invoice\1.AP Down Payment Invoice_ใบจ่ายเงินมัดจำ.rpt
Extracted: 2026-04-09 15:22:45
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT Distinct
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
BRANCH.Code ,
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
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
--------------------------------------------------------------------------------------------------------

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
DPO1.LineTotal,
ODPO.VatSum,
ODPO.DocTotal,
ODPO.DpmAmnt,
DPO1.TotalFrgn,
ODPO.DocTotalFC,
ODPO.DpmAmntFC,
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
BRANCH.Code ,
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
BRANCH.[Name] ,
BRANCH.U_SLD_VTAXID ,
BRANCH.U_SLD_VComName ,
BRANCH.U_SLD_F_VComName ,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END ,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END ,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END,
BRANCH.U_SLD_ZipCode ,
BRANCH.U_SLD_Tel ,
BRANCH.U_SLD_Fax ,
BRANCH.U_SLD_Email ,
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
DPO1.LineTotal,
ODPO.VatSum,
ODPO.DocTotal,
ODPO.DpmAmnt,
DPO1.TotalFrgn,
ODPO.DocTotalFC,
ODPO.DpmAmntFC,
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

Union all
SELECT Distinct
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
BRANCH.Code ,
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
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
--------------------------------------------------------------------------------------------------------

NNM1.BeginStr,
ODPO.DocEntry,
ODPO.DocNum,
ODPO.DocDate,
ODPO.CardCode,
'' as unitmsr,
ODPO.NumAtCard,
(DPO10.AftLineNum + 0.5) As 'No.',
DPO10.LineSeq as 'Line Num',
DPO10.LineType as 'LineType',
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
'' as ItemCode,
cast(DPO10.LineText as nvarchar(4000)) as 'Dscription' ,
'0' as Quantity,
ODPO.Comments,
ODPO.DocCur,
'0' as PriceBefDi,
'0' as LineTotal,
ODPO.VatSum,
ODPO.DocTotal,
ODPO.DpmAmnt,
'0' as TotalFrgn,
ODPO.DocTotalFC,
ODPO.DpmAmntFC,
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
INNER JOIN DPO10 ON ODPO.DocEntry = DPO10.DocEntry 
Inner join dpo1 on ODPO.DocEntry = DPO10.DocEntry 
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
BRANCH.Code ,
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
BRANCH.[Name] ,
BRANCH.U_SLD_VTAXID ,
BRANCH.U_SLD_VComName ,
BRANCH.U_SLD_F_VComName ,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END ,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END ,
CASE WHEN ODPO.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END,
BRANCH.U_SLD_ZipCode ,
BRANCH.U_SLD_Tel ,
BRANCH.U_SLD_Fax ,
BRANCH.U_SLD_Email ,
NNM1.BeginStr,
ODPO.DocEntry,
ODPO.DocNum,
ODPO.DocDate,
ODPO.CardCode,
ODPO.NumAtCard,
(DPO10.AftLineNum + 0.5) ,
DPO10.LineSeq,
DPO10.LineType,
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
cast(DPO10.LineText as nvarchar(4000)),
ODPO.Comments,
ODPO.DocCur,
ODPO.VatSum,
ODPO.DocTotal,
ODPO.DpmAmnt,
ODPO.DocTotalFC,
ODPO.DpmAmntFC,
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
