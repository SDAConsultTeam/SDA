SELECT DISTINCT
PDN12.StreetB     AS '1Bill',
    PDN12.StreetNoB   AS '2Bill',
    PDN12.BlockB      AS '3Bill',
    PDN12.CityB       AS '4Bill',
    PDN12.CountyB     AS '5Bill',
    PDN12.ZipCodeB    AS '6Bill',
        PDN12.StreetS     AS '1Ship',
    PDN12.StreetNoS   AS '2Ship',
    PDN12.BlockS      AS '3Ship',
    PDN12.CityS       AS '4Ship',
    PDN12.CountyS     AS '5Ship',
    PDN12.ZipCodeS    AS '6Ship',
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact'
,BRANCH.Code ,
CASE WHEN BRANCH.Code = '00000' AND OPDN.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND OPDN.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND OPDN.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND OPDN.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND OPDN.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND OPDN.DocCur <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND OPDN.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND OPDN.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE 
 WHEN OPDN.Printed = 'N' AND OPDN.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN OPDN.Printed = 'N' AND OPDN.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN OPDN.Printed = 'Y' AND OPDN.DocCur <> OADM.MainCurncy THEN 'Copy'  
 WHEN OPDN.Printed = 'Y' AND OPDN.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN OPDN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN OPDN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN OPDN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN OPDN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN OPDN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
-----------------------------------------------
OPDN.DocEntry,
OPDN.[Address], 
OPDN.CardCode,
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
OCRD.LicTradNum, 
NNM1.BeginStr, 
OPDN.DocNum, 
OPDN.DocDate, 
OPDN.DocDueDate,  
OCTG.PymntGroup, 
OPDN.NumAtCard, 
(PDN1.VisOrder) AS 'No.',
PDN1.LineNum as 'Line No.', 
PDN1.ItemCode,	
PDN1.Dscription as 'Dscription', 
PDN1.Quantity,
PDN1.unitMsr,
PDN1.Project,
OPDN.Comments,
PDN1.LineType,
CRD1.Street,
CRD1.StreetNo,
CRD1.Block,
CRD1.City,
CRD1.ZipCode,
CRD1.County,
CRD1.GlblLocNum,
OCRD.E_Mail,
OCRD.CntctPrsn

FROM OPDN 
INNER JOIN PDN1 ON OPDN.DocEntry = PDN1.DocEntry 
LEFT JOIN PDN12 ON OPDN.DocEntry = PDN12.DocEntry
LEFT JOIN OITM ON PDN1.ItemCode = OITM.ItemCode 
LEFT JOIN OCRD ON OPDN.CardCode = OCRD.CardCode 
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND OPDN.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT JOIN OCPR ON OPDN.CntctCode = OCPR.CntctCode 
LEFT JOIN NNM1 ON OPDN.Series = NNM1.Series 
LEFT JOIN OCTG ON OPDN.GroupNum = OCTG.GroupNum
LEFT JOIN OHEM ON OPDN.OwnerCode = OHEM.empID
LEFT JOIN OUSR ON OPDN.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON PDN1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OPDN.U_SLD_LVatBranch = BRANCH.Code , oadm


WHERE OPDN.DocEntry  = 4

Order by 'No.' , 'Line No.'
