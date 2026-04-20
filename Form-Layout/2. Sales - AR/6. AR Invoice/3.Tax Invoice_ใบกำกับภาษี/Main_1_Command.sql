SELECT DISTINCT
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
CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
  END 'GLN',
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
INV1.Dscription As 'Dscription',
INV1.Quantity,
INV1.DiscPrcnt,
OINV.Comments,
OINV.DocCur,
INV1.PriceBefDi,
CASE WHEN OINV.DocCur = 'THB' THEN INV1.LineTotal ELSE INV1.TotalFrgn END AS 'LineTotal',
CASE WHEN OINV.DocCur = 'THB' THEN OINV.DiscSum ELSE OINV.DiscSumFC END AS 'DiscSum',
CASE WHEN OINV.DocCur = 'THB' THEN OINV.VatSum ELSE OINV.VatSumFC END AS 'VatSum',
CASE WHEN OINV.DocCur = 'THB' THEN OINV.DocTotal ELSE OINV.DocTotalFC END AS 'DocTotal',
CASE WHEN OINV.DocCur = 'THB' THEN OINV.DpmAmnt ELSE OINV.DpmAmntFC END AS 'DpmAmnt',
SUM(CASE WHEN OINV.DocCur = 'THB' THEN INV1.LineTotal ELSE INV1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
OINV.DiscPrcnt As 'DiscP',
INV1.LineType
,OINV.Printed
,OINV.Address2
,OSLP.SlpName,
INV1.Project,
OCPR.Name,
OCPR.Tel1,
OCPR.E_MailL,
INV12.StreetB,
INV12.StreetNoB,
INV12.BlockB,
INV12.CityB,
INV12.ZipCodeB,
INV12.CountyB,
INV12.CountryB

FROM OINV
inner JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
inner JOIN INV12 ON OINV.DocEntry = INV12.DocEntry
Left JOIN NNM1 ON OINV.Series = NNM1.Series 
Left JOIN OCRD ON OINV.CardCode = OCRD.CardCode 
LEFT JOIN OCPR ON OINV.CntctCode = OCPR.CntctCode
Left JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND OINV.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
Left JOIN OSLP ON OINV.SlpCode = OSLP.SlpCode 
Left JOIN OCTG ON OINV.GroupNum = OCTG.GroupNum 
Left JOIN OHEM ON OINV.OwnerCode = OHEM.empID
Left JOIN INV11 ON OINV.DocEntry = INV11.DocEntry AND INV11.LineType = 'D'
Left JOIN ODPI ON INV11.BASEABS = ODPI.DocEntry
Left JOIN NNM1 NNM ON ODPI.Series = NNM.Series 
LEFT JOIN OUSR ON OINV.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON INV1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OINV.U_SLD_LVatBranch = BRANCH.Code , oadm

WHERE OINV.DocEntry  = {?DocKey@}

Order by 'No.' , 'Line No.'

