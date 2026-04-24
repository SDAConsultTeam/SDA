SELECT DISTINCT
    ORPD.DocEntry,
    (RPD1.VisOrder) AS 'No.',
    RPD1.LineNum AS 'Line No.', 
    ORPD.[Address],  
    OCRD.LicTradNum, 
    OCRD.U_SLD_Title,
    OCRD.U_SLD_FullName,
    CASE 
        WHEN OCRD.Phone2 IS NULL THEN ''
        WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
    END AS 'Phone2',
    OCRD.Phone1, 
    OCRD.Fax,  
    ORPD.NumAtCard, 
    ORPD.Comments,
    RPD1.ItemCode,
    RPD1.dscription AS 'Dscription', 
    RPD1.Quantity, 
    ORPD.DocDate, 
    NNM1.BeginStr,
    ORPD.DocNum,
-----------------------------------------------------
    ISNULL(
        (
            SELECT STRING_AGG(BaseDoc, ', ')
            FROM (
                SELECT DISTINCT 
                    CASE 
                        WHEN Sub_RPD1.BaseType = 20 THEN ISNULL(Sub_N1.BeginStr, '') + CAST(Sub_OPDN.DocNum AS VARCHAR(20))
                        WHEN Sub_RPD1.BaseType = 22 THEN ISNULL(Sub_N2.BeginStr, '') + CAST(Sub_OPOR.DocNum AS VARCHAR(20))
                    END AS BaseDoc
                FROM RPD1 Sub_RPD1
                LEFT JOIN OPDN Sub_OPDN ON Sub_RPD1.BaseEntry = Sub_OPDN.DocEntry
                LEFT JOIN NNM1 Sub_N1 ON Sub_OPDN.Series = Sub_N1.Series
                LEFT JOIN OPOR Sub_OPOR ON Sub_RPD1.BaseEntry = Sub_OPOR.DocEntry
                LEFT JOIN NNM1 Sub_N2 ON Sub_OPOR.Series = Sub_N2.Series
                WHERE Sub_RPD1.DocEntry = ORPD.DocEntry 
                  AND Sub_RPD1.BaseType IN (20, 22)
            ) AS TempDistinct
        ), 
        ISNULL(NNM1.BeginStr, '') + CAST(ORPD.DocNum AS VARCHAR(20))
    ) AS 'FullDocNum',
-----------------------------------------------------
    ORPD.CreateDate,
    ORPD.CardCode,
    ORPD.U_SLD_Returnreason,
    RPD1.unitMsr,
    RPD1.LineType,
    RPD1.Project,
    OCRD.CntctPrsn,
    OCPR.E_MailL,
    OCPR.Cellolar,
    CAST(rpd12.StreetB AS nvarchar(max)) AS StreetB, 
    CAST(rpd12.StreetNoB AS nvarchar(max)) AS StreetNoB,
    CAST(rpd12.BlockB AS nvarchar(max)) AS BlockB, 
    CAST(rpd12.BuildingB AS nvarchar(max)) AS BuildingB, 
    CAST(rpd12.CityB AS nvarchar(max)) AS CityB, 
    rpd12.ZipCodeB, 
    CAST(rpd12.CountyB AS nvarchar(max)) AS CountyB, 
    rpd12.StateB,
    OCPR.Name,
    OCPR.Tel1
    
FROM ORPD 
INNER JOIN RPD1 ON ORPD.DocEntry = RPD1.DocEntry
INNER JOIN RPD12 ON ORPD.DocEntry = RPD12.DocEntry
LEFT JOIN NNM1 ON ORPD.Series = NNM1.Series
LEFT JOIN OUSR ON ORPD.UserSign = OUSR.USERID
LEFT JOIN OPRJ ON RPD1.Project = OPRJ.PrjCode
LEFT JOIN OCRD ON ORPD.CardCode = OCRD.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORPD.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT JOIN OCPR ON OCRD.CardCode = OCPR.CardCode
LEFT JOIN OITM ON RPD1.ItemCode = OITM.ItemCode
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORPD.U_SLD_LVatBranch = BRANCH.Code, OADM
WHERE ORPD.DocEntry = {?DocKey@}