-- ============================================================
-- Report: 1.Inventory Counting_ใบตรวจนับสินค้า_Befor.rpt
Path:   5. Inventory\5. Inventory Counting\1.Inventory Counting_ใบตรวจนับสินค้า_Befor.rpt
Extracted: 2026-04-09 15:22:51
-- Source: Main Report
-- Table:  Command
-- ============================================================

------ ก่อนตรวจ ต้องไม่แสดงยอด sap ให้ดู
SELECT distinct
T0.DocEntry,
CASE WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
     WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
END AS 'GLN_H',
T1.[VisOrder], T1.[ItemCode], T1.[ItemDesc], T1.[UomCode], T1.[WhsCode], T1.[BinEntry]
,T3.[BinCode]
,T5.DistNumber
,T0.[DocNum]
,T0.[Countdate],T0.[BPLId]
,t7.ItmsGrpNam
,T5.MnfSerial
,CASE
	WHEN len(T0.time) = '1' THEN '00' + ':' +'0'+ LEFT(T0.Time,1)	
	WHEN len(T0.time) = '2' THEN '00' + ':' + LEFT(T0.Time,2)
	WHEN len(T0.time) = '3' THEN '0'  + LEFT(T0.Time,1)	+':'+RIGHT(T0.Time,2)
	WHEN len(T0.time) = '4' THEN LEFT(T0.Time,2)+':'+RIGHT(T0.Time,2) 
	End 'TIME'
--,T5.Quantity
--,T9.Quantity   'CountQtyB'
,T6.UgpEntry
,T10.UgpName
,T0.CreateTime
,T0.UserSign
,T11.U_NAME
,Concat(OHEM.firstName,'',OHEM.middleName,' ',OHEM.lastname) as 'CounterName'

FROM OINC T0  
LEFT JOIN INC1 T1 ON T0.[DocEntry] = T1.[DocEntry]
--Bin
LEFT JOIN OIBQ T2 ON T1.[BinEntry] = T2.[BinAbs] and T1.[ItemCode] = T2.[ItemCode]
LEFT JOIN OBIN T3 ON T1.[BinEntry] = T3.[AbsEntry] 
LEFT JOIN OBBQ T4 ON T2.BinAbs = T4.BinAbs and T2.ItemCode = T4.ItemCode and T4.onHandQty <> 0 
--Batch 
LEFT JOIN OBTN T5 on T4.SnBMDAbs = T5.AbsEntry and T4.ItemCode = T5.ItemCode
LEFT JOIN OITM T6 ON T1.[ItemCode] = T6.[ItemCode]
LEFT JOIN OITB t7 ON T7.ItmsGrpCod = T6.ItmsGrpCod
LEFT JOIN OBTQ T8 on T1.ItemCode = T8.ItemCode and  T8.[WhsCode] =T1.[WhsCode] and  T8.[Quantity] <>0
LEFT JOIN INC3 T9 ON T9.ObjAbs = T8.MdAbsEntry
LEFT JOIN OUGP T10 on T6.UgpEntry = T10.UgpEntry
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON T0.U_SLD_LVatBranch = BRANCH.Code
LEFT JOIN OUSR T11 ON T0.UserSign = T11.USERID
right JOIN OHEM ON OHEM.empID = t0.Taker1Id --and t0.taker1Type = '171' เลือก Counter แบบ Multiple ไม่ได้

WHERE (T1.[BinEntry] is not null or T1.[BinEntry] <> '') and
 T0.DocEntry = {?DocKey@}

ORDER BY T1.[VisOrder],T1.[BinEntry]
