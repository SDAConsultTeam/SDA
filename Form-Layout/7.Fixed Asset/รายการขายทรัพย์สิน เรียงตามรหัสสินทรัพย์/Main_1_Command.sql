-- ============================================================
-- Report: รายการขายทรัพย์สิน เรียงตามรหัสสินทรัพย์.rpt
Path:   7.Fixed Asset\รายการขายทรัพย์สิน เรียงตามรหัสสินทรัพย์.rpt
Extracted: 2026-04-09 15:22:55
-- Source: Main Report
-- Table:  Command
-- ============================================================

declare @dateFrom datetime set @dateFrom = '20210131'--{?DateFrom}
declare @dateTo datetime set @dateTo = '20211231'--{?DateTo}

select distinct [@SLDT_SET_BRANCH].U_SLD_VComName
,CASE WHEN BRANCH.Code = '00000' THEN N'สำนักงานใหญ่'
     WHEN BRANCH.Code <> '00000' THEN concat(N'สาขาที่', ' ', BRANCH.Code)
END 'GLN_H'
,year(@dateFrom) 'Yearfrom',year(@dateTo) 'YearTo'
,case when Month(@dateFrom) = '1' then N'มกราคม' 
 when Month(@dateFrom) = '2' then N'กุมภาพันธ์' 
 when Month(@dateFrom) = '3' then N'มีนาคม' 
 when Month(@dateFrom) = '4' then N'เมษายน' 
 when Month(@dateFrom) = '5' then N'พฤษภาคม' 
 when Month(@dateFrom) = '6' then N'มิถุนายน' 
 when Month(@dateFrom) = '7' then N'กรกฎาคม' 
 when Month(@dateFrom) = '8' then N'สิงหาคม' 
 when Month(@dateFrom) = '9' then N'กันยายน' 
 when Month(@dateFrom) = '10' then N'ตุลาคม' 
 when Month(@dateFrom) = '11' then N'พฤศจิกายน' 
 when Month(@dateFrom) = '12' then N'ธันวาคม' 
else '' end 'MonthFrom'
,case when Month(@dateTo) = '1' then N'มกราคม' 
 when Month(@dateTo) = '2' then N'กุมภาพันธ์' 
 when Month(@dateTo) = '3' then N'มีนาคม' 
 when Month(@dateTo) = '4' then N'เมษายน' 
 when Month(@dateTo) = '5' then N'พฤษภาคม' 
 when Month(@dateTo) = '6' then N'มิถุนายน' 
 when Month(@dateTo) = '7' then N'กรกฎาคม' 
 when Month(@dateTo) = '8' then N'สิงหาคม' 
 when Month(@dateTo) = '9' then N'กันยายน' 
 when Month(@dateTo) = '10' then N'ตุลาคม' 
 when Month(@dateTo) = '11' then N'พฤศจิกายน' 
 when Month(@dateTo) = '12' then N'ธันวาคม' else '' end 'MonthTo'
,T0.AssetClass 'AsClassCode' ,OACS.[Name] 'AsClassName'
,T0.ItemCode ,T0.ItemName
,Retire.Qty
--, (ITM7.UsefulLife) 'Usefull Life M'
, CONCAT( (100/(ITM7.UsefulLife/12)),' ', '%') 'DeperRate'
,Retire.RetireDate ,T0.CapDate 
,Retire.JEnumber ,Retire.INVNumber
,(isnull(FixPrice.PriceCost,0) - isnull(Fixprice.CNSum,0)) - isnull(FixPrice.SumRevalu,0) as 'PriceCost'
,isnull(FixDeper.Deper1,0)  as 'DeperHistorical'
,isnull(FixDeper.Deper2,0) as 'DeperPeriod'
,isnull(FixDeper.Deper1,0) + isnull(FixDeper.Deper2,0) as 'SumDeper'
,((isnull(FixPrice.PriceCost,0) - isnull(Fixprice.CNSum,0)) - isnull(FixPrice.SumRevalu,0)) - (isnull(FixDeper.Deper1,0) + (isnull(FixDeper.Deper2,0) )) as 'PriceNet'
,isnull(Retire.PriceSale,0) 'PriceSale'
,isnull(Retire.PriceSale,0) - (((isnull(FixPrice.PriceCost,0) - isnull(Fixprice.CNSum,0)) - isnull(FixPrice.SumRevalu,0)) - (isnull(FixDeper.Deper1,0) + (isnull(FixDeper.Deper2,0)))) as 'Profit(Loss)'

from OITM T0
LEFT JOIN OACS ON T0.AssetClass = OACS.Code
LEFT JOIN ITM7 ON T0.ItemCode = ITM7.ItemCode 
--Retirement By turk
 left join ( select distinct orti.docnum,ORTI.DocStatus,ORTI.DocType,RTI1.Itemcode,concat(JE.JeSeries,Je.JEno) 'JEnumber',concat(INV.INVSeries,INV.INVno) 'INVNumber',ORTI.PostDate 'RetireDate' ,ORTI.DocTotal 'PriceSale',case when RTI1.Quantity is null or RTI1.Quantity = 0 then 1 else RTI1.Quantity End 'Qty'
  from ORTI inner join rti1 on rti1.DocEntry = orti.DocEntry
 ---Pull Ref INV
 left join ( select distinct ORTI.DocNum,ORTI.BaseRef,OINV.DocNum 'INVno',NNM1.BeginStr'INVSeries' from ORTI
  left join OINV on ORTI.BaseRef = OINV.Docnum and ORTI.TransType = 13
   left join nnm1 on nnm1.Series = OINV.Series 
    where ORTI.DocStatus = 'P' and ORTI.DocType = 'NC'
     ) INV on INV.INVno = ORTI.BaseRef
 ---Pull Ref JE
 left join ( select distinct ORTI.DocNum,OJDT.BaseRef,NNM1.BeginStr 'JeSeries' ,OJDT.TransId 'JEno' from ORTI
  left join OJDT on ORTI.DocNum = OJDT.BaseRef and OJDT.TransType = 1470000094
   left join nnm1 on nnm1.Series = OJDT.Series 
    where ORTI.DocStatus = 'P' and ORTI.DocType = 'NC' 
     ) JE on JE.BaseRef = ORTI.Docnum
 where ORTI.DocStatus = 'P' and ORTI.DocType = 'NC' and (ORTI.PostDate >= @dateFrom  and  ORTI.PostDate <= @dateTo) 
 ) Retire on Retire.Itemcode = T0.Itemcode

--calculate deperciation by Turk
 left join (select distinct T0.itemcode,Deperciation1.Deper1,Deperciation2.Deper2,Deperciation3.Deper3 from OITM T0 
   ---Pull BeginYear
 left join (select distinct itemcode,OrDpAcc 'Deper1' from itm8 where PeriodCat = year(@dateTo)) 
  Deperciation1 on Deperciation1.itemcode = T0.ItemCode
   ---Sum PostDerpercation except a month 
 left join (select De2.ItemCode,sum(De2.OrdDprPost) 'Deper2' from 
    (select itemcode, OrdDprPost from odpv where odpv.PeriodCat = year(@dateTo) and month(fromdate) <= MONTH(@dateTo) ) De2 group by itemCode)
  Deperciation2 on Deperciation2.ItemCode = T0.itemcode
   ---Pull Deperciation a month only
 left join (select itemcode,OrdDprPost 'Deper3'  --, PeriodCat , year(@dateto) , month(fromdate) , month(@dateto)
    from odpv where PeriodCat = year(@dateTo) and month(fromdate) = month(@dateTo))
  Deperciation3 on Deperciation3.ItemCode = T0.itemcode 
  ) FixDeper on FixDeper.itemcode = T0.itemcode

--calculate price by Turk
 left join (select distinct Fprice.itemcode ,case when Fprice.CapSum is null or /*change from AND to OR 20-10-2021*/ Fprice.CapSum = 0 then Fprice.APC else Fprice.CapSum  end 'PriceCost' ,Fprice.CNSum,Fprice.CapSum,Fprice.APC,FPrice.SalvageVal,Fprice.SumRevalu from OITM t0
  left join (select T0.ITEMCODE,TopITM8.SalvageVal,TopITM8.APC,FXCAP.CapSum,FXCN.CNSum,FXRE.SumRevalu from oitm T0
  ---Capitalization
   left join (select ACQ.ItemCode,sum(ACQ.LineTotal) 'CapSum' from (select convert(varchar,OACQ.PostDate, 23) 'ACQDate', ACQ1.itemcode, ACQ1.Linetotal
    from OACQ inner join ACQ1 on OACQ.DocEntry = ACQ1.DocEntry where OACQ.DocStatus = 'P'
     ) ACQ where ACQ.ACQDate <= @dateTo  group by ACQ.ItemCode) FXCAP on T0.ITEMCODE = FXCAP.ItemCode
  ---CreditMemo-FixAss   
   left join (select ACD.ItemCode,sum(ACD.LineTotal) 'CNSum' from (select convert(varchar,OACD.PostDate, 23) 'ACDDate', ACD1.itemcode, ACD1.Linetotal
    from OACD inner join ACD1 on OACD.DocEntry = ACD1.DocEntry where OACD.DocStatus = 'P'
     ) ACD where ACD.ACDDate <= @dateTo  group by ACD.ItemCode) FXCN on T0.ITEMCODE = FXCN.itemCode 
  ---Revaluation   
   left join (select Revalu.RevaluDate,Revalu.ItemCode,sum(Revalu.NBV)-sum(Revalu.New_NBV) 'SumRevalu' 
   from (select convert(varchar,OFAR.PostDate, 23) 'RevaluDate' ,FAR1.itemcode, FAR1.NBV, FAR1.New_NBV --,sum(NBV) 'Sum1',sum(New_NBV) 'Sum2'
    from OFAR INNER JOIN FAR1 on FAR1.DocEntry = OFAR.DocEntry
     ) Revalu where Revalu.RevaluDate <= @dateTo group by Revalu.RevaluDate,Revalu.ItemCode) FXRE on T0.ITEMCODE = FXRe.itemCode
  ---Pull Salvage
   left join (select distinct itemcode,APC,SalvageVal  from itm8 where APC is not null and APC <> 0 ) TopITM8 on T0.ITEMCODE = TopITM8.itemCode
 ) Fprice on Fprice.ItemCode = T0.ItemCode 
 ) FixPrice on FixPrice.itemcode = T0.ItemCode

, [@SLDT_SET_BRANCH] BRANCH

WHERE T0.ItemType = 'F' --Type Fixed Assets
and  (Retire.DocStatus is not null or Retire.DocStatus = 'P')  and Retire.DocType = 'NC' 
--and T0.ItemCode = 'FAOE22019060001'
