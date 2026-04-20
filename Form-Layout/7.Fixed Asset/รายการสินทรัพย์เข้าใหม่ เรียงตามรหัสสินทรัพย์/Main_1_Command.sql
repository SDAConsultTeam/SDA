-- ============================================================
-- Report: รายการสินทรัพย์เข้าใหม่ เรียงตามรหัสสินทรัพย์.rpt
Path:   7.Fixed Asset\รายการสินทรัพย์เข้าใหม่ เรียงตามรหัสสินทรัพย์.rpt
Extracted: 2026-04-09 15:22:55
-- Source: Main Report
-- Table:  Command
-- ============================================================

--declare @dateFrom datetime set @dateFrom = '2020-08-27'--{?DateFrom}
--declare @dateTo datetime set @dateTo = '2021-12-31'--{?DateTo}

declare @dateFrom datetime set @dateFrom = {?DateFrom}
declare @dateTo datetime set @dateTo = {?DateTo}

---Cappitalization
select distinct  '1' as 'NoLow',FixedAss.ObjType,FixedAss.CompanyName,FixedAss.GLN_H,FixedAss.AsClassCode,FixedAss.AsClassName,FixedAss.AsGroup,FixedAss.ItemCode,FixedAss.ItemName,FixedAss.DeperRate,FixedAss.CapDate,ISNULL(FixedAss.PriceCost,0) 'PriceCost',ISNULL(FixedAss.Deperciation,0) 'Deperciation'
,((isnull(FixedAss.PriceCost,0) - isnull(FixedAss.CNSum,0)) - isnull(FixedAss.SumRevalu,0)) - isnull(FixedAss.Deperciation,0) 'PriceNet'
,@dateFrom 'DateFrom',@dateTo 'DateTo'
from (select distinct [@SLDT_SET_BRANCH].U_SLD_VComName as 'CompanyName'
,CASE WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
     WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
END 'GLN_H'
,T0.AssetClass 'AsClassCode' ,OACS.[Name] 'AsClassName' ,OAGS.Descr 'AsGroup'
,T0.ItemCode,T0.ItemName
, CONCAT( (100/(ITM7.UsefulLife/12)),' ', '%') 'DeperRate' --, (ITM7.UsefulLife) 'Usefull Life M'
,T0.CapDate
,case when FXCAP.CapSum is null and FXCAP.CapSum = 0 then TopITM8.APC else FXCAP.CapSum  end 'PriceCost'  --,TopITM8.APC,FXCAP.CapSum
,Deperciation2.Deperciation
,FXCAP.ObjType
,FXCN.CNSum
,FXRE.SumRevalu
from OITM T0 
LEFT JOIN OACS ON T0.AssetClass = OACS.Code
LEFT JOIN OAGS ON T0.AssetGroup = OAGS.Code
LEFT JOIN ITM7 ON T0.ItemCode = ITM7.ItemCode	
left join rti1 on rti1.itemcode = T0.itemcode
left join orti on rti1.DocEntry = orti.DocEntry
---Pull Deperciation 
	left join (select De2.ItemCode,sum(De2.OrdDprPost) 'Deperciation' from 
				(select itemcode, OrdDprPost from odpv where odpv.PeriodCat = year(@dateTo) ) De2 group by itemCode)
					Deperciation2 on Deperciation2.ItemCode = T0.itemcode
---Capitalization
	left join ( select ACQ.ItemCode,sum(ACQ.LineTotal) 'CapSum' ,ACQ.ObjType
				from (select convert(varchar,OACQ.PostDate, 23) 'ACQDate', ACQ1.itemcode, ACQ1.Linetotal,OACQ.ObjType from OACQ inner join ACQ1 on OACQ.DocEntry = ACQ1.DocEntry where OACQ.DocStatus = 'P'
					) ACQ where (ACQ.ACQDate >= @dateFrom and ACQ.ACQDate <= @dateTo)  group by ACQ.ItemCode,ACQ.ObjType) FXCAP on T0.ITEMCODE = FXCAP.ItemCode
---Pull APC 
	left join ( select distinct itemcode,APC  from itm8 where APC is not null and APC <> 0 ) TopITM8 on T0.ITEMCODE = TopITM8.itemCode 
		---CreditMemo		
			left join (select ACD.ItemCode,sum(ACD.LineTotal) 'CNSum' from (select convert(varchar,OACD.PostDate, 23) 'ACDDate', ACD1.itemcode, ACD1.Linetotal
				from OACD inner join ACD1 on OACD.DocEntry = ACD1.DocEntry where OACD.DocStatus = 'P'
					) ACD where ACD.ACDDate <= @dateTo  group by ACD.ItemCode) FXCN on T0.ITEMCODE = FXCN.itemCode	
		---Revaluation			
			left join (select Revalu.RevaluDate,Revalu.ItemCode,sum(Revalu.NBV)-sum(Revalu.New_NBV) 'SumRevalu' 
			from (select convert(varchar,OFAR.PostDate, 23) 'RevaluDate' ,FAR1.itemcode, FAR1.NBV, FAR1.New_NBV --,sum(NBV) 'Sum1',sum(New_NBV) 'Sum2'
				from OFAR INNER JOIN FAR1 on FAR1.DocEntry = OFAR.DocEntry
					) Revalu where Revalu.RevaluDate <= @dateTo group by Revalu.RevaluDate,Revalu.ItemCode) FXRE on T0.ITEMCODE = FXRe.itemCode
	,[@SLDT_SET_BRANCH] BRANCH

	WHERE T0.ItemType = 'F' and  (ORTI.DocStatus is null or ORTI.DocStatus <> 'P') ) FixedAss
	where FixedAss.ObjType is not null

	order by ItemCode,'NoLow' --เรียงจาก Cap > CN > Revalu

