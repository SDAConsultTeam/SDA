SELECT DISTINCT
case when OCPR.Cellolar is null then ''
  when OCPR.Cellolar is not null then OCPR.Cellolar
  END 'Phone2',
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
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
CASE WHEN ORDR.DocCur = 'THB' THEN RDR1.LineTotal ELSE RDR1.TotalFrgn END AS 'LineTotal',
CASE WHEN ORDR.DocCur = 'THB' THEN ORDR.DiscSum ELSE ORDR.DiscSumFC END AS 'DiscSum',
CASE WHEN ORDR.DocCur = 'THB' THEN ORDR.VatSum ELSE ORDR.VatSumFC END AS 'VatSum',
CASE WHEN ORDR.DocCur = 'THB' THEN ORDR.DocTotal ELSE ORDR.DocTotalFC END AS 'DocTotal',
SUM(CASE WHEN ORDR.DocCur = 'THB' THEN RDR1.LineTotal ELSE RDR1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
RDR1.DiscPrcnt,
ORDR.DocCur,
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
Order by 'No.' , 'Line No.'
