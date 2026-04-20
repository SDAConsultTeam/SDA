SELECT DISTINCT
CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
CASE WHEN BRANCH.Code = '00000' AND OPCH.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND OPCH.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND OPCH.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND OPCH.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END 'GLN_H' ,
CASE WHEN CRD.GlblLocNum = '00000' AND OPCH.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD.GlblLocNum = '00000' AND OPCH.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD.GlblLocNum <> '00000' AND OPCH.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD.GlblLocNum,')')
  WHEN CRD.GlblLocNum <> '00000' AND OPCH.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD.GlblLocNum,')')
  when CRD.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
 CASE
 WHEN OPCH.Printed = 'N' AND OPCH.DocCur <> OADM.MainCurncy THEN 'Original'
 WHEN OPCH.Printed = 'N' AND OPCH.DocCur = OADM.MainCurncy THEN N'ต้นฉบับ'
 WHEN OPCH.Printed = 'Y' AND OPCH.DocCur <> OADM.MainCurncy THEN 'Copy'
 WHEN OPCH.Printed = 'Y' AND OPCH.DocCur = OADM.MainCurncy THEN N'สำเนา'
 END AS 'Print Status',
OPCH.DocEntry,
OPCH.[Address],
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN CRD.GlblLocNum IS NULL THEN ''
  WHEN CRD.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD.GlblLocNum
  END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1, 
OCRD.Fax,
OCRD.LicTradNum,  
NNM1.BeginStr, 
OPCH.DocNum, 
OPCH.DocDate, 
OPCH.DocDueDate, 
OCTG.PymntGroup, 
ISNULL(OPCH.NumAtCard,'') AS 'NumAtCard',
(PCH1.VisOrder) AS 'No.', 
PCH1.LineNum as 'Line No.', 
PCH1.ItemCode, 
PCH1.Dscription as 'Dscription',
PCH1.LineType as 'LineType',
PCH1.Quantity,
PCH1.PriceBefDi, 
PCH1.DiscPrcnt As 'LDiscPrcnt',
CASE WHEN OPCH.DocCur = 'THB' THEN PCH1.LineTotal ELSE PCH1.TotalFrgn END AS 'LineTotal',
CASE WHEN OPCH.DocCur = 'THB' THEN OPCH.VatSum ELSE OPCH.VatSumFC END AS 'VatSum',
CASE WHEN OPCH.DocCur = 'THB' THEN OPCH.DiscSum ELSE OPCH.DiscSumFC END AS 'DiscSum',
OPCH.DiscPrcnt,
OPCH.DocCur,
CASE WHEN OPCH.DocCur = 'THB' THEN OPCH.DocTotal ELSE OPCH.DocTotalFC END AS 'DocTotal',
SUM(CASE WHEN OPCH.DocCur = 'THB' THEN PCH1.LineTotal ELSE PCH1.TotalFrgn END) OVER() AS 'Sum_LineTotal_All',
PCH1.unitMsr,
OPCH.Comments,
CASE WHEN OPCH.DocCur = 'THB' THEN OPCH.DpmAmnt ELSE OPCH.DpmAmntFC END AS 'DpmAmnt',
CASE WHEN OPCH.U_DB_02 IS not NULL THEN ''
  WHEN OPCH.U_DB_02 IS NULL THEN T10.[Name]
  END 'Reason_DB',
CASE WHEN OPCH.U_DB_02 IS NULL THEN ''
  WHEN OPCH.U_DB_02 IS NOT NULL THEN N'เพิ่มหนี้เนื่องจาก' + OPCH.U_DB_02
  END 'Reason_DB_Remark',
OPCH.U_CN_01,
OPCH.U_CN_02,
OPCH.U_CN_03,
opch.Printed

FROM OPCH   
INNER JOIN PCH1 ON OPCH.DocEntry = PCH1.DocEntry 
LEFT JOIN OITM ON PCH1.ItemCode = OITM.ItemCode 
LEFT JOIN OCRD ON OPCH.CardCode = OCRD.CardCode 
LEFT JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode 
LEFT JOIN OCPR ON OPCH.CntctCode = OCPR.CntctCode 
LEFT JOIN NNM1 ON OPCH.Series = NNM1.Series 
LEFT JOIN OCTG ON OPCH.GroupNum = OCTG.GroupNum
LEFT JOIN OHEM ON OPCH.OwnerCode = OHEM.empID
LEFT JOIN CRD1 CRD ON (OPCH.PaytoCode = CRD.[Address] AND OPCH.CardCode = CRD.CardCode AND CRD.AdresType ='B') 
LEFT JOIN OPRJ ON PCH1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON OPCH.UserSign = OUSR.USERID
LEFT JOIN OSLP ON OPCH.SlpCode = OSLP.SlpCode
LEFT JOIN [dbo].[@SLD_REASON_DBNOTE] T10 ON OPCH.U_DB_01 = T10.code
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OPCH.U_SLD_LVatBranch = BRANCH.Code , oadm

WHERE OPCH.DocEntry = 1
Order by 'No.' , 'Line No.'
