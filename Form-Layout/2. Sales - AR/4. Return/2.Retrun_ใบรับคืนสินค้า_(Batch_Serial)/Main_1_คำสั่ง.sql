SELECT distinct
RDN12.StreetB     AS '1Bill',
    RDN12.StreetNoB   AS '2Bill',
    RDN12.BlockB      AS '3Bill',
    RDN12.CityB       AS '4Bill',
    RDN12.CountyB     AS '5Bill',
    RDN12.ZipCodeB    AS '6Bill',
        RDN12.StreetS     AS '1Ship',
    RDN12.StreetNoS   AS '2Ship',
    RDN12.BlockS      AS '3Ship',
    RDN12.CityS       AS '4Ship',
    RDN12.CountyS     AS '5Ship',
    RDN12.ZipCodeS    AS '6Ship',
ORDN.[CardCode],
ORDN.[Comments],
RDN1.[ItemCode],
RDN1.[dscription] as 'Dscription',
RDN1.[Quantity],
ORDN.[DocDate],
ORDN.[DocNum],
ORDN.[DocEntry],
NNM1.[BeginStr],
ORDN.[CreateDate],
RDN1.[unitMsr],
(RDN1.[VisOrder]) As 'No.',
RDN1.LineNum as 'Line No.', 
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
OCRD.LicTradNum ,
OPRJ.PrjCode,
CASE 
  WHEN CRD1.GlblLocNum IS NULL THEN ''
  WHEN CRD1.GlblLocNum = '00000' THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
  END 'GLN',
CASE WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
RDN1.LineType,
OCPR.Name,
OCPR.Cellolar,
OCPR.E_MailL
FROM ORDN  
INNER JOIN RDN1 ON ORDN.[DocEntry] = RDN1.[DocEntry]
LEFT JOIN RDN12 ON ORDN.DocEntry = RDN12.DocEntry 
LEFT JOIN OCRD ON ORDN.CardCode = OCRD.CardCode
LEFT JOIN OCPR ON ORDN.CntctCode = OCPR.CntctCode
LEFT JOIN CRD1 ON (ORDN.[CardCode] = CRD1.[CardCode] AND ORDN.[PayToCode] = CRD1.[Address] AND CRD1.[AdresType] ='B')
LEFT JOIN NNM1 ON ORDN.[Series] = NNM1.[Series]
LEFT JOIN OUSR ON ORDN.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON RDN1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORDN.U_SLD_LVatBranch = BRANCH.Code , oadm
WHERE ORDN.[DocEntry] = {?DocKey@}
Union all
SELECT distinct
RDN12.StreetB     AS '1Bill',
    RDN12.StreetNoB   AS '2Bill',
    RDN12.BlockB      AS '3Bill',
    RDN12.CityB       AS '4Bill',
    RDN12.CountyB     AS '5Bill',
    RDN12.ZipCodeB    AS '6Bill',
        RDN12.StreetS     AS '1Ship',
    RDN12.StreetNoS   AS '2Ship',
    RDN12.BlockS      AS '3Ship',
    RDN12.CityS       AS '4Ship',
    RDN12.CountyS     AS '5Ship',
    RDN12.ZipCodeS    AS '6Ship',
ORDN.[CardCode],
ORDN.[Comments],
'' as [ItemCode],
CAST(RDN10.LineText as nvarchar(4000)) as 'Dscription',
'0' as [Quantity],
ORDN.[DocDate],
ORDN.[DocNum],
ORDN.[DocEntry],
NNM1.[BeginStr],
ORDN.[CreateDate],
'' as [unitMsr],
(RDN10.AftLineNum + 0.5) As 'No.', 
RDN10.LineSeq as 'Line No.', 
OCRD.U_SLD_Title,
OCRD.U_SLD_FullName,
OCRD.LicTradNum ,
'' AS 'PrjCode',
CASE 
  WHEN CRD1.GlblLocNum IS NULL THEN ''
  WHEN CRD1.GlblLocNum = '00000' THEN N'(สำนักงานใหญ่)'
  WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
  END 'GLN',
CASE 
  WHEN OCRD.Phone2 IS NULL THEN ''
  WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
  END 'Phone2',
RDN10.LineType,
OCPR.Name,
OCPR.Cellolar,
OCPR.E_MailL
FROM ORDN  
INNER JOIN RDN10 ON ORDN.[DocEntry] = RDN10.[DocEntry]
LEFT JOIN RDN12 ON ORDN.DocEntry = RDN12.DocEntry 
LEFT JOIN OCRD ON ORDN.CardCode = OCRD.CardCode
LEFT JOIN OCPR ON ORDN.CntctCode = OCPR.CntctCode
LEFT JOIN CRD1 ON (ORDN.[CardCode] = CRD1.[CardCode] AND ORDN.[PayToCode] = CRD1.[Address] AND CRD1.[AdresType] ='B')
LEFT JOIN NNM1 ON ORDN.[Series] = NNM1.[Series]
LEFT JOIN OUSR ON ORDN.UserSign = OUSR.USERID
--LEFT JOIN OPRJ ON RDN1.Project = OPRJ.PrjCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORDN.U_SLD_LVatBranch = BRANCH.Code , oadm
WHERE ORDN.[DocEntry] = {?DocKey@}
Order by 'No.' , 'Line No.'
