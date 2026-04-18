SELECT DISTINCT
BRANCH.Code ,
CASE WHEN BRANCH.Code = '00000' AND OPQT.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND OPQT.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND OPQT.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND OPQT.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND OPQT.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN CRD1.GlblLocNum = '00000' AND OPQT.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN CRD1.GlblLocNum <> '00000' AND OPQT.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',CRD1.GlblLocNum) 
  WHEN CRD1.GlblLocNum <> '00000' AND OPQT.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',CRD1.GlblLocNum) 
END 'GLN_BP' ,
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN OPQT.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN OPQT.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN OPQT.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN OPQT.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN OPQT.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
CASE WHEN OPQT.DocCur = 'THB' THEN PQT1.LineTotal ELSE PQT1.TotalFrgn END AS 'LineTotal',
OPQT.DocCur,
OPQT.DocEntry,
OPQT.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1, 
ISNULL(OCRD.Fax,'') AS 'Fax', 
OCRD.LicTradNum,
ISNULL(pqt12.GlbLocNumB,'') AS 'GlbLocNumB',
ISNULL(NNM1.BeginStr,'') AS 'BeginStr', 
OPQT.DocNum, 
OPQT.DocDate, 
OPQT.DocDueDate, 
(PQT1.VisOrder) AS 'No.', 
PQT1.LineNum as 'Line No.', 
PQT1.ItemCode, 
PQT1.Dscription as 'Dscription', 
PQT1.Quantity, 
PQT1.Price, 
PQT1.TotalSumSy,
PQT1.UomCode, 
CASE WHEN OPQT.DocCur = 'THB' THEN OPQT.VatSum ELSE OPQT.VatSumFC END AS 'VatSum',
CASE WHEN OPQT.DocCur = 'THB' THEN OPQT.DocTotal ELSE OPQT.DocTotalFC END AS 'DocTotal',
SUM(CASE WHEN OPQT.DocCur = 'THB' THEN PQT1.LineTotal ELSE PQT1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
pqt1.unitMsr,
PQT1.LineType,
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
pqt1.Project,
ocrd.CntctPrsn,
ocrd.E_Mail,
ocrd.Phone1,
ocrd.Phone2,
pqt1.DiscPrcnt,
pqt1.U_SLD_Dis_Amount,
CAST(pqt12.StreetB AS nvarchar(max)) as StreetB, CAST(pqt12.StreetNoB AS nvarchar(max)) as StreetNoB,CAST(pqt12.BlockB AS nvarchar(max)) as BlockB, CAST(pqt12.BuildingB AS nvarchar(max)) as BuildingB,
CAST(pqt12.CityB AS nvarchar(max)) as CityB, pqt12.ZipCodeB, CAST(pqt12.CountyB AS nvarchar(max)) as CountyB, pqt12.StateB,
opqt.cardcode

FROM OPQT
INNER JOIN PQT1 ON OPQT.DocEntry = PQT1.DocEntry
inner join PQT12 on OPQT.DocEntry = PQT12.DocEntry
LEFT JOIN OCRD ON OCRD.CardCode = OPQT.CardCode
LEFT JOIN OCPR ON OCRD.CardCode = OCPR.CardCode AND OPQT.cntctcode = OCPR.cntctcode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND OPQT.PaytoCode = CRD1.[Address] AND  CRD1.AdresType ='B')
LEFT JOIN NNM1 ON OPQT.Series = NNM1.Series
LEFT JOIN OUSR ON OPQT.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON PQT1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OPQT.U_SLD_LVatBranch = BRANCH.Code, OADM

WHERE OPQT.DocEntry = {?DocKey@}
Order by 'No.' , 'Line No.'