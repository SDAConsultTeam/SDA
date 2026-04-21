SELECT DISTINCT
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND ORIN.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ORIN.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND ORIN.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND ORIN.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORIN.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND ORIN.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND ORIN.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND ORIN.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,

 CASE
 WHEN ORIN.Printed = 'N' AND ORIN.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ORIN.Printed = 'N' AND ORIN.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN ORIN.Printed = 'Y' AND ORIN.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN ORIN.Printed = 'Y' AND ORIN.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
ORIN.CardCode,
ORIN.[Address],
ORIN.LicTradNum,
--ORIN.U_CN_01,
--ORIN.U_CN_02,
--ORIN.U_CN_03,
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
OSLP.SlpName,
NNM1.BeginStr,
ORIN.DocNum,
ORIN.DocDate,
(RIN1.VisOrder) As 'No.',
RIN1.LineNum as 'Line No.', 
RIN1.ItemCode,
RIN1.Dscription as 'Dscription', 
RIN1.LineType as 'LineType',
RIN1.Quantity,
RIN1.PriceBefDi,
CASE WHEN ORIN.DocCur = 'THB' THEN RIN1.LineTotal ELSE RIN1.TotalFrgn END AS 'LineTotal',
CASE WHEN ORIN.DocCur = 'THB' THEN ORIN.VatSum ELSE ORIN.VatSumFC END AS 'VatSum',
CASE WHEN ORIN.DocCur = 'THB' THEN ORIN.DocTotal ELSE ORIN.DocTotalFC END AS 'DocTotal',
SUM(CASE WHEN ORIN.DocCur = 'THB' THEN RIN1.LineTotal ELSE RIN1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
ORIN.DocCur,
ORIN.DocEntry,
ORIN.CreateDate,
RIN1.unitmsr,
orin.Printed
--CASE WHEN ORIN.U_CN_05 IS not NULL THEN ''
  --WHEN ORIN.U_CN_05 IS NULL THEN T10.[Name]
  --END 'Reason_CN',
--CASE WHEN ORIN.U_CN_05 IS NULL THEN ''
  --WHEN ORIN.U_CN_05 IS NOT NULL THEN N'ลดหนี้เนื่องจาก' + ORIN.U_CN_05
  --END 'Reason_CN_Remark'
,ORIN.comments
,OINV.VatSum as 'InvVat'
,OINV.VatSumFC as 'InvVatFC',
Ref_NNM.BeginStr                          AS 'Ref_BeginStr',
Ref_OINV.DocNum                           AS 'Ref_DocNum',
Ref_OINV.DocDate                          AS 'Ref_DocDate',
CASE WHEN OINV.DocCur = 'THB' 
     THEN Ref_OINV.DocTotal 
     ELSE Ref_OINV.DocTotalFC 
END                                        AS 'Ref_DocTotal',
RIN1.Project,
OCPR.Name,
OCPR.Tel1,
OCPR.E_MailL,
RIN12.StreetB,
RIN12.StreetNoB,
RIN12.BlockB,
RIN12.CityB,
RIN12.ZipCodeB,
RIN12.CountyB,
RIN12.CountryB

FROM ORIN
INNER JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry 
INNER JOIN RIN12 ON ORIN.DocEntry = RIN12.DocEntry 
left join INV1 on RIN1.BaseEntry = INV1.DocEntry and RIN1.BaseLine = INV1.LineNum and RIN1.BaseType = 13
inner join OINV on OINV.DocEntry = inv1.DocEntry

LEFT JOIN OITM ON RIN1.ItemCode = OITM.ItemCode 
LEFT JOIN OCRD ON ORIN.CardCode = OCRD.CardCode 
LEFT JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode AND CRD1.AdresType = 'B' AND CRD1.[Address] = ORIN.PayToCode
LEFT JOIN OCPR ON ORIN.CntctCode = OCPR.CntctCode 
LEFT JOIN NNM1 ON ORIN.Series = NNM1.Series 
LEFT JOIN OCTG ON ORIN.GroupNum = OCTG.GroupNum
LEFT JOIN OHEM ON ORIN.OwnerCode = OHEM.empID
LEFT JOIN OSLP ON ORIN.SlpCode = OSLP.SlpCode
--Left join [dbo].[@SLD_REASON_RD] T10 on ORIN.U_CN_04 = T10.code
LEFT JOIN OUSR ON ORIN.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON RIN1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORIN.U_SLD_LVatBranch = BRANCH.Code 
LEFT JOIN OINV Ref_OINV ON INV1.BaseEntry = Ref_OINV.DocEntry 
                        AND INV1.BaseType  = 13  -- 13 = A/R Invoice
LEFT JOIN NNM1 Ref_NNM  ON Ref_OINV.Series = Ref_NNM.Series
, oadm

WHERE ORIN.DocEntry = {?DocKey@}

Order by 'No.' , 'Line No.'
