SELECT DISTINCT
CASE WHEN BRANCH.Code = '00000' AND OPOR.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND OPOR.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND OPOR.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND OPOR.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND OPOR.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND OPOR.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND OPOR.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND OPOR.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE
 WHEN OPOR.Printed = 'N' AND OPOR.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN OPOR.Printed = 'N' AND OPOR.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN OPOR.Printed = 'Y' AND OPOR.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN OPOR.Printed = 'Y' AND OPOR.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
OPOR.DocEntry,
CAST(OPOR.Address2 AS nvarchar(max)) AS 'Address2', 
CAST(OPOR.[Address] AS nvarchar(max)) AS 'Address',
OCRD.U_SLD_Title,
CAST(OCRD.U_SLD_FullName AS nvarchar(max)) AS 'U_SLD_FullName',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1, 
ISNULL(OCRD.Fax,'') AS 'Fax',
OCRD.LicTradNum,
NNM1.BeginStr, 
OPOR.DocNum,
OPOR.CardCode, 
OPOR.DocDate, 
OPOR.DocDueDate, 
OCTG.PymntGroup, 
CAST(POR1.VisOrder AS FLOAT) AS 'No.', 
POR1.LineNum as 'Line No.', 
POR1.ItemCode, 
CAST(POR1.Dscription AS nvarchar(max)) AS 'Dscription', 
POR1.Quantity,
POR1.PriceBefDi, 
POR1.DiscPrcnt,
CASE WHEN OPOR.DocCur = 'THB' THEN POR1.LineTotal ELSE POR1.TotalFrgn END AS 'LineTotal',
CASE WHEN OPOR.DocCur = 'THB' THEN OPOR.DiscSum ELSE OPOR.DiscSumFC END AS 'DiscSum',
CASE WHEN OPOR.DocCur = 'THB' THEN OPOR.VatSum ELSE OPOR.VatSumFC END AS 'VatSum',
OPOR.DiscPrcnt,
OPOR.DocCur,
CASE WHEN OPOR.DocCur = 'THB' THEN OPOR.DocTotal ELSE OPOR.DocTotalFC END AS 'DocTotal',
SUM(CASE WHEN OPOR.DocCur = 'THB' THEN POR1.LineTotal ELSE POR1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
POR1.unitmsr,
CAST(OPOR.Comments AS nvarchar(max)) AS 'Comments',
POR1.LineType,
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
OCRD.cntctPrsn,
OCRD.E_mail,
POR1.U_SLD_Dis_Amount,
CAST(ocrd.MailAddres AS nvarchar(max)) AS 'MailAddres',
ocrd.Country,
POR1.Project, 
CAST(por12.StreetS AS nvarchar(max)) as StreetS, CAST(por12.StreetNoS AS nvarchar(max)) as StreetS,CAST(por12.BlockS AS nvarchar(max)) as BlockS, CAST(por12.BuildingS AS nvarchar(max)) as BuildingS, 
CAST(por12.CityS AS nvarchar(max)) as CityS, por12.ZipCodeS, CAST(por12.CountyS AS nvarchar(max)) as CountyS, por12.StateS,
CAST(por12.StreetB AS nvarchar(max)) as StreetB, CAST(por12.StreetNoB AS nvarchar(max)) as StreetNoB,CAST(por12.BlockB AS nvarchar(max)) as BlockB, CAST(por12.BuildingB AS nvarchar(max)) as BuildingB, 
CAST(por12.CityB AS nvarchar(max)) as CityB, por12.ZipCodeB, CAST(por12.CountyB AS nvarchar(max)) as CountyB, por12.StateB,
OCPR.Name,
OCPR.Tel1,
OCPR.E_MailL

FROM OPOR   
INNER JOIN POR1 ON OPOR.DocEntry = POR1.DocEntry 
INNER JOIN POR12 ON OPOR.DocEntry = POR12.DocEntry 
LEFT JOIN OITM ON POR1.ItemCode = OITM.ItemCode 
LEFT JOIN OCRD ON OPOR.CardCode = OCRD.CardCode 
LEFT JOIN CRD1 ON (OPOR.[PaytoCode] = CRD1.[Address] AND OPOR.CardCode = CRD1.CardCode and CRD1.AdresType = 'B')
LEFT JOIN OCPR ON OPOR.CntctCode = OCPR.CntctCode 
LEFT JOIN NNM1 ON OPOR.Series = NNM1.Series 
LEFT JOIN OCTG ON OPOR.GroupNum = OCTG.GroupNum
LEFT JOIN OHEM ON OPOR.OwnerCode = OHEM.empID
LEFT JOIN OSLP ON OPOR.SlpCode = OSLP.SlpCode
LEFT JOIN POR12 ON OPOR.DocEntry = POR12.DocEntry
LEFT JOIN OUSR ON OPOR.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON POR1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OPOR.U_SLD_LVatBranch = BRANCH.Code, oadm
WHERE OPOR.DocEntry = 9
ORDER BY 'No.' , 'Line No.'