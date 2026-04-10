SELECT DISTINCT
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_Building As 'Building',
BRANCH.U_SLD_Steet As 'Street',
BRANCH.U_SLD_Block As 'Block',
BRANCH.U_SLD_City As 'City',
BRANCH.U_SLD_County As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
OHEM.firstName,
OHEM.lastName,
OPRQ.DocEntry,
OPRQ.docdate,
NNM1.BeginStr, 
OPRQ.DocNum,
OPRQ.ReqName,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
  END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1,
ISNULL(OUDP.[Name],'') AS 'Department',
(PRQ1.VisOrder) AS 'No.', 
PRQ1.LineNum as 'Line No.', 
PRQ1.Dscription as 'Dscription', 
PRQ1.Quantity, 
PRQ1.Price,
PRQ1.LineTotal,
PRQ1.unitmsr,
ISNULL(OPRQ.Comments,'') AS 'Comments',
((SUM(OITW.OnHand)-SUM(OITW.IsCommited))+SUM(OITW.OnOrder)) AS 'Available',
OPRQ.ReqDate,
PRQ1.ItemCode,
PRQ1.LineType,
PRQ1.Project,
PRQ1.U_SLD_Dis_Amount


FROM OPRQ
INNER JOIN PRQ1 ON OPRQ.DocEntry = PRQ1.DocEntry
LEFT JOIN OCRD ON OPRQ.CardCode = OCRD.CardCode 
LEFT JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode AND CRD1.AdresType = 'B' AND CRD1.[Address] = OPRQ.PayToCode
LEFT JOIN NNM1 ON OPRQ.Series = NNM1.Series 
LEFT JOIN OUDP ON OPRQ.Department = OUDP.Code
LEFT JOIN OHEM ON (SELECT CASE WHEN ReqType = '12' THEN UserSign ELSE Requester END FROM OPRQ WHERE DocEntry  = {?DocKey@}) = OHEM.empID
LEFT JOIN OHPS ON OHEM.position = OHPS.posID
LEFT JOIN OBPL ON OPRQ.BPLId = OBPL.BPLId
LEFT JOIN OITM ON PRQ1.ItemCode = OITM.ItemCode
LEFT JOIN OWHS ON PRQ1.WhsCode = OWHS.WhsCode
LEFT JOIN OITW ON PRQ1.ItemCode = OITW.ItemCode 
LEFT JOIN OPRJ ON PRQ1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON OPRQ.UserSign = OUSR.USERID
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON CAST(OPRQ.U_SLD_LVatBranch AS NVARCHAR(30)) = BRANCH.Code

WHERE OPRQ.DocEntry  = {?DocKey@}

GROUP BY
BRANCH.[Name],
BRANCH.U_SLD_VComName,
BRANCH.U_SLD_F_VComName,
BRANCH.U_SLD_VTAXID,
BRANCH.U_SLD_Building,
BRANCH.U_SLD_Steet,
BRANCH.U_SLD_Block,
BRANCH.U_SLD_City,
BRANCH.U_SLD_County,
BRANCH.U_SLD_ZipCode,
BRANCH.U_SLD_Tel,
BRANCH.U_SLD_Fax,
OHEM.firstName,
OHEM.lastName,
OPRQ.DocEntry,
OPRQ.docdate,
NNM1.BeginStr, 
OPRQ.DocNum,
OPRQ.ReqName,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
  END ,
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END ,
OCRD.Phone1,
OUDP.[Name],
(PRQ1.VisOrder), 
PRQ1.LineNum,
PRQ1.Dscription, 
PRQ1.Quantity, 
PRQ1.Price,
PRQ1.LineTotal,
PRQ1.unitmsr,
OPRQ.Comments,
OPRQ.ReqDate,
PRQ1.ItemCode,
PRQ1.LineType,
PRQ1.Project,
PRQ1.U_SLD_Dis_Amount


Union all
SELECT DISTINCT
BRANCH.[Name] As 'BranchName',
BRANCH.U_SLD_VComName As 'PrintHeadr',
BRANCH.U_SLD_F_VComName As 'PrintHdrF',
BRANCH.U_SLD_VTAXID As 'TaxIdNum',
BRANCH.U_SLD_Building As 'Building',
BRANCH.U_SLD_Steet As 'Street',
BRANCH.U_SLD_Block As 'Block',
BRANCH.U_SLD_City As 'City',
BRANCH.U_SLD_County As 'County',
BRANCH.U_SLD_ZipCode As 'ZipCode',
BRANCH.U_SLD_Tel As 'Tel',
BRANCH.U_SLD_Fax As 'BFax',
OHEM.firstName,
OHEM.lastName,
OPRQ.DocEntry,
OPRQ.docdate,
NNM1.BeginStr, 
OPRQ.DocNum,
OPRQ.ReqName,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
  END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
OCRD.Phone1,
ISNULL(OUDP.[Name],'') AS 'Department',
(PRQ10.AftLineNum + 0.5) AS 'No.', 
PRQ10.LineSeq as 'Line No.', 
CAST(PRQ10.LineText as nvarchar (4000)) as 'Dscription', 
'0' as Quantity, 
'0' as LineTotal,
'' as unitmsr,
ISNULL(OPRQ.Comments,'') AS 'Comments',
'0' as Available,
OPRQ.ReqDate,
'' as ItemCode,
PRQ10.LineType,
' ' AS new,
PRQ1.Project,
PRQ1.U_SLD_Dis_Amount

FROM OPRQ
INNER JOIN PRQ10 ON OPRQ.DocEntry = PRQ10.DocEntry
LEFT JOIN OCRD ON OPRQ.CardCode = OCRD.CardCode 
LEFT JOIN CRD1 ON OCRD.CardCode = CRD1.CardCode AND CRD1.AdresType = 'B' AND CRD1.[Address] = OPRQ.PayToCode
LEFT JOIN NNM1 ON OPRQ.Series = NNM1.Series 
LEFT JOIN OUDP ON OPRQ.Department = OUDP.Code
LEFT JOIN OHEM ON OPRQ.Requester = OHEM.empID
LEFT JOIN OHPS ON OHEM.position = OHPS.posID
LEFT JOIN OBPL ON OPRQ.BPLId = OBPL.BPLId
--LEFT JOIN OITM ON PRQ1.ItemCode = OITM.ItemCode
--LEFT JOIN OWHS ON PRQ1.WhsCode = OWHS.WhsCode
--LEFT JOIN OITW ON PRQ1.ItemCode = OITW.ItemCode 
--LEFT JOIN OPRJ ON PRQ1.Project = OPRJ.PrjCode
LEFT JOIN OUSR ON OPRQ.UserSign = OUSR.USERID
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON OPRQ.U_SLD_LVatBranch = BRANCH.Code
left join PRQ1 on OPRQ.DocEntry = PRQ1.DocEntry

WHERE OPRQ.DocEntry  = {?DocKey@}

GROUP BY
BRANCH.[Name] ,
BRANCH.U_SLD_VComName ,
BRANCH.U_SLD_F_VComName ,
BRANCH.U_SLD_VTAXID ,
BRANCH.U_SLD_Building ,
BRANCH.U_SLD_Steet,
BRANCH.U_SLD_Block ,
BRANCH.U_SLD_City ,
BRANCH.U_SLD_County ,
BRANCH.U_SLD_ZipCode ,
BRANCH.U_SLD_Tel ,
BRANCH.U_SLD_Fax ,
OHEM.firstName,
OHEM.lastName,
OPRQ.DocEntry,
OPRQ.docdate,
NNM1.BeginStr, 
OPRQ.DocNum,
OPRQ.ReqName,
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
  END ,
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END ,
OCRD.Phone1,
ISNULL(OUDP.[Name],'') ,
(PRQ10.AftLineNum + 0.5) , 
PRQ10.LineSeq,
CAST(PRQ10.LineText as nvarchar (4000)) , 
ISNULL(OPRQ.Comments,''),
--((SUM(OITW.OnHand)-SUM(OITW.IsCommited))+SUM(OITW.OnOrder)) AS 'Available',
OPRQ.ReqDate,
PRQ10.LineType,
PRQ1.Project,
PRQ1.U_SLD_Dis_Amount

Order by 'No.' , 'Line No.'