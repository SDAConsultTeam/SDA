-- ============================================================
-- Report: 7.DeliveryAR InvoiceTax Invoice_ใบส่งของใบแจ้งหนี้ใบกำกับภาษี_(Batch_Serial).rpt
Path:   2. Sales - AR\6. AR Invoice\7.DeliveryAR InvoiceTax Invoice_ใบส่งของใบแจ้งหนี้ใบกำกับภาษี_(Batch_Serial).rpt
Extracted: 2026-04-09 15:22:39
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
INV12.StreetB     AS '1Bill',
    INV12.StreetNoB   AS '2Bill',
    INV12.BlockB      AS '3Bill',
    INV12.CityB       AS '4Bill',
    INV12.CountyB     AS '5Bill',
    INV12.ZipCodeB    AS '6Bill',
        INV12.StreetS     AS '1Ship',
    INV12.StreetNoS   AS '2Ship',
    INV12.BlockS      AS '3Ship',
    INV12.CityS       AS '4Ship',
    INV12.CountyS     AS '5Ship',
    INV12.ZipCodeS    AS '6Ship',
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND OINV.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND OINV.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND OINV.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND OINV.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND OINV.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND OINV.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND OINV.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND OINV.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE
 WHEN OINV.Printed = 'N' AND OINV.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN OINV.Printed = 'N' AND OINV.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN OINV.Printed = 'Y' AND OINV.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN OINV.Printed = 'Y' AND OINV.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
OINV.DocEntry,
NNM1.BeginStr,
OINV.DocNum,
OINV.DocDate,
OINV.CardCode,
INV1.UnitMsr,
OINV.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1,
OCRD.Fax,
OINV.LicTradNum,
OINV.NumAtCard,
OCTG.PymntGroup,
OINV.DocDueDate,
(INV1.VisOrder) As 'No.',
INV1.LineNum as 'Line No.', 
INV1.ItemCode,
INV1.Dscription as 'Dscription',
INV1.Quantity,
OINV.Comments,
OINV.DocCur,
INV1.PriceBefDi,
CASE WHEN OINV.DocCur = 'THB' THEN INV1.LineTotal ELSE INV1.TotalFrgn END AS 'LineTotal',
CASE WHEN OINV.DocCur = 'THB' THEN OINV.DiscSum ELSE OINV.DiscSumFC END AS 'DiscSum',
CASE WHEN OINV.DocCur = 'THB' THEN OINV.VatSum ELSE OINV.VatSumFC END AS 'VatSum',
CASE WHEN OINV.DocCur = 'THB' THEN OINV.DocTotal ELSE OINV.DocTotalFC END AS 'DocTotal',
CASE WHEN OINV.DocCur = 'THB' THEN OINV.DpmAmnt ELSE OINV.DpmAmntFC END AS 'DpmAmnt',
SUM(CASE WHEN OINV.DocCur = 'THB' THEN INV1.LineTotal ELSE INV1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
INV1.LineType,
OINV.Address2,
OSLP.SlpName,
OINV.Printed

FROM OINV
INNER JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
LEFT JOIN INV12 ON OINV.DocEntry = INV12.DocEntry
LEFT JOIN NNM1 ON OINV.Series = NNM1.Series 
LEFT JOIN OCRD ON OINV.CardCode = OCRD.CardCode
LEFT JOIN OCPR ON OINV.CntctCode = OCPR.CntctCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND OINV.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT JOIN OSLP ON OINV.SlpCode = OSLP.SlpCode 
LEFT JOIN OCTG ON OINV.GroupNum = OCTG.GroupNum 
LEFT JOIN OHEM ON OINV.OwnerCode = OHEM.empID
LEFT JOIN INV11 ON OINV.DocEntry = INV11.DocEntry AND INV11.LineType = 'D'
LEFT JOIN ODPI ON INV11.BASEABS = ODPI.DocEntry
LEFT JOIN NNM1 NNM ON ODPI.Series = NNM.Series 
LEFT JOIN OUSR ON OINV.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON INV1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OINV.U_SLD_LVatBranch = BRANCH.Code, oadm
 
WHERE OINV.DocEntry = {?DocKey@}

Order by 'No.' , 'Line No.'

