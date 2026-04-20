SELECT DISTINCT
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND ORPC.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND ORPC.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND ORPC.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND ORPC.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORPC.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND ORPC.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND ORPC.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND ORPC.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE
 WHEN ORPC.Printed = 'N' AND ORPC.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ORPC.Printed = 'N' AND ORPC.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN ORPC.Printed = 'Y' AND ORPC.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN ORPC.Printed = 'Y' AND ORPC.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
ORPC.[Address],
--ORPC.U_CN_01,
--ORPC.U_CN_02,
--ORPC.U_CN_03,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
--CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
  --WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
  --END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1, 
OCRD.Fax, 
OSLP.SlpName,
NNM1.BeginStr, 
ORPC.DocEntry, 
ORPC.DocNum, 
ORPC.DocDate,
--CASE WHEN ORPC.U_CN_05 IS not NULL THEN ''
  --WHEN ORPC.U_CN_05 IS NULL THEN T10.[Name]
  --END 'Reason_DB',
--CASE WHEN ORPC.U_CN_05 IS NULL THEN ''
  --WHEN ORPC.U_CN_05 IS NOT NULL THEN N'ลดหนี้เนื่องจาก' + ORPC.U_CN_05
  --END 'Reason_CN_Remark',

(RPC1.VisOrder) AS 'No.', 
RPC1.LineNum as 'Line No.', 

RPC1.ItemCode, 

RPC1.Dscription as 'Dscription', 
RPC1.LineType as 'LineType',

RPC1.Quantity, 
RPC1.UomCode,
RPC1.unitMsr,  
RPC1.PriceBefDi,
CASE WHEN ORPC.DocCur = 'THB' THEN RPC1.LineTotal ELSE RPC1.TotalFrgn END AS 'LineTotal',
CASE WHEN ORPC.DocCur = 'THB' THEN ORPC.VatSum ELSE ORPC.VatSumFC END AS 'VatSum',
ORPC.DocCur,
CASE WHEN ORPC.DocCur = 'THB' THEN ORPC.DocTotal ELSE ORPC.DocTotalFC END AS 'DocTotal',
SUM(CASE WHEN ORPC.DocCur = 'THB' THEN RPC1.LineTotal ELSE RPC1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
OCRD.LicTradNum,
ORPC.Printed,
ORPC.Comments,
RPC1.Project,
RPC12.StreetB,
RPC12.StreetNoB,
RPC12.BlockB,
RPC12.CityB,
RPC12.ZipcodeB,
RPC12.CountyB,
RPC12.CountryB

FROM ORPC 
INNER JOIN RPC1 ON ORPC.DocEntry = RPC1.DocEntry 
INNER JOIN RPC12 ON ORPC.DocEntry = RPC12.DocEntry 
LEFT JOIN OITM ON RPC1.ItemCode = OITM.ItemCode 
LEFT JOIN OCRD ON ORPC.CardCode = OCRD.CardCode 
LEFT JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode AND CRD1.AdresType = 'B' AND CRD1.[Address] = ORPC.PayToCode
LEFT JOIN OCPR ON ORPC.CntctCode = OCPR.CntctCode 
LEFT JOIN NNM1 ON ORPC.Series = NNM1.Series 
LEFT JOIN OCTG ON ORPC.GroupNum = OCTG.GroupNum
LEFT JOIN OHEM ON ORPC.OwnerCode = OHEM.empID
LEFT JOIN OSLP ON ORPC.SlpCode = OSLP.SlpCode
--LEFT JOIN [dbo].[@SLD_REASON_RD] T10 ON ORPC.U_CN_04 = T10.code
LEFT JOIN CRD1 CRD ON (ORPC.PaytoCode = CRD.[Address] AND ORPC.CardCode = CRD.CardCode AND CRD.AdresType ='B' ) 
LEFT JOIN OUSR ON ORPC.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON RPC1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORPC.U_SLD_LVatBranch = BRANCH.Code , oadm

WHERE ORPC.DocEntry  = 1
Order by 'No.' , 'Line No.'