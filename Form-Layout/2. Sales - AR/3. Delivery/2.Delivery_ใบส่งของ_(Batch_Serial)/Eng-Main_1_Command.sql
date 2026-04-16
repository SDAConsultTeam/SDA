SELECT DISTINCT
case when OCPR.Cellolar is null then ''
  when OCPR.Cellolar is not null then ', ' + OCPR.Cellolar
  END 'Phone2',
OCPR.name AS 'Coontact',
BRANCH.Code ,
CASE WHEN BRANCH.Code = '00000' AND ODLN.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND ODLN.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ODLN.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ODLN.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ODLN.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ODLN.DocCur <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ODLN.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ODLN.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE 
 WHEN ODLN.Printed = 'N' AND ODLN.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ODLN.Printed = 'N' AND ODLN.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ODLN.Printed = 'Y' AND ODLN.DocCur <> OADM.MainCurncy THEN 'Copy'  
 WHEN ODLN.Printed = 'Y' AND ODLN.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
--------------------------------------------------------------------------------------------------------
ODLN.DocEntry,
ODLN.CardCode,
DLN12.StreetB     AS '1Bill',
    DLN12.StreetNoB   AS '2Bill',
    DLN12.BlockB      AS '3Bill',
    DLN12.CityB       AS '4Bill',
    DLN12.CountyB     AS '5Bill',
    DLN12.ZipCodeB    AS '6Bill',
        DLN12.StreetS     AS '1Ship',
    DLN12.StreetNoS   AS '2Ship',
    DLN12.BlockS      AS '3Ship',
    DLN12.CityS       AS '4Ship',
    DLN12.CountyS     AS '5Ship',
    DLN12.ZipCodeS    AS '6Ship',
ODLN.CreateDate,
ODLN.DocNum,
ODLN.DocDueDate,
ODLN.DocDate,
DLN1.unitmsr,
DLN1.Quantity,
DLN1.BaseDocNum,
(DLN1.VisOrder) AS 'No.',
DLN1.LineNum as 'Line No.', 
DLN1.Dscription,
DLN1.ItemCode,
NNM1.BeginStr,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CRD1.GlblLocNum,
OCRD.Phone1,
ISNULL(OCPR.Cellolar,'') As 'Phone2',
OCRD.Fax,
OCRD.LicTradNum,
OCTG.pymntgroup,
OSLP.SlpName,
ODLN.Comments,
ODLN.NumAtCard,
DLN1.LineType,
OCPR.E_MailL AS ContactMail,
OSLP.SlpName as 'Sale Name contact',
OSLP.Mobil as 'Mobile',
OSLP.Email as 'Email-Sale',
OPRJ.PrjCode ,
OUGP.UgpCode
FROM ODLN 
INNER JOIN DLN1 ON ODLN.DocEntry = DLN1.DocEntry 
LEFT JOIN DLN12 ON ODLN.DocEntry = DLN12.DocEntry 
LEFT JOIN NNM1 ON ODLN.Series = NNM1.Series 
LEFT JOIN OCRD ON ODLN.CardCode = OCRD.CardCode
LEFT JOIN OCPR ON ODLN.CntctCode = OCPR.CntctCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ODLN.PayToCode = CRD1.[Address] AND CRD1.AdresType ='B')
LEFT JOIN OCTG ON ODLN.GroupNum = OCTG.GroupNum
LEFT JOIN OSLP ON ODLN.SlpCode = OSLP.SlpCode
LEFT JOIN OPRJ ON DLN1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON ODLN.UserSign = OUSR.USERID
LEFT JOIN OUGP ON DLN1.UomCode = OUGP.UgpCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ODLN.U_SLD_LVatBranch = BRANCH.Code , oadm
WHERE ODLN.DocEntry  = '{?DocKey@}'
Union all
SELECT DISTINCT
case when OCPR.Cellolar is null then ''
  when OCPR.Cellolar is not null then ', ' + OCPR.Cellolar
  END 'Phone2',
OCPR.Name AS 'Coontact',
BRANCH.Code ,
CASE WHEN BRANCH.Code = '00000' AND ODLN.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND ODLN.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ODLN.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ODLN.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ODLN.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ODLN.DocCur <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ODLN.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ODLN.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE 
 WHEN ODLN.Printed = 'N' AND ODLN.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ODLN.Printed = 'N' AND ODLN.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ODLN.Printed = 'Y' AND ODLN.DocCur <> OADM.MainCurncy THEN 'Copy'  
 WHEN ODLN.Printed = 'Y' AND ODLN.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN ODLN.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
--------------------------------------------------------------------------------------------------------
ODLN.DocEntry,
ODLN.CardCode,
DLN12.StreetB     AS '1Bill',
    DLN12.StreetNoB   AS '2Bill',
    DLN12.BlockB      AS '3Bill',
    DLN12.CityB       AS '4Bill',
    DLN12.CountyB     AS '5Bill',
    DLN12.ZipCodeB    AS '6Bill',
        DLN12.StreetS     AS '1Ship',
    DLN12.StreetNoS   AS '2Ship',
    DLN12.BlockS      AS '3Ship',
    DLN12.CityS       AS '4Ship',
    DLN12.CountyS     AS '5Ship',
    DLN12.ZipCodeS    AS '6Ship',
ODLN.CreateDate,
ODLN.DocNum,
ODLN.DocDueDate,
ODLN.DocDate,
'' as unitmsr,
'0' as Quantity,
'' as BaseDocNum,
(DLN10.AftLineNum + 0.5) As 'No.',
DLN10.LineSeq as 'Line No.', 
CAST(DLN10.LineText AS NVARCHAR(4000)) As 'Dscription',
'' as ItemCode,
NNM1.BeginStr,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CRD1.GlblLocNum,
OCRD.Phone1,
ISNULL(OCPR.Cellolar,'') As 'Phone2',
OCRD.Fax,
OCRD.LicTradNum,
OCTG.pymntgroup,
OSLP.SlpName,
ODLN.Comments,
ODLN.NumAtCard,
DLN10.LineType,
OCPR.E_MailL AS ContactMail,
OSLP.SlpName as 'Sale Name contact',
OSLP.Mobil as 'Mobile',
OSLP.Email as 'Email-Sale',
'' AS PrjCode,
'' AS UgpCode 
FROM ODLN 
INNER JOIN DLN10 ON ODLN.DocEntry = DLN10.DocEntry 
LEFT JOIN DLN12 ON ODLN.DocEntry = DLN12.DocEntry 
LEFT JOIN NNM1 ON ODLN.Series = NNM1.Series 
LEFT JOIN OCRD ON ODLN.CardCode = OCRD.CardCode
LEFT JOIN OCPR ON ODLN.CntctCode = OCPR.CntctCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ODLN.PayToCode = CRD1.[Address] AND CRD1.AdresType ='B')
LEFT JOIN OCTG ON ODLN.GroupNum = OCTG.GroupNum
LEFT JOIN OSLP ON ODLN.SlpCode = OSLP.SlpCode
--LEFT JOIN OPRJ ON DLN1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON ODLN.UserSign = OUSR.USERID
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ODLN.U_SLD_LVatBranch = BRANCH.Code , oadm
WHERE ODLN.DocEntry  = '{?DocKey@}'
Order by 'No.' , 'Line No.'
