SELECT DISTINCT
BRANCH.Code ,
CASE WHEN BRANCH.Code = '00000' AND OPRQ.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND OPRQ.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND OPRQ.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND OPRQ.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND OPRQ.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN CRD1.GlblLocNum = '00000' AND OPRQ.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN CRD1.GlblLocNum <> '00000' AND OPRQ.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',CRD1.GlblLocNum) 
  WHEN CRD1.GlblLocNum <> '00000' AND OPRQ.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',CRD1.GlblLocNum) 
END 'GLN_BP' ,
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN OPRQ.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN OPRQ.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN OPRQ.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN OPRQ.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN OPRQ.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
CASE WHEN OPRQ.DocCur = 'THB' THEN PRQ1.LineTotal ELSE PRQ1.TotalFrgn END AS 'LineTotal',
OPRQ.DocCur,
OPRQ.DocEntry,
OPRQ.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1, 
ISNULL(OCRD.Fax,'') AS 'Fax', 
OCRD.LicTradNum,
ISNULL(PRQ12.GlbLocNumB,'') AS 'GlbLocNumB',
ISNULL(NNM1.BeginStr,'') AS 'BeginStr', 
OPRQ.DocNum, 
OPRQ.DocDate, 
OPRQ.DocDueDate, 
(PRQ1.VisOrder) AS 'No.', 
PRQ1.LineNum as 'Line No.', 
PRQ1.ItemCode, 
PRQ1.Dscription as 'Dscription', 
PRQ1.Quantity, 
PRQ1.Price, 
PRQ1.TotalSumSy,
PRQ1.UomCode, 
CASE WHEN OPRQ.DocCur = 'THB' THEN OPRQ.VatSum ELSE OPRQ.VatSumFC END AS 'VatSum',
CASE WHEN OPRQ.DocCur = 'THB' THEN OPRQ.DocTotal ELSE OPRQ.DocTotalFC END AS 'DocTotal',
SUM(CASE WHEN OPRQ.DocCur = 'THB' THEN PRQ1.LineTotal ELSE PRQ1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
PRQ1.unitMsr,
PRQ1.LineType,
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
PRQ1.Project,
ocrd.CntctPrsn,
ocrd.E_Mail,
ocrd.Phone1,
ocrd.Phone2,
PRQ1.DiscPrcnt,
PRQ1.U_SLD_Dis_Amount,
CAST(PRQ12.StreetB AS nvarchar(max)) as StreetB, CAST(PRQ12.StreetNoB AS nvarchar(max)) as StreetNoB,CAST(PRQ12.BlockB AS nvarchar(max)) as BlockB, CAST(PRQ12.BuildingB AS nvarchar(max)) as BuildingB, 
CAST(PRQ12.CityB AS nvarchar(max)) as CityB, PRQ12.ZipCodeB, CAST(PRQ12.CountyB AS nvarchar(max)) as CountyB, PRQ12.StateB,
OPRQ.cardcode

FROM OPRQ 
INNER JOIN PRQ1 ON OPRQ.DocEntry = PRQ1.DocEntry
left join PRQ12 on OPRQ.DocEntry = PRQ12.DocEntry
LEFT JOIN OCRD ON OCRD.CardCode = OPRQ.CardCode 
LEFT JOIN OCPR ON OCRD.CardCode = OCPR.CardCode AND OPRQ.cntctcode = OCPR.cntctcode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND OPRQ.PaytoCode = CRD1.[Address] AND  CRD1.AdresType ='B')
LEFT JOIN NNM1 ON OPRQ.Series = NNM1.Series
LEFT JOIN OUSR ON OPRQ.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON PRQ1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OPRQ.U_SLD_LVatBranch = BRANCH.Code, OADM

WHERE OPRQ.DocEntry = {?DocKey@}
Order by 'No.' , 'Line No.'