SELECT DISTINCT
BRANCH.Code AS 'BranchCode' ,
CASE WHEN BRANCH.Code = '00000' AND OJDT.FcTotal = '0' THEN N'สำนักงานใหญ่' 
  WHEN BRANCH.Code = '00000' AND OJDT.FcTotal <> '0' THEN 'Head office' 
  WHEN BRANCH.Code <> '00000' AND OJDT.FcTotal = '0' THEN concat(N'สาขาที่' ,' ',BRANCH.Code) 
  WHEN BRANCH.Code <> '00000' AND OJDT.FcTotal <> '0' THEN concat('Branch' ,' ',BRANCH.Code) 
END 'GLN_H' ,
--CASE WHEN CRD1.GlblLocNum = '00000' AND OJDT.FcTotal = '0' THEN N'(สำนักงานใหญ่)' 
--  WHEN CRD1.GlblLocNum = '00000' AND OJDT.FcTotal <> '0' THEN '(Head office)' 
--  WHEN CRD1.GlblLocNum <> '00000' AND OJDT.FcTotal = '0' THEN concat(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
--  WHEN CRD1.GlblLocNum <> '00000' AND OJDT.FcTotal <> '0' THEN concat('(Branch' ,' ',CRD1.GlblLocNum,')') 
--  when CRD1.GlblLocNum = '' or CRD1.GlblLocNum is null then ''
--END 'GLN_BP' ,

BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
--CASE WHEN OQUT.DocCurr = OADM.MainCurncy THEN BRANCH.U_SLD_VComName ELSE BRANCH.U_SLD_F_VComName END AS 'PrintHeadr',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
CASE WHEN OJDT.FcTotal = '0' THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
CASE WHEN OJDT.FcTotal = '0' THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet  END AS 'Street',
CASE WHEN OJDT.FcTotal = '0' THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block   END AS 'Block',
CASE WHEN OJDT.FcTotal = '0' THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City  END As 'City',
CASE WHEN OJDT.FcTotal = '0' THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County  END As 'County',
--BRANCH.U_SLD_VComName As 'PrintHeadr',
--BRANCH.U_SLD_F_VComName As 'PrintHdrF',
--BRANCH.U_SLD_Building AS 'Building',
--BRANCH.U_SLD_Steet AS 'Street',
--BRANCH.U_SLD_Block AS 'Block',
--BRANCH.U_SLD_City As 'City',
--BRANCH.U_SLD_County As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
BRANCH.U_SLD_Email AS 'E-Mail',
OJDT.FcTotal,
--------------------------------------------------------------------------------------------------------
OJDT.[Series], 
OJDT.[Ref1], 
OJDT.[Memo], 
OJDT.[RefDate], 
OJDT.[Number], 
OJDT.[TransType], 
OJDT.[BaseRef],
T2.[BeginStr], 
T2.[SeriesName], 
(T1.Line_ID+1) As 'No.',
T1.[Debit], 
T1.[Credit], 
T1.[LineMemo],
T1.[ShortName], 
T3.[ActId], 
T3.[AcctName], 
T3.[Segment_0], 
T4.[CardName],

CASE
	WHEN T3.[ActId] IS NOT NULL THEN T3.[AcctName] 
	ELSE T4.[CardName] 
END AS 'NAME',

CASE
	WHEN T3.[ActId] IS NOT NULL THEN T3.FormatCode
	ELSE T1.[ShortName] 
END AS 'CODE' , 



--CASE 
--	WHEN OJDT.[TransType] = 13 THEN T5.[CardName] --A/R Invoice
--	WHEN OJDT.[TransType] = 18 THEN T6.[CardName] --A/P Invoice
--	WHEN OJDT.[TransType] = 14 THEN T7.[CardName] --A/R Credit Memo
--	WHEN OJDT.[TransType] = 19 THEN T8.[CardName] --A/P Credit Memo
--	WHEN OJDT.[TransType] = 24 THEN T9.[CardName] --Incoming Payment
--	--WHEN T0.[TransType] = 30 THEN  T18.[CardName] --Journal Entry T10 
--	WHEN OJDT.[TransType] = 46 THEN T11.[CardName] --Outgoing Payment
--	WHEN OJDT.[TransType] = 203 THEN T12.[CardName] --A/R Down Payment 
--	WHEN OJDT.[TransType] = 204 THEN T13.[CardName] --A/P Down Payment
--	WHEN OJDT.[TransType] = 15 THEN T14.[CardName] --Delivery
--	WHEN OJDT.[TransType] = 20 THEN T15.[CardName] --Good Receipt PO
--	WHEN OJDT.[TransType] = 59 THEN NULL --Good Receipt Inventory T16
--	WHEN OJDT.[TransType] = 60 THEN NULL --Good Issue Inventory T17
--	when OJDT.[TransType] = 30 Then (select A2.CardName
--from
--(
--select top 1 *
--From
--(
--SELECT distinct T00.[TransId], convert(nvarchar(100),T02.[CardName]) 'CardName' 
--		FROM OJDT T00
--		LEFT JOIN JDT1 T01 ON T00.[TransId] = T01.[TransId]
--		LEFT JOIN OCRD T02 ON T01.[ShortName] = T02.[CardCode]
--		WHERE (T01.[ShortName] LIKE 'C%' OR T01.[ShortName] LIKE 'V%' OR T01.[ShortName] LIKE 'S%')
--		AND T00.[TransId] = '{?DocKey@}'
--)A
--)A2
--)
--END AS 'Name_link' ,

CASE 
	WHEN OJDT.[TransType] = 13 THEN 'IN' --A/R Invoice
	WHEN OJDT.[TransType] = 18 THEN 'PU' --A/P Invoice
	WHEN OJDT.[TransType] = 14 THEN 'CN' --A/R Credit Memo
	WHEN OJDT.[TransType] = 19 THEN 'PC' --A/P Credit Memo
	WHEN OJDT.[TransType] = 24 THEN 'RC' --Incoming Payment
	WHEN OJDT.[TransType] = 30 THEN 'JE' --Journal Entry
	WHEN OJDT.[TransType] = 46 THEN 'PS' --Outgoing Payment
	WHEN OJDT.[TransType] = 203 THEN 'DT' --A/R Down Payment 
	WHEN OJDT.[TransType] = 204 THEN 'DT' --A/P Down Payment
	WHEN OJDT.[TransType] = 15 THEN 'DN' --Delivery
	WHEN OJDT.[TransType] = 20 THEN 'PD' --Good Receipt PO
	WHEN OJDT.[TransType] = 59 THEN 'SI' --Good Receipt Inventory
	WHEN OJDT.[TransType] = 60 THEN 'SO' --Good Issue Inventory
	ELSE NULL
END AS 'Series_link' 
,ad.*
,T1.Project

FROM OJDT 
LEFT JOIN JDT1 T1 ON OJDT.[TransId] = T1.[TransId]
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OJDT.U_S_ComVatB = BRANCH.Code
LEFT JOIN NNM1 T2 ON OJDT.[Series] = T2.[Series]
LEFT JOIN OACT T3 ON T1.[ShortName] = T3.[AcctCode]
LEFT JOIN OCRD T4 ON T1.[ShortName] = T4.[CardCode]
LEFT JOIN CRD1 ON (T4.CardCode = CRD1.CardCode AND CRD1.AdresType ='B')
LEFT JOIN OINV T5 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 13 THEN T5.[DocNum] ELSE NULL END --A/R Invoice 
LEFT JOIN OPCH T6 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 18 THEN T6.[DocNum] ELSE NULL END --A/P Invoice
LEFT JOIN ORIN T7 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 14 THEN T7.[DocNum] ELSE NULL END --A/R Credit Memo
LEFT JOIN ORPC T8 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 19 THEN T8.[DocNum] ELSE NULL END --A/P Credit Memo
LEFT JOIN ORCT T9 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 24 THEN T9.[DocNum] ELSE NULL END --Incoming Payment
LEFT JOIN OJDT T10 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 30 THEN T10.[Number] ELSE NULL END --Journal Entry 
LEFT JOIN OVPM T11 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 46 THEN T11.[DocNum] ELSE NULL END --Outgoing Payment
LEFT JOIN ODPI T12 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 203 THEN T12.[DocNum] ELSE NULL END --A/R Down Payment
LEFT JOIN ODPO T13 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 204 THEN T13.[DocNum] ELSE NULL END --A/P Down Payment
LEFT JOIN ODLN T14 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 15 THEN T14.[DocNum] ELSE NULL END --Delivery
LEFT JOIN OPDN T15 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 20 THEN T15.[DocNum] ELSE NULL END --Good Receipt PO
LEFT JOIN OIGN T16 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 59 THEN T16.[DocNum] ELSE NULL END --Good Receipt Inventory
LEFT JOIN OIGE T17 ON OJDT.[BaseRef] = CASE WHEN OJDT.[TransType] = 60 THEN T17.[DocNum] ELSE NULL END --Good Issue Inventory
left JOIN (select top 1 A.CardName , A.TransId
		from OJDT T0 
		left join 
		(SELECT distinct T00.[TransId], T02.[CardName]
		FROM OJDT T00
		LEFT JOIN JDT1 T01 ON T00.[TransId] = T01.[TransId]
		LEFT JOIN OCRD T02 ON T01.[ShortName] = T02.[CardCode]
		WHERE (T01.[ShortName] LIKE 'C%' OR T01.[ShortName] LIKE 'V%' OR T01.[ShortName] LIKE 'S%')
		)A on T0.TransId = A.TransId
		)T18 ON OJDT.TransId = T18.TransId

	 ,
	 (SELECT T0.[CompnyName], T1.[Street], T1.[StreetNo], T1.[Block], T1.[Building], T1.[City], T1.[County]
	 , T1.[ZipCode], T0.[Phone1], T0.[Phone2], T0.[Fax], T0.[E_Mail], T0.[TaxIdNum], T0.[PrintHeadr], T0.[PrintHdrF]

	FROM OADM T0 , ADM1 T1
	)AD


WHERE OJDT.[TransId] = '{?DocKey@}'

ORDER BY (T1.Line_ID+1)