SELECT distinct
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
BRANCH.Code ,
CASE WHEN BRANCH.Code = '00000' AND ORPD.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND ORPD.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ORPD.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ORPD.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORPD.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ORPD.DocCur <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ORPD.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ORPD.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE 
 WHEN ORPD.Printed = 'N' AND ORPD.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ORPD.Printed = 'N' AND ORPD.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ORPD.Printed = 'Y' AND ORPD.DocCur <> OADM.MainCurncy THEN 'Copy'  
 WHEN ORPD.Printed = 'Y' AND ORPD.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
--------------------------------------------------------------------------
ORPD.DocEntry,
(RPD1.VisOrder) AS 'No.',
RPD1.LineNum as 'Line No.', 
ORPD.[Address],  
OCRD.LicTradNum, 
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1 , 
OCRD.Fax,  
ORPD.NumAtCard, 
ORPD.Comments,
RPD1.ItemCode,
RPD1.dscription as 'Dscription', 
RPD1.Quantity, 
ORPD.DocDate, 
ORPD.DocNum, 
NNM1.BeginStr,
ORPD.CreateDate,
ORPD.CardCode,
ORPD.U_SLD_Returnreason,
RPD1.unitMsr,
RPD1.LineType,
rpD1.Project,
OCRD.CntctPrsn,
OCrd.E_Mail,
ocrd.phone1,
ocrd.phone2,
CAST(rpd12.StreetB AS nvarchar(max)) as StreetB, CAST(rpd12.StreetNoB AS nvarchar(max)) as StreetNoB,CAST(rpd12.BlockB AS nvarchar(max)) as BlockB, CAST(rpd12.BuildingB AS nvarchar(max)) as BuildingB, 
CAST(rpd12.CityB AS nvarchar(max)) as CityB, rpd12.ZipCodeB, CAST(rpd12.CountyB AS nvarchar(max)) as CountyB, rpd12.StateB

FROM ORPD 
INNER JOIN RPD1 ON ORPD.DocEntry = RPD1.DocEntry
INNER JOIN RPD12 ON ORPD.DocEntry = RPD12.DocEntry
LEFT JOIN NNM1 ON ORPD.Series = NNM1.Series
LEFT JOIN OUSR ON ORPD.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON RPD1.Project = OPRJ.PrjCode
LEFT JOIN OCRD ON ORPD.CardCode = OCRD.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORPD.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT JOIN OCPR ON OCRD.CardCode = OCPR.CardCode
LEFT JOIN OITM ON RPD1.ItemCode = OITM.ItemCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORPD.U_SLD_LVatBranch = BRANCH.Code, OADM

WHERE ORPD.DocEntry = {?DocKey@}

Union all
SELECT distinct
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
BRANCH.Code ,
CASE WHEN BRANCH.Code = '00000' AND ORPD.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND ORPD.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ORPD.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ORPD.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORPD.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ORPD.DocCur <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ORPD.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ORPD.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE 
 WHEN ORPD.Printed = 'N' AND ORPD.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ORPD.Printed = 'N' AND ORPD.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ORPD.Printed = 'Y' AND ORPD.DocCur <> OADM.MainCurncy THEN 'Copy'  
 WHEN ORPD.Printed = 'Y' AND ORPD.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN ORPD.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
--------------------------------------------------------------------------
ORPD.DocEntry,
RPD10.AftLineNum + 0.5 As 'No.',
RPD10.LineSeq as 'Line No.', 
ORPD.[Address],  
OCRD.LicTradNum, 
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1 , 
OCRD.Fax,  
ORPD.NumAtCard, 
ORPD.Comments,
'' as ItemCode,
CAST(RPD10.LineText AS NVARCHAR(4000)) As 'Dscription',
'0' as Quantity, 
ORPD.DocDate, 
ORPD.DocNum, 
NNM1.BeginStr,
ORPD.CreateDate,
ORPD.CardCode,
ORPD.U_SLD_Returnreason,
'' as unitMsr,
RPD10.LineType,
rpD1.Project,
OCRD.CntctPrsn,
OCrd.E_Mail,
ocrd.phone1,
ocrd.phone2,
CAST(rpd12.StreetB AS nvarchar(max)) as StreetB, CAST(rpd12.StreetNoB AS nvarchar(max)) as StreetNoB,CAST(rpd12.BlockB AS nvarchar(max)) as BlockB, CAST(rpd12.BuildingB AS nvarchar(max)) as BuildingB, 
CAST(rpd12.CityB AS nvarchar(max)) as CityB, rpd12.ZipCodeB, CAST(rpd12.CountyB AS nvarchar(max)) as CountyB, rpd12.StateB

FROM ORPD 
INNER JOIN RPD10 ON ORPD.DocEntry = RPD10.DocEntry
inner join rpd12 on orpd.Docentry = rpd12.docentry
inner join RPD1 on orpd.docEntry = rpd1.docentry
LEFT JOIN NNM1 ON ORPD.Series = NNM1.Series
LEFT JOIN OUSR ON ORPD.UserSign = OUSR.USERID
--LEFT JOIN OPRJ ON RPD1.Project = OPRJ.PrjCode
LEFT JOIN OCRD ON ORPD.CardCode = OCRD.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORPD.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT JOIN OCPR ON OCRD.CardCode = OCPR.CardCode
--LEFT JOIN OITM ON RPD1.ItemCode = OITM.ItemCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORPD.U_SLD_LVatBranch = BRANCH.Code, OADM

WHERE ORPD.DocEntry = {?DocKey@}
Order by 'No.' , 'Line No.'
