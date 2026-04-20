-- ============================================================
-- Report: 2.Incoming Payments_ใบเสร็จรับเงินใบกำกับภาษี.rpt
Path:   4. Banking\1. Incoming Payments\2.Incoming Payments_ใบเสร็จรับเงินใบกำกับภาษี.rpt
Extracted: 2026-04-09 15:22:48
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
ORCT.Comments,
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,

 CASE 
 WHEN ORCT.Printed = 'N' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Original'
 WHEN ORCT.Printed = 'N' AND ORCT.DocCurr = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Copy'  
 WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
CONVERT(NVARCHAR,ORCT.DocNum) AS 'RecNo',
(RCT2.InvoiceId+1) As 'No.',
ORCT.DocENTRY,
ORCT.TaxDate,  
ORCT.CardCode, 
ORCT.[Address], 
ORCT.DocCurr AS 'RctDocCurr',
SupR_Vat.VatSum,
SupR_Vat.VatSumFC,
--(OINV.DocTotal-OINV.VatSum) As 'DocTotal',
--(OINV.DocTotalFC-OINV.VatSumFC) As 'DoctotalFC',
SupR_D.DocTotal,
SupR_D.DocTotalFC, 
ORCT.DocTotal As 'T Total',
ORCT.DocTotalFC As 'F Total', 
ORCT.CounterRef, 
ORCT.DocDueDate,
OCRD.LicTradNum,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
--CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
--  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
--  END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1,
OCRD.Fax,	
RCT2.SumApplied, 
RCT2.AppliedFC,
CONVERT(NVARCHAR,OINV.DocNum) AS 'INVNo', 
OINV.TaxDate AS 'INVDate', 
OINV.DocDueDate AS 'INVDueDate', 
T3.BeginStr AS 'RECBeginStr',	
NNM1.BeginStr AS 'INVBeginStr', 
CONVERT(NVARCHAR(100),OCRD.Building ) As 'BPBuilding' , 
OCTG.PymntGroup,
ORCT.TrsfrSum,
ORCT.CashSum,
RCT1.[CheckSum],
(RCT1.LineID+1) As 'LineID',
RCT1.CheckNum,
ODSC.BankName,
RCT1.DueDate

FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum

LEFT JOIN (SELECT -------DocTotal-------
DocT.DocEntry,
SUM(DocT.DocTotal) As 'DocTotal',
SUM(DocT.DoctotalFC) As 'DocTotalFC'
FROM

(SELECT DISTINCT -----OINV----
ORCT.DocEntry,
(OINV.DocTotal-OINV.VatSum) As 'DocTotal',
(OINV.DocTotalFC-OINV.VatSumFC) As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
WHERE RCT2.InvType = '13' 
UNION 
SELECT	DISTINCT ----CN-----
ORCT.DocEntry,
(ORIN.DocTotal-ORIN.VatSum)*-1 As 'DocTotal',
(ORIN.DocTotalFC-ORIN.VatSumFC)*-1 As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN ORIN ON RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
WHERE RCT2.InvType = '14'
UNION
SELECT	DISTINCT ----Down---
ORCT.DocEntry,
(ODPI.DocTotal-ODPI.VatSum) As 'DocTotal',
(ODPI.DocTotalFC-ODPI.VatSumFC) As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODPI ON RCT2.baseAbs = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
WHERE RCT2.InvType = '203'
UNION
SELECT	DISTINCT  ----JE----
ORCT.DocEntry,
RCT2.SumApplied As 'DocTotal',
RCT2.AppliedFC As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
WHERE RCT2.InvType = '30'
) As DocT
GROUP BY 
DocT.DocEntry) As SupR_D ON ORCT.DocEntry = SupR_D.DocEntry 

LEFT JOIN (SELECT ------------VatTotal----------
Vat.DocEntry,
SUM(Vat.VatSum) As 'VatSum',
SUM(Vat.VatSumFC) As 'VatSumFC'

FROM

(SELECT DISTINCT -----OINV----
ORCT.DocEntry,
(OINV.VatSum) As 'VatSum',
(OINV.VatSumFC) As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
WHERE RCT2.InvType = '13' 
UNION 
SELECT	DISTINCT ----CN-----
ORCT.DocEntry,
(ORIN.VatSum)*-1 As 'VatSum',
(ORIN.VatSumFC)*-1 As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN ORIN ON RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
WHERE RCT2.InvType = '14'
UNION
SELECT	DISTINCT ----Down---
ORCT.DocEntry,
(ODPI.VatSum) As 'VatSum',
(ODPI.VatSumFC) As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODPI ON RCT2.baseAbs = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
WHERE RCT2.InvType = '203'
UNION
SELECT	DISTINCT  ----JE----
ORCT.DocEntry,
ORCT.VatSum As 'VatSum',
ORCT.VatSumFC As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
WHERE RCT2.InvType = '30'
) As Vat
GROUP BY 
Vat.DocEntry) SupR_Vat ON ORCT.DocEntry = SupR_Vat.DocEntry

LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN OACT ON ORCT.CashAcct = OACT.AcctCode 
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
LEFT OUTER JOIN NNM1 T3 ON ORCT.Series = T3.Series
LEFT OUTER JOIN NNM1 ON OINV.Series = NNM1.Series
LEFT OUTER JOIN OCRD ON ORCT.CardCode = OCRD.CardCode
LEFT OUTER JOIN OCPR ON ORCT.CardCode = OCPR.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORCT.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT OUTER  JOIN OCRG ON OCRD.GroupCode = OCRG.GroupCode
LEFT OUTER JOIN INV1 T7 ON OINV.DocEntry = T7.DocEntry
LEFT OUTER JOIN RCT4 ON ORCT.DocEntry = RCT4.DocNum
LEFT OUTER JOIN OJDT ON ORCT.TransId = OJDT.TransId
LEFT JOIN OPRJ ON INV1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON ORCT.UserSign = OUSR.USERID
LEFT JOIN OCTG ON OCRD.GroupNum = OCTG.GroupNum
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORCT.U_SLD_VatBranch = BRANCH.Code ,oadm

WHERE RCT2.InvType = '13' 
AND ORCT.DocENTRY  = '{?DocKey@}'   

UNION 

SELECT	DISTINCT ----CN-----
ORCT.Comments,
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,

 CASE 
 WHEN ORCT.Printed = 'N' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Original'
 WHEN ORCT.Printed = 'N' AND ORCT.DocCurr = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Copy'  
 WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
CONVERT(NVARCHAR,ORCT.DocNum) AS 'RecNo',
(RCT2.InvoiceId+1) As 'No.',
ORCT.DocENTRY,
ORCT.TaxDate,  
ORCT.CardCode, 
ORCT.[Address], 
ORCT.DocCurr AS 'RctDocCurr', 
SupR_Vat.VatSum,
SupR_Vat.VatSumFC,
--(ORIN.DocTotal-ORIN.VatSum)*-1 As 'DocTotal',
--(ORIN.DocTotalFC-ORIN.VatSumFC)*-1 As 'DoctotalFC',
SupR_D.DocTotal,
SupR_D.DocTotalFC, 
ORCT.DocTotal As 'T Total',
ORCT.DocTotalFC As 'F Total', 
ORCT.CounterRef, 
ORCT.DocDueDate,
OCRD.LicTradNum,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
--CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
--  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
--  END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1,
OCRD.Fax,	
(RCT2.SumApplied*-1)As 'SumApplied', 
(RCT2.AppliedFC*-1) As 'AppliedFC',
CONVERT(NVARCHAR,ORIN.DocNum) AS 'INVNo', 
ORIN.TaxDate AS 'INVDate', 
ORIN.DocDueDate AS 'INVDueDate', 
NNM1.BeginStr AS 'RECBeginStr',		
T4.BeginStr AS 'INVBeginStr', 
CONVERT(NVARCHAR(100),OCRD.Building ) As 'BPBuilding' , 
OCTG.PymntGroup,
ORCT.TrsfrSum,
ORCT.CashSum,
RCT1.[CheckSum],
(RCT1.LineID+1) As 'LineID',
RCT1.CheckNum,
ODSC.BankName,
RCT1.DueDate

FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN (SELECT 
DocT.DocEntry,
SUM(DocT.DocTotal) As 'DocTotal',
SUM(DocT.DoctotalFC) As 'DocTotalFC'
FROM

(SELECT DISTINCT -----OINV----
ORCT.DocEntry,
(OINV.DocTotal-OINV.VatSum) As 'DocTotal',
(OINV.DocTotalFC-OINV.VatSumFC) As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
WHERE RCT2.InvType = '13' 
UNION 
SELECT	DISTINCT ----CN-----
ORCT.DocEntry,
(ORIN.DocTotal-ORIN.VatSum)*-1 As 'DocTotal',
(ORIN.DocTotalFC-ORIN.VatSumFC)*-1 As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN ORIN ON RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
WHERE RCT2.InvType = '14'
UNION
SELECT	DISTINCT ----Down---
ORCT.DocEntry,
(ODPI.DocTotal-ODPI.VatSum) As 'DocTotal',
(ODPI.DocTotalFC-ODPI.VatSumFC) As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODPI ON RCT2.baseAbs = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
WHERE RCT2.InvType = '203'
UNION
SELECT	DISTINCT  ----JE----
ORCT.DocEntry,
RCT2.SumApplied As 'DocTotal',
RCT2.AppliedFC As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
WHERE RCT2.InvType = '30'
) As DocT
GROUP BY 
DocT.DocEntry) As SupR_D ON ORCT.DocEntry = SupR_D.DocEntry 

LEFT JOIN (SELECT ------------VatTotal----------
Vat.DocEntry,
SUM(Vat.VatSum) As 'VatSum',
SUM(Vat.VatSumFC) As 'VatSumFC'

FROM

(SELECT DISTINCT -----OINV----
ORCT.DocEntry,
(OINV.VatSum) As 'VatSum',
(OINV.VatSumFC) As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
WHERE RCT2.InvType = '13' 
UNION 
SELECT	DISTINCT ----CN-----
ORCT.DocEntry,
(ORIN.VatSum)*-1 As 'VatSum',
(ORIN.VatSumFC)*-1 As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN ORIN ON RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
WHERE RCT2.InvType = '14'
UNION
SELECT	DISTINCT ----Down---
ORCT.DocEntry,
(ODPI.VatSum) As 'VatSum',
(ODPI.VatSumFC) As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODPI ON RCT2.baseAbs = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
WHERE RCT2.InvType = '203'
UNION
SELECT	DISTINCT  ----JE----
ORCT.DocEntry,
ORCT.VatSum As 'VatSum',
ORCT.VatSumFC As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
WHERE RCT2.InvType = '30'
) As Vat
GROUP BY 
Vat.DocEntry) SupR_Vat ON ORCT.DocEntry = SupR_Vat.DocEntry

LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN OACT T9 ON ORCT.CashAcct = T9.AcctCode 
LEFT OUTER JOIN ORIN ON RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
LEFT OUTER JOIN NNM1 ON ORCT.Series = NNM1.Series
LEFT OUTER JOIN NNM1 T4 ON ORIN.Series = T4.Series
LEFT OUTER JOIN OCRD ON ORCT.CardCode = OCRD.CardCode
LEFT OUTER JOIN OCPR ON ORCT.CardCode = OCPR.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORCT.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT OUTER  JOIN OCRG ON OCRD.GroupCode = OCRG.GroupCode
LEFT OUTER JOIN RIN1 T7 ON ORIN.DocEntry = T7.DocEntry
LEFT OUTER JOIN RCT4 ON ORCT.DocEntry = RCT4.DocNum
LEFT OUTER JOIN OJDT ON ORCT.TransId = OJDT.TransId
LEFT JOIN  OPRJ ON RIN1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON ORCT.UserSign = OUSR.USERID
LEFT JOIN OCTG ON OCRD.GroupNum = OCTG.GroupNum
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORCT.U_SLD_VatBranch = BRANCH.Code , oadm

WHERE RCT2.InvType = '14'
AND ORCT.DocENTRY  = '{?DocKey@}' 

UNION
SELECT	DISTINCT
ORCT.Comments,
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,

 CASE 
 WHEN ORCT.Printed = 'N' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Original'
 WHEN ORCT.Printed = 'N' AND ORCT.DocCurr = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Copy'  
 WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
CONVERT(NVARCHAR,ORCT.DocNum) AS 'RecNo',
(RCT2.InvoiceId+1) As 'No.',
ORCT.DocENTRY,
ORCT.TaxDate, 
ORCT.CardCode, 
ORCT.[Address], 
ORCT.DocCurr AS 'RctDocCurr',  
SupR_Vat.VatSum,
SupR_Vat.VatSumFC,
--(ODPI.DocTotal-ODPI.VatSum) As 'DocTotal',
--(ODPI.DocTotalFC-ODPI.VatSumFC) As 'DoctotalFC',
SupR_D.DocTotal,
SupR_D.DocTotalFC, 
ORCT.DocTotal As 'T Total',
ORCT.DocTotalFC As 'F Total', 
ORCT.CounterRef, 
ORCT.DocDueDate,
OCRD.LicTradNum,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
--CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
--  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
--  END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1,
OCRD.Fax,		
RCT2.SumApplied, 
RCT2.AppliedFC,
CONVERT(NVARCHAR,OINV.DocNum) AS 'INVNo', 
ODPI.TaxDate AS 'INVDate',
ODPI.DocDueDate AS 'INVDueDate', 
NNM1.BeginStr AS 'RECBeginStr',
T3.BeginStr AS 'INVBeginStr', 
CONVERT(NVARCHAR(100),OCRD.Building ) As 'BPBuilding', 
OCTG.PymntGroup,
ORCT.TrsfrSum,
ORCT.CashSum,
RCT1.[CheckSum],
(RCT1.LineID+1) As 'LineID',
RCT1.CheckNum,
ODSC.BankName,
RCT1.DueDate

FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN (SELECT 
DocT.DocEntry,
SUM(DocT.DocTotal) As 'DocTotal',
SUM(DocT.DoctotalFC) As 'DocTotalFC'
FROM

(SELECT DISTINCT -----OINV----
ORCT.DocEntry,
(OINV.DocTotal-OINV.VatSum) As 'DocTotal',
(OINV.DocTotalFC-OINV.VatSumFC) As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
WHERE RCT2.InvType = '13' 
UNION 
SELECT	DISTINCT ----CN-----
ORCT.DocEntry,
(ORIN.DocTotal-ORIN.VatSum)*-1 As 'DocTotal',
(ORIN.DocTotalFC-ORIN.VatSumFC)*-1 As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN ORIN ON RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
WHERE RCT2.InvType = '14'
UNION
SELECT	DISTINCT ----Down---
ORCT.DocEntry,
(ODPI.DocTotal-ODPI.VatSum) As 'DocTotal',
(ODPI.DocTotalFC-ODPI.VatSumFC) As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODPI ON RCT2.baseAbs = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
WHERE RCT2.InvType = '203'
UNION
SELECT	DISTINCT  ----JE----
ORCT.DocEntry,
RCT2.SumApplied As 'DocTotal',
RCT2.AppliedFC As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
WHERE RCT2.InvType = '30'
) As DocT
GROUP BY 
DocT.DocEntry) As SupR_D ON ORCT.DocEntry = SupR_D.DocEntry 

LEFT JOIN (SELECT ------------VatTotal----------
Vat.DocEntry,
SUM(Vat.VatSum) As 'VatSum',
SUM(Vat.VatSumFC) As 'VatSumFC'

FROM

(SELECT DISTINCT -----OINV----
ORCT.DocEntry,
(OINV.VatSum) As 'VatSum',
(OINV.VatSumFC) As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
WHERE RCT2.InvType = '13' 
UNION 
SELECT	DISTINCT ----CN-----
ORCT.DocEntry,
(ORIN.VatSum)*-1 As 'VatSum',
(ORIN.VatSumFC)*-1 As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN ORIN ON RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
WHERE RCT2.InvType = '14'
UNION
SELECT	DISTINCT ----Down---
ORCT.DocEntry,
(ODPI.VatSum) As 'VatSum',
(ODPI.VatSumFC) As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODPI ON RCT2.baseAbs = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
WHERE RCT2.InvType = '203'
UNION
SELECT	DISTINCT  ----JE----
ORCT.DocEntry,
ORCT.VatSum As 'VatSum',
ORCT.VatSumFC As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
WHERE RCT2.InvType = '30'
) As Vat
GROUP BY 
Vat.DocEntry) SupR_Vat ON ORCT.DocEntry = SupR_Vat.DocEntry

LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN OACT ON ORCT.CashAcct = OACT.AcctCode 
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
LEFT JOIN ODPI ON RCT2.baseAbs = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
LEFT OUTER JOIN NNM1 ON ORCT.Series = NNM1.Series
LEFT OUTER JOIN NNM1 T3 ON ODPI.Series = T3.Series
LEFT OUTER JOIN OCRD ON ORCT.CardCode = OCRD.CardCode
LEFT OUTER JOIN OCPR ON ORCT.CardCode = OCPR.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORCT.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT OUTER  JOIN OCRG ON OCRD.GroupCode = OCRG.GroupCode
LEFT OUTER JOIN INV1 T7 ON OINV.DocEntry = T7.DocEntry
LEFT OUTER JOIN RCT4 ON ORCT.DocEntry = RCT4.DocNum
LEFT OUTER JOIN OJDT ON ORCT.TransId = OJDT.TransId
LEFT JOIN OPRJ ON INV1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON ORCT.UserSign = OUSR.USERID
LEFT JOIN OCTG ON OCRD.GroupNum = OCTG.GroupNum
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORCT.U_SLD_VatBranch = BRANCH.Code , oadm

WHERE RCT2.InvType = '203'
AND ORCT.DocENTRY  = '{?DocKey@}' 

UNION
SELECT	DISTINCT
ORCT.Comments,
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,

 CASE 
 WHEN ORCT.Printed = 'N' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Original'
 WHEN ORCT.Printed = 'N' AND ORCT.DocCurr = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Copy'  
 WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
CONVERT(NVARCHAR,ORCT.DocNum) AS 'RecNo',
(RCT2.InvoiceId+1) As 'No.',
ORCT.DocENTRY,
ORCT.TaxDate, 
ORCT.CardCode, 
ORCT.[Address], 
ORCT.DocCurr AS 'RctDocCurr', 
SupR_Vat.VatSum,
SupR_Vat.VatSumFC,
--RCT2.SumApplied As 'DocTotal',
--RCT2.AppliedFC As 'DoctotalFC',
SupR_D.DocTotal,
SupR_D.DocTotalFC, 
ORCT.DocTotal As 'T Total',
ORCT.DocTotalFC As 'F Total', 
ORCT.CounterRef, 
ORCT.DocDueDate,
OCRD.LicTradNum,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
--CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
--  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
--  END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1,
OCRD.Fax,		
RCT2.SumApplied, 
RCT2.AppliedFC,
CONVERT(NVARCHAR,OJDT.Number) AS 'INVNo', 
OJDT.TaxDate AS 'INVDate',
OJDT.DueDate AS 'INVDueDate', 
NNM1.BeginStr AS 'RECBeginStr',
T3.BeginStr AS 'INVBeginStr', 
CONVERT(NVARCHAR(100),OCRD.Building ) As 'BPBuilding', 
OCTG.PymntGroup,
ORCT.TrsfrSum,
ORCT.CashSum,
RCT1.[CheckSum],
(RCT1.LineID+1) As 'LineID',
RCT1.CheckNum,
ODSC.BankName,
RCT1.DueDate

FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN (SELECT 
DocT.DocEntry,
SUM(DocT.DocTotal) As 'DocTotal',
SUM(DocT.DoctotalFC) As 'DocTotalFC'
FROM

(SELECT DISTINCT -----OINV----
ORCT.DocEntry,
(OINV.DocTotal-OINV.VatSum) As 'DocTotal',
(OINV.DocTotalFC-OINV.VatSumFC) As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
WHERE RCT2.InvType = '13' 
UNION 
SELECT	DISTINCT ----CN-----
ORCT.DocEntry,
(ORIN.DocTotal-ORIN.VatSum)*-1 As 'DocTotal',
(ORIN.DocTotalFC-ORIN.VatSumFC)*-1 As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN ORIN ON RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
WHERE RCT2.InvType = '14'
UNION
SELECT	DISTINCT ----Down---
ORCT.DocEntry,
(ODPI.DocTotal-ODPI.VatSum) As 'DocTotal',
(ODPI.DocTotalFC-ODPI.VatSumFC) As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODPI ON RCT2.baseAbs = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
WHERE RCT2.InvType = '203'
UNION
SELECT	DISTINCT  ----JE----
ORCT.DocEntry,
RCT2.SumApplied As 'DocTotal',
RCT2.AppliedFC As 'DoctotalFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
WHERE RCT2.InvType = '30'
) As DocT
GROUP BY 
DocT.DocEntry) As SupR_D ON ORCT.DocEntry = SupR_D.DocEntry 

LEFT JOIN (SELECT ------------VatTotal----------
Vat.DocEntry,
SUM(Vat.VatSum) As 'VatSum',
SUM(Vat.VatSumFC) As 'VatSumFC'

FROM

(SELECT DISTINCT -----OINV----
ORCT.DocEntry,
(OINV.VatSum) As 'VatSum',
(OINV.VatSumFC) As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
WHERE RCT2.InvType = '13' 
UNION 
SELECT	DISTINCT ----CN-----
ORCT.DocEntry,
(ORIN.VatSum)*-1 As 'VatSum',
(ORIN.VatSumFC)*-1 As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN ORIN ON RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
WHERE RCT2.InvType = '14'
UNION
SELECT	DISTINCT ----Down---
ORCT.DocEntry,
(ODPI.VatSum) As 'VatSum',
(ODPI.VatSumFC) As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODPI ON RCT2.baseAbs = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
WHERE RCT2.InvType = '203'
UNION
SELECT	DISTINCT  ----JE----
ORCT.DocEntry,
ORCT.VatSum As 'VatSum',
ORCT.VatSumFC As 'VatSumFC'
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
WHERE RCT2.InvType = '30'
) As Vat
GROUP BY 
Vat.DocEntry) SupR_Vat ON ORCT.DocEntry = SupR_Vat.DocEntry

LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN OACT ON ORCT.CashAcct = OACT.AcctCode 
LEFT JOIN OINV ON RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
LEFT OUTER JOIN OJDT ON RCT2.baseAbs = OJDT.TransId
LEFT OUTER JOIN NNM1 ON ORCT.Series = NNM1.Series
LEFT OUTER JOIN NNM1 T3 ON OJDT.Series = T3.Series
LEFT OUTER JOIN OCRD ON ORCT.CardCode = OCRD.CardCode	
LEFT OUTER JOIN OCPR ON ORCT.CardCode = OCPR.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORCT.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT OUTER  JOIN OCRG ON OCRD.GroupCode = OCRG.GroupCode
LEFT OUTER JOIN INV1 T7 ON OINV.DocEntry = T7.DocEntry
LEFT OUTER JOIN RCT4 ON ORCT.DocEntry = RCT4.DocNum
LEFT JOIN OPRJ ON INV1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON ORCT.UserSign = OUSR.USERID
LEFT JOIN OCTG ON OCRD.GroupNum = OCTG.GroupNum
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORCT.U_SLD_VatBranch = BRANCH.Code, oadm

WHERE RCT2.InvType = '30'
AND ORCT.DocENTRY  = '{?DocKey@}' 

ORDER BY 13
