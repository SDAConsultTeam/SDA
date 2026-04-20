SELECT DISTINCT
case when OCRD.Phone2 is null then ''
  when OCRD.Phone2 is not null then ', ' + OCRD.Phone2
  END 'Phone2',
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND OQUT.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND OQUT.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND OQUT.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND OQUT.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND OQUT.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND OQUT.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND OQUT.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND OQUT.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
CASE
 WHEN OQUT.Printed = 'N' AND OQUT.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN OQUT.Printed = 'N' AND OQUT.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN OQUT.Printed = 'Y' AND OQUT.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN OQUT.Printed = 'Y' AND OQUT.DocCur = OADM.MainCurncy THEN N'สำเนา'
END AS 'Print Status',
OQUT.DocEntry,
OQUT.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CRD1.GlblLocNum,
OCRD.Phone1,
ISNULL(OCRD.Phone2,'') As 'Phone2',
OCRD.Fax,
OCRD.LicTradNum,
NNM1.BeginStr,
OQUT.DocNum,
OQUT.DocDate,
OQUT.DocDueDate,
(QUT1.VisOrder) As 'No.',
QUT1.LineNum as 'Line No.', 
QUT1.ItemCode,
OITM.FrgnName AS 'Dscription',
--QUT1.Dscription 'Dscription',
QUT1.Quantity,
QUT1.PriceBefDi,
CASE WHEN OQUT.DocCur = 'THB' THEN QUT1.LineTotal ELSE QUT1.TotalFrgn END AS 'LineTotal',
CASE WHEN OQUT.DocCur = 'THB' THEN OQUT.DiscSum ELSE OQUT.DiscSumFC END AS 'DiscSum',
CASE WHEN OQUT.DocCur = 'THB' THEN OQUT.VatSum ELSE OQUT.VatSumFC END AS 'VatSum',
CASE WHEN OQUT.DocCur = 'THB' THEN OQUT.DocTotal ELSE OQUT.DocTotalFC END AS 'DocTotal',
SUM(CASE WHEN OQUT.DocCur = 'THB' THEN QUT1.LineTotal ELSE QUT1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
QUT1.DiscPrcnt,
OQUT.DiscPrcnt As 'DiscP',
OQUT.DocCur,
OCPR.FirstName,
OCPR.LastName,
OQUT.CreateDate,
OQUT.CntctCode,
QUT1.unitMsr,
OQUT.Comments
,qut1.LineType,
qut1.Project,
OCPR.E_MailL as 'Contact',
OCPR.Cellolar as 'Mobile Phone',
ocpr.Tel1 as 'Tel1',
OSLP.U_Name_Foreign as 'Sale Name contact',
--OSLP.SlpName as 'Sale Name contact',
OSLP.Mobil as 'Mobile',
OSLP.Email as 'Email-Sale',
OCTG.PymntGroup,
OCRD.Cardname,
OCRD.CardFname,
OCPR.name,
QUT12.StreetB     AS 'Street / PO Box12',
QUT12.StreetNoB   AS 'Street No.12',
QUT12.BlockB      AS 'Block12',
QUT12.CityB       AS 'City12',
QUT12.ZipCodeB    AS 'Zip Code12',
QUT12.CountyB     AS 'County12',
QUT12.StateB      AS 'State12',
QUT12.CountryB    AS 'Country/Region12',
QUT1.U_SLD_Dis_Amount,
OUGP.UgpCode

FROM OQUT  
INNER JOIN QUT1 ON OQUT.DocEntry = QUT1.DocEntry 
LEFT JOIN OITM ON QUT1.ItemCode = OITM.ItemCode 
LEFT JOIN OCRD ON OQUT.CardCode = OCRD.CardCode 
LEFT JOIN CRD1 ON (OQUT.CardCode = CRD1.CardCode AND OQUT.PaytoCode = CRD1.Address AND CRD1.AdresType ='B') 
LEFT JOIN OCPR ON OQUT.CntctCode = OCPR.CntctCode 
LEFT JOIN NNM1 ON OQUT.Series = NNM1.Series 
LEFT JOIN OCTG ON OQUT.GroupNum = OCTG.GroupNum
LEFT JOIN OHEM ON OQUT.OwnerCode = OHEM.empID
LEFT JOIN OSLP ON OQUT.SLPCODE = OSLP.SLPCODE 
LEFT JOIN OPRJ ON QUT1.PROJECT = OPRJ.PRJCODE
LEFT JOIN OUGP ON QUT1.UomCode = OUGP.UgpCode
INNER JOIN QUT12 ON OQUT.DocEntry = QUT12.DocEntry
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OQUT.U_SLD_LVatBranch = BRANCH.Code , oadm

WHERE OQUT.DocEntry = '{?DocKey@}'

Order by 'No.' , 'Line No.'