-- ============================================================
-- Report: 1.Landed Costs_ใบปรับราคาต้นทุนสินค้า.rpt
Path:   3. Purchasing - AP\9. Landed Costs\1.Landed Costs_ใบปรับราคาต้นทุนสินค้า.rpt
Extracted: 2026-04-09 15:22:47
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
CASE WHEN BRANCH.Code = '00000' AND OIPF.DocCur = OADM.MainCurncy THEN N'สำนักงานใหญ่'
  WHEN BRANCH.Code = '00000' AND OIPF.DocCur <> OADM.MainCurncy THEN 'Head office'
  WHEN BRANCH.Code <> '00000' AND OIPF.DocCur = OADM.MainCurncy THEN concat(N'สาขาที่' ,' ',BRANCH.Code)
  WHEN BRANCH.Code <> '00000' AND OIPF.DocCur <> OADM.MainCurncy THEN concat('Branch' ,' ',BRANCH.Code)
END 'GLN_H' ,
CASE WHEN CRD1.GlblLocNum = '00000' AND OIPF.DocCur = OADM.MainCurncy THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum = '00000' AND OIPF.DocCur <> OADM.MainCurncy THEN '(Head office)'
  WHEN CRD1.GlblLocNum <> '00000' AND OIPF.DocCur = OADM.MainCurncy THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')')
  WHEN CRD1.GlblLocNum <> '00000' AND OIPF.DocCur <> OADM.MainCurncy THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')')
  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
END 'GLN_BP' ,
OIPF.DocEntry,
OIPF.DocNum,
(IPF1.LineNum+1) AS 'No.', 
NNM1.BeginStr,
OIPF.DocDate,
OIPF.DocCur,
OCRD.CardCode,
OCRD.CardName,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
---------------------------------
IPF1.ItemCode,
IPF1.Dscription,
IPF1.Quantity,
IPF1.PriceFOB,
IPF1.FobValue,
IPF1.TtlExpndLC,
IPF1.LineTotal,
IPF1.PriceAtWH,
IPF1.WhsCode,
OIPF.CostSum,
OIPF.BeforeVat,
OIPF.Vat1,
OIPF.Vat2,
OIPF.DocTotal,
IPF2_2.SUMCOST,
OIPF.Descr,
--------------------------------------
--CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
--  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
--  END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1

FROM OIPF
INNER JOIN IPF1 ON OIPF.DocEntry = IPF1.DocEntry 
INNER JOIN (SELECT IPF2.DocEntry,SUM(IPF2.CostSum) AS SUMCOST
			FROM IPF2 GROUP BY IPF2.DocEntry)IPF2_2 ON OIPF.DocEntry = IPF2_2.DocEntry
INNER JOIN IPF2 ON OIPF.DocEntry = IPF2.DocEntry
LEFT JOIN OALC ON IPF2.AlcCode = OALC.AlcCode
LEFT JOIN OCRD ON OIPF.CardCode = OCRD.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND CRD1.AdresType ='B')
LEFT JOIN NNM1 ON OIPF.Series = NNM1.Series
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OIPF.U_SLD_LVatBranch = BRANCH.Code , oadm


WHERE OIPF.DocEntry = 
{?@DocKey}

ORDER BY (IPF1.LineNum+1)
