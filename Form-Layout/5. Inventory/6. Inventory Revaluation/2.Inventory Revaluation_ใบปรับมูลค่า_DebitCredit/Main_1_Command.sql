-- ============================================================
-- Report: 2.Inventory Revaluation_ใบปรับมูลค่า_DebitCredit.rpt
Path:   5. Inventory\6. Inventory Revaluation\2.Inventory Revaluation_ใบปรับมูลค่า_DebitCredit.rpt
Extracted: 2026-04-09 15:22:52
-- Source: Main Report
-- Table:  Command
-- ============================================================

SELECT DISTINCT
CASE WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
     WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
END AS 'GLN_H',
OMRV.RevalType,
OMRV.JrnlMemo,
OMRV.DocEntry,
OMRV.DocNum,
OMRV.DocDate,
OMRV.TaxDate,
OMRV.Ref2,
NNM1.BeginStr,
(MRV2.LineNum+1) AS 'NUM',
ISNULL(MRV2.LineNum+1,MRV1.LineNum+1) As 'No.',
MRV1.ItemCode,
MRV1.Dscription,
MRV1.WhsCode,
MRV1.UnitMsr,
ISNULL(MRV2.INMOpenQty,MRV1.Quantity) AS 'Quantity',
ISNULL(MRV2.LineTotal,MRV1.LineTotal) As 'DeCre',
MRV1.WhsCode,
CASE
	WHEN MRV2.INMTransTy = 15 THEN ODLN.BeginStr
	WHEN MRV2.INMTransTy = 16 THEN ORDN.BeginStr
	WHEN MRV2.INMTransTy = 13 THEN OINV.BeginStr
	WHEN MRV2.INMTransTy = 14 THEN ORIN.BeginStr
	WHEN MRV2.INMTransTy = 132 THEN OCIN.BeginStr
	WHEN MRV2.INMTransTy = 20 THEN OPDN.BeginStr
	WHEN MRV2.INMTransTy = 21 THEN ORPD.BeginStr
	WHEN MRV2.INMTransTy = 18 THEN OPCH.BeginStr
	WHEN MRV2.INMTransTy = 19 THEN ORPC.BeginStr
	WHEN MRV2.INMTransTy = 59 THEN OIGN.BeginStr
	WHEN MRV2.INMTransTy = 60 THEN OIGE.BeginStr
	WHEN MRV2.INMTransTy = 68 THEN OWKO.BeginStr
	WHEN MRV2.INMTransTy = 67 THEN OWTR.BeginStr
	WHEN MRV2.INMTransTy = 69 THEN OIPF.BeginStr 
	WHEN MRV2.INMTransTy = 162 THEN NNM1.BeginStr
	END AS Doc_Type,
MRV2.INMBaseRef AS 'DOCUMENT_NO',
CASE
	WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
	WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
	WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD,
OMRV.Comments

FROM OMRV
LEFT JOIN MRV1 ON OMRV.DocEntry = MRV1.DocEntry
LEFT JOIN MRV2 ON MRV1.DocEntry = MRV2.DocEntry AND MRV1.LineNum = MRV2.BaseLine
LEFT JOIN NNM1 ON OMRV.Series = NNM1.Series
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OMRV.U_SLD_LVatBranch = BRANCH.Code
LEFT JOIN (SELECT DISTINCT OIGN.DocNum,NNM1.BeginStr,OIGN.ObjType,IGN1.ItemCode,IGN1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM OIGN
			LEFT JOIN NNM1 ON OIGN.Series = NNM1.Series
			LEFT JOIN IGN1 ON OIGN.DocEntry = IGN1.DocEntry
			INNER JOIN MRV1 ON IGN1.ItemCode = MRV1.ItemCode
			) OIGN ON MRV2.INMBaseRef = OIGN.DocNum AND MRV2.INMTransTy = OIGN.ObjType AND OIGN.LineNum = MRV2.BaseLine

LEFT JOIN (SELECT DISTINCT ODLN.DocNum,NNM1.BeginStr,ODLN.ObjType,DLN1.ItemCode,DLN1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM ODLN
			LEFT JOIN NNM1 ON ODLN.Series = NNM1.Series
			LEFT JOIN DLN1 ON ODLN.DocEntry = DLN1.DocEntry
			INNER JOIN MRV1 ON DLN1.ItemCode = MRV1.ItemCode) ODLN ON MRV2.INMBaseRef = ODLN.DocNum AND MRV2.INMTransTy = ODLN.ObjType

LEFT JOIN (SELECT DISTINCT ORDN.DocNum,NNM1.BeginStr,ORDN.ObjType,RDN1.ItemCode,RDN1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM ORDN
			LEFT JOIN NNM1 ON ORDN.Series = NNM1.Series
			LEFT JOIN RDN1 ON ORDN.DocEntry = RDN1.DocEntry
			INNER JOIN MRV1 ON RDN1.ItemCode = MRV1.ItemCode) ORDN ON MRV2.INMBaseRef = ORDN.DocNum AND MRV2.INMTransTy = ORDN.ObjType

LEFT JOIN (SELECT DISTINCT OINV.DocNum,NNM1.BeginStr,OINV.ObjType,INV1.ItemCode,INV1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM OINV
			LEFT JOIN NNM1 ON OINV.Series = NNM1.Series
			LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
			INNER JOIN MRV1 ON INV1.ItemCode = MRV1.ItemCode) OINV ON MRV2.INMBaseRef = OINV.DocNum AND MRV2.INMTransTy = OINV.ObjType

LEFT JOIN (SELECT DISTINCT ORIN.DocNum,NNM1.BeginStr,ORIN.ObjType,RIN1.ItemCode,RIN1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM ORIN
			LEFT JOIN NNM1 ON ORIN.Series = NNM1.Series
			LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
			INNER JOIN MRV1 ON RIN1.ItemCode = MRV1.ItemCode) ORIN ON MRV2.INMBaseRef = ORIN.DocNum AND MRV2.INMTransTy = ORIN.ObjType

LEFT JOIN (SELECT DISTINCT OCIN.DocNum,NNM1.BeginStr,OCIN.ObjType,CIN1.ItemCode,CIN1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM OCIN
			LEFT JOIN NNM1 ON OCIN.Series = NNM1.Series
			LEFT JOIN CIN1 ON OCIN.DocEntry = CIN1.DocEntry
			INNER JOIN MRV1 ON CIN1.ItemCode = MRV1.ItemCode) OCIN ON MRV2.INMBaseRef = OCIN.DocNum AND MRV2.INMTransTy = OCIN.ObjType

LEFT JOIN (SELECT DISTINCT OPDN.DocNum,NNM1.BeginStr,OPDN.ObjType,PDN1.ItemCode,PDN1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM OPDN
			LEFT JOIN NNM1 ON OPDN.Series = NNM1.Series
			LEFT JOIN PDN1 ON OPDN.DocEntry = PDN1.DocEntry
			INNER JOIN MRV1 ON PDN1.ItemCode = MRV1.ItemCode) OPDN ON MRV2.INMBaseRef = OPDN.DocNum AND MRV2.INMTransTy = OPDN.ObjType

LEFT JOIN (SELECT DISTINCT ORPD.DocNum,NNM1.BeginStr,ORPD.ObjType,RPD1.ItemCode,RPD1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM ORPD
			LEFT JOIN NNM1 ON ORPD.Series = NNM1.Series
			LEFT JOIN RPD1 ON ORPD.DocEntry = RPD1.DocEntry
			INNER JOIN MRV1 ON RPD1.ItemCode = MRV1.ItemCode) ORPD ON MRV2.INMBaseRef = ORPD.DocNum AND MRV2.INMTransTy = ORPD.ObjType

LEFT JOIN (SELECT DISTINCT OPCH.DocNum,OPCH.Series, NNM1.BeginStr,OPCH.ObjType,PCH1.ItemCode,PCH1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.DocEntry,MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM OPCH
			LEFT JOIN NNM1 ON OPCH.Series = NNM1.Series
			LEFT JOIN PCH1 ON OPCH.DocEntry = PCH1.DocEntry
			INNER JOIN MRV1 ON PCH1.ItemCode = MRV1.ItemCode) OPCH ON MRV2.INMBaseRef = OPCH.DocNum AND MRV2.INMTransTy = OPCH.ObjType 
			AND MRV2.BaseLine = OPCH.LineNum

LEFT JOIN (SELECT DISTINCT ORPC.DocNum,NNM1.BeginStr,ORPC.ObjType,RPC1.ItemCode,RPC1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM ORPC
			LEFT JOIN NNM1 ON ORPC.Series = NNM1.Series
			LEFT JOIN RPC1 ON ORPC.DocEntry = RPC1.DocEntry
			INNER JOIN MRV1 ON RPC1.ItemCode = MRV1.ItemCode) ORPC ON MRV2.INMBaseRef = ORPC.DocNum AND MRV2.INMTransTy = ORPC.ObjType

LEFT JOIN (SELECT DISTINCT OIGE.DocNum,NNM1.BeginStr,OIGE.ObjType,IGE1.ItemCode,IGE1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM OIGE
			LEFT JOIN NNM1 ON OIGE.Series = NNM1.Series
			LEFT JOIN IGE1 ON OIGE.DocEntry = IGE1.DocEntry
			INNER JOIN MRV1 ON IGE1.ItemCode = MRV1.ItemCode) OIGE ON MRV2.INMBaseRef = OIGE.DocNum AND MRV2.INMTransTy = OIGE.ObjType

LEFT JOIN (SELECT DISTINCT OWKO.OrderNum,NNM1.BeginStr,OWKO.ObjType,WKO1.ItemCode,MRV1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM OWKO
			LEFT JOIN NNM1 ON OWKO.Series = NNM1.Series
			LEFT JOIN WKO1 ON OWKO.OrderNum = WKO1.OrderNum
			INNER JOIN MRV1 ON WKO1.ItemCode = MRV1.ItemCode) OWKO ON MRV2.INMTransTy = OWKO.ObjType

LEFT JOIN (SELECT DISTINCT OWTR.DocNum,NNM1.BeginStr,OWTR.ObjType,WTR1.ItemCode,WTR1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			WTR1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM OWTR
			LEFT JOIN NNM1 ON OWTR.Series = NNM1.Series
			LEFT JOIN WTR1 ON OWTR.DocEntry = WTR1.DocEntry
			INNER JOIN MRV1 ON WTR1.ItemCode = MRV1.ItemCode) OWTR ON MRV2.INMBaseRef = OWTR.DocNum AND MRV2.INMTransTy = OWTR.ObjType

LEFT JOIN (SELECT DISTINCT OIPF.DocNum,NNM1.BeginStr,OIPF.ObjType,IPF1.ItemCode,IPF1.Dscription,MRV1.UnitMsr,MRV1.WhsCode,
			MRV1.LineNum,
			CASE
				WHEN MRV1.EvalSystem = 'F' THEN 'FIFO'
				WHEN MRV1.EvalSystem = 'A' THEN 'Moving Average'
				WHEN MRV1.EvalSystem = 'S' THEN 'Standard' END AS VALUE_METHOD
			FROM OIPF
			LEFT JOIN NNM1 ON OIPF.Series = NNM1.Series
			LEFT JOIN IPF1 ON OIPF.DocEntry = IPF1.DocEntry
			INNER JOIN MRV1 ON IPF1.ItemCode = MRV1.ItemCode) OIPF ON MRV2.INMBaseRef = OIPF.DocNum AND MRV2.INMTransTy = OIPF.ObjType


WHERE OMRV.DocEntry = {?@DocKey}
AND OMRV.RevalType = 'M' 

ORDER BY (MRV2.LineNum+1)
