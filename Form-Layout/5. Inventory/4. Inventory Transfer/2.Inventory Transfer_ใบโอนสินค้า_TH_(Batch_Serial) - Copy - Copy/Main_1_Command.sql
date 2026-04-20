-- ============================================================
-- Report: 2.Inventory Transfer_ใบโอนสินค้า_TH_(Batch_Serial) - Copy - Copy.rpt
Path:   5. Inventory\4. Inventory Transfer\2.Inventory Transfer_ใบโอนสินค้า_TH_(Batch_Serial) - Copy - Copy.rpt
Extracted: 2026-04-09 15:22:51
-- Source: Main Report
-- Table:  Command
-- ============================================================

DECLARE @DocEntry INT
SET @DocEntry = {?DocKey@}

SELECT
CASE WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
     WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
END AS 'GLN_H',
'From' WhsFrom,
'To' WhsTo,
OWTR.DocEntry ,
NNM1.BeginStr + CONVERT(CHAR(10),OWTR.DocNum) 'DocNum',
OWTR.DocDate ,
--OWTR.U_LogIn 'TransferBy',

OWTR.Comments 'Remark',
WTR1.BaseRef 'TransRefNo',
WTR1.LineNum+1 'LineNum',
WTR1.ItemCode,
WTR1.Dscription ,
WTR1.Quantity,
WTR1.unitMsr  ,
WTR1.FromWhsCod,
WTR1.WhsCode,
BinBatch.BatchNum,
Binbatch.BatchQty *-1 'BatchQty',
SinSerial.DistNumber,
SinSerial.Quantity*-1 AS 'SerialQty',
WTR1.Project

FROM OWTR
INNER JOIN WTR1 ON OWTR.DocEntry = WTR1.DocEntry 
INNER JOIN NNM1 ON OWTR.Series = NNM1.Series
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OWTR.U_SLD_LVatBranch = BRANCH.Code

LEFT JOIN
		--BinFrom Nobatch
		(
		SELECT OWTR.DocEntry ,WTR1.LineNum
		,WTR1.ItemCode,WTR1.FromWhsCod ,OBIN.BinCode BinFrom
		,OBTL.Quantity BinQty
		FROM OWTR
		INNER JOIN WTR1 ON OWTR.DocEntry = WTR1.DocEntry 
		INNER JOIN OITM ON WTR1.ItemCode = OITM.ItemCode
		LEFT JOIN OILM ON OILM.DocEntry = WTR1.DocEntry AND OILM.TransType = 67 and WTR1.ItemCode = OILM.ItemCode
		AND OILM.DocLineNum = WTR1.LineNum AND WTR1.FromWhsCod = OILM.LocCode AND OILM.AccumType = 1 AND OILM.DocAction = 2
		LEFT JOIN OBTL ON OBTL.MessageID = OILM.MessageID 
		LEFT JOIN OBIN ON OBTL.BinAbs = OBIN.AbsEntry 
		WHERE OITM.ManBtchNum = 'N'
		AND WTR1.FromWhsCod NOT IN(SELECT OWHS.Whscode FROM OWHS WHERE OWHS.BinActivat='Y')
		AND OWTR.DocEntry = @DocEntry
		) BinFrom ON WTR1.DocEntry = BinFrom.DocEntry AND WTR1.LineNum = BinFrom.LineNum AND WTR1.ItemCode = BinFrom.ItemCode AND WTR1.FromWhsCod = BinFrom.FromWhsCod
LEFT JOIN
		(
		--Batch
		SELECT IBT.BaseEntry,IBT.BaseLinNum,IBT.ItemCode,IBT.BatchNum,OBTN.AbsEntry BatchEntry ,IBT.WhsCode,
		CASE WHEN IBT.Direction = 2 THEN OBTL.Quantity 
		ELSE IBT.Quantity END AS BatchQty
		,OBIN.BinCode,obtl.Quantity BinQty
		FROM IBT1_LINK IBT  
		INNER JOIN OBTN ON IBT.ItemCode = OBTN.ItemCode and IBT.BatchNum = OBTN.DistNumber
		INNER JOIN OBBQ ON OBBQ.ItemCode = OBTN.ItemCode AND OBBQ.SnBMDAbs = OBTN.AbsEntry and obbq.WhsCode = IBT.WhsCode
		INNER JOIN OBIN ON OBBQ.BinAbs = OBIN.AbsEntry
		INNER JOIN OBTl ON OBTL.BinAbs = OBBQ.BinAbs and obtl.SnBMDAbs = OBBQ.SnBMDAbs 
		INNER JOIN OILM ON OILM.DocEntry = IBT.BaseEntry AND OILM.TransType = 67 and IBT.ItemCode = OILM.ItemCode
		AND OILM.DocLineNum = IBT.BaseLinNum AND IBT.WhsCode = OILM.LocCode AND OILM.AccumType = 1 AND OILM.DocAction = 2
		and OBTL.MessageID = OILM.MessageID
		WHERE IBT.BaseType = 67 
		and (ibt.Direction = 1 OR ibt.Direction = 2)
		AND IBT.Whscode IN(SELECT OWHS.WhsCode FROM OWHS WHERE OWHS.BinActivat= 'Y')
		and ibt.BaseEntry = @DocEntry

		UNION ALL

		SELECT 
		IBT.BaseEntry,
		IBT.BaseLinNum,
		IBT.ItemCode,
		IBT.BatchNum,
		OBTN.AbsEntry 'BatchEntry' ,
		IBT.WhsCode,
		IBT.Quantity 'BatchQty',
		'' BinCode,0 BinQty

		FROM IBT1_LINK IBT  
		INNER JOIN OBTN ON IBT.ItemCode = OBTN.ItemCode and IBT.BatchNum = OBTN.DistNumber
		WHERE IBT.BaseType = 67 
		and (ibt.Direction = 1 OR ibt.Direction = 2)
		AND IBT.WhsCode NOT IN(SELECT OWHS.WhsCode FROM OWHS WHERE OWHS.BinActivat= 'Y')
		--and OBTN.AbsEntry NOT IN (SELECT OBBQ.SnBMDAbs  FROM OBBQ WHERE OBBQ.ItemCode = IBT.ItemCode AND OBBQ.WhsCode = IBT.WhsCode)
		and ibt.BaseEntry = @DocEntry
		) BinBatch ON WTR1.DocEntry = BinBatch.BaseEntry AND WTR1.ItemCode = BinBatch.ItemCode AND BinBatch.BaseLinNum = WTR1.LineNum

LEFT JOIN
		--SinFrom Nobatch
		(
		SELECT DISTINCT OWTR.DocEntry ,WTR1.LineNum
		,WTR1.ItemCode,WTR1.FromWhsCod 
		--OBIN.BinCode SinFrom
		--,OBTL.Quantity BinQty
		FROM OWTR
		INNER JOIN WTR1 ON OWTR.DocEntry = WTR1.DocEntry 
		INNER JOIN OITM ON WTR1.ItemCode = OITM.ItemCode
		LEFT JOIN OILM ON OILM.DocEntry = WTR1.DocEntry AND OILM.TransType = 67 and WTR1.ItemCode = OILM.ItemCode
		AND OILM.DocLineNum = WTR1.LineNum AND WTR1.FromWhsCod = OILM.LocCode AND OILM.AccumType = 1 AND OILM.DocAction = 2
		--LEFT JOIN OBTL ON OBTL.MessageID = OILM.MessageID 
		--LEFT JOIN OBIN ON OBTL.BinAbs = OBIN.AbsEntry 
		WHERE OITM.ManBtchNum = 'N'
		AND WTR1.FromWhsCod NOT IN(SELECT OWHS.Whscode FROM OWHS WHERE OWHS.BinActivat='Y')
		AND OWTR.DocEntry = @DocEntry
		) SinFrom ON WTR1.DocEntry = SinFrom.DocEntry AND WTR1.LineNum = SinFrom.LineNum AND WTR1.ItemCode = SinFrom.ItemCode AND WTR1.FromWhsCod = SinFrom.FromWhsCod
LEFT JOIN
		(
		--Satch
		SELECT DISTINCT SRI.BaseEntry,SRI.BaseLinNum,OSRN.DistNumber,SRI.ItemCode,SRI.SysSerial,OSRN.AbsEntry SerialEntry ,SRI.WhsCode,
		OSRQ.Quantity
		--CASE WHEN SRI.Direction = 2 THEN OBTL.Quantity 
		--ELSE SRI.Quantity END AS BatchQty
		--,OBIN.BinCode,obtl.Quantity BinQty
		FROM SRI1_LINK SRI  
		LEFT JOIN OSRN ON SRI.ItemCode = OSRN.ItemCode and SRI.SysSerial = OSRN.SysNumber
		LEFT JOIN OSRQ ON SRI.SysSerial = OSRQ.SysNumber
		--INNER JOIN OBBQ ON OBBQ.ItemCode = OSRN.ItemCode AND OBBQ.SnBMDAbs = OSRN.AbsEntry and obbq.WhsCode = SRI.WhsCode
		--INNER JOIN OBIN ON OBBQ.BinAbs = OBIN.AbsEntry
		--INNER JOIN OBTl ON OBTL.BinAbs = OBBQ.BinAbs and obtl.SnBMDAbs = OBBQ.SnBMDAbs 
		LEFT JOIN OILM ON OILM.DocEntry = SRI.BaseEntry AND OILM.TransType = 67 and SRI.ItemCode = OILM.ItemCode
		AND OILM.DocLineNum = SRI.BaseLinNum AND SRI.WhsCode = OILM.LocCode AND OILM.AccumType = 1 AND OILM.DocAction = 2
		--and OBTL.MessageID = OILM.MessageID
		WHERE SRI.BaseType = 67 
		and SRI.Direction <> 0 AND OSRQ.Quantity > 0
		AND SRI.Whscode IN(SELECT OWHS.WhsCode FROM OWHS WHERE OWHS.BinActivat= 'Y')
		and SRI.BaseEntry = @DocEntry

		UNION ALL

		SELECT DISTINCT
		SRI.BaseEntry,
		SRI.BaseLinNum,
		OSRN.DistNumber,
		SRI.ItemCode,
		SRI.SysSerial,
		OSRN.AbsEntry 'SerialEntry' ,
		SRI.WhsCode,
		OSRQ.Quantity
		--SRI.Quantity 'BatchQty',
		--'' SinCode,0 SinQty

		FROM SRI1_LINK SRI  
		INNER JOIN OSRN ON SRI.ItemCode = OSRN.ItemCode and SRI.SysSerial = OSRN.SysNumber
		LEFT JOIN OSRQ ON SRI.SysSerial = OSRQ.SysNumber
		WHERE SRI.BaseType = 67 
		and SRI.Direction <> 0 AND OSRQ.Quantity > 0
		AND SRI.WhsCode NOT IN(SELECT OWHS.WhsCode FROM OWHS WHERE OWHS.BinActivat= 'Y')
		--and OSRN.AbsEntry NOT IN (SELECT OBBQ.SnBMDAbs  FROM OBBQ WHERE OBBQ.ItemCode = SRI.ItemCode AND OBBQ.WhsCode = SRI.WhsCode)
		and SRI.BaseEntry = @DocEntry
		) SinSerial ON WTR1.DocEntry = SinSerial.BaseEntry AND WTR1.ItemCode = SinSerial.ItemCode AND SinSerial.BaseLinNum = WTR1.LineNum

,OADM ,ADM1

WHERE OWTR.DocEntry = @DocEntry
--AND SinSerial.DistNumber IS NOT NULL
--OR BinBatch.BatchNum IS NOT NULL


