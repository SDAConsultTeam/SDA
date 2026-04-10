SELECT DISTINCT
case when OCPR.Cellolar is null then ''
  when OCPR.Cellolar is not null then OCPR.Cellolar
  END 'Phone2',
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
BRANCH.Code ,
CASE WHEN BRANCH.Code = '00000' AND ORDR.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND ORDR.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ORDR.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ORDR.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORDR.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ORDR.DocCur <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ORDR.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ORDR.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,

 CASE 
 WHEN ORDR.Printed = 'N' AND ORDR.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ORDR.Printed = 'N' AND ORDR.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ORDR.Printed = 'Y' AND ORDR.DocCur <> OADM.MainCurncy THEN 'Copy'  
 WHEN ORDR.Printed = 'Y' AND ORDR.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
ORDR.DocEntry,
ORDR.CardCode,
ORDR.Address2,
ORDR.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CRD1.GlblLocNum,
OCRD.Phone1,
ISNULL(OCRD.Phone2,'') As 'Phone2',
OCRD.Fax,
OCRD.LicTradNum,
NNM1.BeginStr,
ORDR.DocNum,
ORDR.DocDate,
ORDR.DocDueDate,
OCTG.PymntGroup,
ORDR.NumAtCard,
(RDR1.VisOrder) As 'No.',
RDR1.LineNum as 'Line No.', 
RDR1.ItemCode,
RDR1.Dscription as 'Dscription',
RDR1.Quantity,
RDR1.PriceBefDi,
RDR1.LineTotal,
RDR1.TotalFrgn,
RDR1.DiscPrcnt,
ORDR.VatSum,
ORDR.VatSumFC,
ORDR.DiscSum,
ORDR.DiscSumFC,
ORDR.DocCur,
ORDR.DocTotal,
ORDR.DocTotalFC,
ORDR.DiscPrcnt As 'DiscP',
RDR1.unitMsr,
ORDR.Comments,
rdr1.LineType,
RDR1.project,
OCPR.E_MailL,
OSLP.SlpName as 'Sale Name contact',
OSLP.Mobil as 'Mobile',
OSLP.Email as 'Email-Sale',
RDR12.StreetB     AS 'Street / PO Box12',
    RDR12.StreetNoB   AS 'Street No.12',
    RDR12.BlockB      AS 'Block12',
    RDR12.CityB       AS 'City12',
    RDR12.ZipCodeB    AS 'Zip Code12',
    RDR12.CountyB     AS 'County12',
    RDR12.StateB      AS 'State12',
    RDR12.CountryB    AS 'Country/Region12',
		RDR12.Streets     ,
    RDR12.StreetNos   ,
    RDR12.Blocks   ,
    RDR12.Citys      ,
    RDR12.ZipCodes   ,
    RDR12.Countys     ,
    RDR12.States     ,
    RDR12.Countrys   ,
	RDR1.U_SLD_Dis_Amount




FROM ORDR   
INNER JOIN RDR1 ON ORDR.DocEntry = RDR1.DocEntry 
LEFT JOIN OITM ON RDR1.ItemCode = OITM.ItemCode 
LEFT JOIN OCRD ON ORDR.CardCode = OCRD.CardCode
LEFT JOIN CRD1 ON (ORDR.CardCode = CRD1.CardCode AND ORDR.PaytoCode = CRD1.[Address] AND CRD1.AdresType ='B' ) 
LEFT JOIN OCPR ON ORDR.CardCode = OCPR.CardCode AND ORDR.CntctCode = OCPR.CntctCode
LEFT JOIN NNM1 ON ORDR.Series = NNM1.Series 
LEFT JOIN OCTG ON ORDR.GroupNum = OCTG.GroupNum
LEFT JOIN OSLP ON ORDR.SlpCode = OSLP.SlpCode
LEFT JOIN OPRJ ON RDR1.PROJECT = OPRJ.PRJCODE 
LEFT JOIN RDR12 ON ORDR.DocEntry = RDR12.DocEntry
INNER JOIN OITT ON RDR1.ItemCode = OITT.Code AND OITT.TreeType = 'S'
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORDR.U_SLD_LVatBranch = BRANCH.Code , oadm


WHERE ORDR.DocEntry = {?DocKey@}

Union all
SELECT DISTINCT
case when OCPR.Cellolar is null then ''
  when OCPR.Cellolar is not null then OCPR.Cellolar
  END 'Phone2',
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
BRANCH.Code ,
CASE WHEN BRANCH.Code = '00000' AND ORDR.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND ORDR.DocCur <> OADM.MainCurncy THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND ORDR.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND ORDR.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND ORDR.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
  WHEN CRD1.GlblLocNum = '00000' AND ORDR.DocCur <> OADM.MainCurncy THEN '(Head office)' 
  WHEN CRD1.GlblLocNum <> '00000' AND ORDR.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
  WHEN CRD1.GlblLocNum <> '00000' AND ORDR.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,

 CASE 
 WHEN ORDR.Printed = 'N' AND ORDR.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN ORDR.Printed = 'N' AND ORDR.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ' 
 WHEN ORDR.Printed = 'Y' AND ORDR.DocCur <> OADM.MainCurncy THEN 'Copy'  
 WHEN ORDR.Printed = 'Y' AND ORDR.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN ORDR.DocCur = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
ORDR.DocEntry,
ORDR.CardCode,
ORDR.Address2,
ORDR.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CRD1.GlblLocNum,
OCRD.Phone1,
ISNULL(OCRD.Phone2,'') As 'Phone2',
OCRD.Fax,
OCRD.LicTradNum,
NNM1.BeginStr,
ORDR.DocNum,
ORDR.DocDate,
ORDR.DocDueDate,
OCTG.PymntGroup,
ORDR.NumAtCard,
(RDR10.AftLineNum + 0.5) As 'No.',
RDR10.LineSeq as 'Line No.', 
'' as ItemCode,
CAST(RDR10.LineText AS NVARCHAR(4000)) As 'Dscription',
'0' as Quantity,
'0' as PriceBefDi,
'0' as LineTotal,
'0' as TotalFrgn,
'0' as DiscPrcnt,
ORDR.VatSum,
ORDR.VatSumFC,
ORDR.DiscSum,
ORDR.DiscSumFC,
ORDR.DocCur,
ORDR.DocTotal,
ORDR.DocTotalFC,
ORDR.DiscPrcnt As 'DiscP',
'' as unitMsr,
ORDR.Comments,
rdr10.LineType,
RDR1.project,
OCPR.E_MailL,
OSLP.SlpName as 'Sale Name contact',
OSLP.Mobil as 'Mobile',
OSLP.Email as 'Email-Sale',
RDR12.StreetB     AS 'Street / PO Box12',
    RDR12.StreetNoB   AS 'Street No.12',
    RDR12.BlockB      AS 'Block12',
    RDR12.CityB       AS 'City12',
    RDR12.ZipCodeB    AS 'Zip Code12',
    RDR12.CountyB     AS 'County12',
    RDR12.StateB      AS 'State12',
    RDR12.CountryB    AS 'Country/Region12',
	RDR12.Streets     ,
    RDR12.StreetNos   ,
    RDR12.Blocks   ,
    RDR12.Citys      ,
    RDR12.ZipCodes   ,
    RDR12.Countys     ,
    RDR12.States     ,
    RDR12.Countrys   ,
	'' as U_SLD_Dis_Amount


FROM ORDR   
INNER JOIN RDR10 ON ORDR.DocEntry = RDR10.DocEntry 
INNER JOIN RDR1 ON ORDR.DocEntry = RDR1.DocEntry 
--LEFT JOIN OITM ON RDR1.ItemCode = OITM.ItemCode 
LEFT JOIN OCRD ON ORDR.CardCode = OCRD.CardCode
LEFT JOIN CRD1 ON (ORDR.CardCode = CRD1.CardCode AND ORDR.PaytoCode = CRD1.[Address] AND CRD1.AdresType ='B' ) 
LEFT JOIN OCPR ON ORDR.CardCode = OCPR.CardCode AND ORDR.CntctCode = OCPR.CntctCode
LEFT JOIN NNM1 ON ORDR.Series = NNM1.Series 
LEFT JOIN OCTG ON ORDR.GroupNum = OCTG.GroupNum
LEFT JOIN OSLP ON ORDR.SlpCode = OSLP.SlpCode
LEFT JOIN RDR12 ON ORDR.DocEntry = RDR12.DocEntry
--LEFT JOIN OPRJ ON RDR1.PROJECT = OPRJ.PRJCODE 
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORDR.U_SLD_LVatBranch = BRANCH.Code , oadm

WHERE ORDR.DocEntry = {?DocKey@}
Order by 'No.' , 'Line No.'
