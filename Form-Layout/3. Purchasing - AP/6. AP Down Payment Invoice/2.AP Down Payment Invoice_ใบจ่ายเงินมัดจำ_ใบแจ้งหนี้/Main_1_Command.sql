SELECT DISTINCT
    CONCAT(OCPR.FirstName,' ',OCPR.LastName) AS 'Coontact',
    
    CASE WHEN BRANCH.Code = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำนักงานใหญ่'
         WHEN BRANCH.Code = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Head office' 
         WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN CONCAT(N'สาขาที่' ,' ',BRANCH.Code) 
         WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN CONCAT('Branch' ,' ',BRANCH.Code) 
    END AS 'GLN_H',
    
    CASE WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
         WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN '(Head office)' 
         WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN CONCAT(N'(สาขาที่' ,' ',CRD1.GlblLocNum,')') 
         WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN CONCAT('(Branch' ,' ',CRD1.GlblLocNum,')') 
         WHEN CRD1.GlblLocNum = '' OR CRD1.GlblLocNum IS NULL THEN ''
    END AS 'GLN_BP',

    CASE WHEN ORCT.Printed = 'N' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Original'
         WHEN ORCT.Printed = 'N' AND ORCT.DocCurr = OADM.MainCurncy THEN N'ต้นฉบับ' 
         WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Copy'  
         WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำเนา'
    END AS 'Print Status',
    
    CONVERT(NVARCHAR, ORCT.DocNum) AS 'RecNo',
    (RCT2.InvoiceId + 1) As 'No.',
    ORCT.DocENTRY,
    ORCT.TaxDate,  
    ORCT.CardCode, 
    
    CAST('<X>' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(ORCT.[Address], ''), '&', '&amp;'), '<', '&lt;'), CHAR(13)+CHAR(10), CHAR(13)), CHAR(10), CHAR(13)), CHAR(13), '</X><X>') + '</X>' AS XML).value('(/X)[1]', 'NVARCHAR(250)') AS 'AddressLine1',
    CAST('<X>' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(ORCT.[Address], ''), '&', '&amp;'), '<', '&lt;'), CHAR(13)+CHAR(10), CHAR(13)), CHAR(10), CHAR(13)), CHAR(13), '</X><X>') + '</X>' AS XML).value('(/X)[2]', 'NVARCHAR(250)') AS 'AddressLine2',
    CAST('<X>' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(ORCT.[Address], ''), '&', '&amp;'), '<', '&lt;'), CHAR(13)+CHAR(10), CHAR(13)), CHAR(10), CHAR(13)), CHAR(13), '</X><X>') + '</X>' AS XML).value('(/X)[3]', 'NVARCHAR(250)') AS 'AddressLine3',
    CAST('<X>' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(ORCT.[Address], ''), '&', '&amp;'), '<', '&lt;'), CHAR(13)+CHAR(10), CHAR(13)), CHAR(10), CHAR(13)), CHAR(13), '</X><X>') + '</X>' AS XML).value('(/X)[4]', 'NVARCHAR(250)') AS 'AddressLine4',
    CAST('<X>' + REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(ORCT.[Address], ''), '&', '&amp;'), '<', '&lt;'), CHAR(13)+CHAR(10), CHAR(13)), CHAR(10), CHAR(13)), CHAR(13), '</X><X>') + '</X>' AS XML).value('(/X)[5]', 'NVARCHAR(250)') AS 'AddressLine5',
    -- ==========================================================
    
    ORCT.DocCurr AS 'RctDocCurr', 
    ORCT.DocTotal,
    ORCT.DocTotalFC, 
    ORCT.CounterRef, 
    ORCT.DocDueDate,
    OCRD.LicTradNum,
    OCRD.U_SLD_Title,
    OCRD.U_SLD_FullName,
    
    CASE WHEN CRD1.GlblLocNum IS NULL THEN ''
         WHEN CRD1.GlblLocNum IS NOT NULL THEN N'สาขาที่ ' + CRD1.GlblLocNum
    END AS 'GLN',
    
    CASE WHEN OCRD.Phone2 IS NULL THEN ''
         WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
    END AS 'Phone2',
    
    OCRD.Phone1,
    OCRD.Fax,
    OCPR.Cellolar,
    OCPR.E_MailL,	
    
    CASE WHEN RCT2.InvType = '14' THEN (RCT2.SumApplied * -1) ELSE RCT2.SumApplied END AS 'SumApplied', 
    CASE WHEN RCT2.InvType = '14' THEN (RCT2.AppliedFC * -1) ELSE RCT2.AppliedFC END AS 'AppliedFC',
    
    CONVERT(NVARCHAR, COALESCE(OINV.DocNum, ORIN.DocNum, ODPI.DocNum, OJDT.Number)) AS 'INVNo', 
    COALESCE(OINV.TaxDate, ORIN.TaxDate, ODPI.TaxDate, OJDT.TaxDate) AS 'INVDate', 
    COALESCE(OINV.DocDueDate, ORIN.DocDueDate, ODPI.DocDueDate, OJDT.DueDate) AS 'INVDueDate', 
    
    -- ===== เพิ่ม Field Project ระดับ Line =====
    CASE 
        WHEN RCT2.InvType = '13' THEN (SELECT TOP 1 Project FROM INV1 WHERE DocEntry = RCT2.BASEABS AND ISNULL(Project, '') <> '')
        WHEN RCT2.InvType = '14' THEN (SELECT TOP 1 Project FROM RIN1 WHERE DocEntry = RCT2.BASEABS AND ISNULL(Project, '') <> '')
        WHEN RCT2.InvType = '203' THEN (SELECT TOP 1 Project FROM DPI1 WHERE DocEntry = RCT2.BASEABS AND ISNULL(Project, '') <> '')
        WHEN RCT2.InvType = '30' THEN (SELECT TOP 1 Project FROM JDT1 WHERE TransId = RCT2.BASEABS AND ISNULL(Project, '') <> '')
        ELSE NULL
    END AS 'Project',
    -- ==========================================

    NNM1_REC.BeginStr AS 'RECBeginStr',		
    COALESCE(NNM1_INV.BeginStr, NNM1_RIN.BeginStr, NNM1_DPI.BeginStr, NNM1_JDT.BeginStr) AS 'INVBeginStr', 
    
    CONVERT(NVARCHAR(100), OCRD.Building) As 'BPBuilding', 
    OCTG.PymntGroup,
    ORCT.TrsfrSum,
    ORCT.CashSum,
    RCT1.[CheckSum],
    RCT1.CheckNum,
    ODSC.BankName,
    RCT1.DueDate

FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum
LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN OACT ON ORCT.CashAcct = OACT.AcctCode 
LEFT OUTER JOIN OCRD ON ORCT.CardCode = OCRD.CardCode
LEFT OUTER JOIN OCPR ON ORCT.CardCode = OCPR.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORCT.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT OUTER JOIN OCRG ON OCRD.GroupCode = OCRG.GroupCode
LEFT JOIN OUSR ON ORCT.UserSign = OUSR.USERID
LEFT JOIN OCTG ON OCRD.GroupNum = OCTG.GroupNum
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORCT.U_SLD_VatBranch = BRANCH.Code


LEFT OUTER JOIN NNM1 NNM1_REC ON ORCT.Series = NNM1_REC.Series
LEFT JOIN OINV ON RCT2.InvType = '13' AND RCT2.BASEABS = OINV.DocEntry
LEFT JOIN INV1 ON OINV.DocEntry = INV1.DocEntry
LEFT OUTER JOIN NNM1 NNM1_INV ON OINV.Series = NNM1_INV.Series
LEFT JOIN OPRJ OPRJ_INV ON INV1.Project = OPRJ_INV.PrjCode
LEFT JOIN ORIN ON RCT2.InvType = '14' AND RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
LEFT OUTER JOIN NNM1 NNM1_RIN ON ORIN.Series = NNM1_RIN.Series
LEFT JOIN OPRJ OPRJ_RIN ON RIN1.Project = OPRJ_RIN.PrjCode
LEFT JOIN ODPI ON RCT2.InvType = '203' AND RCT2.BASEABS = ODPI.DocEntry
LEFT JOIN DPI1 ON ODPI.DocEntry = DPI1.DocEntry
LEFT OUTER JOIN NNM1 NNM1_DPI ON ODPI.Series = NNM1_DPI.Series
LEFT OUTER JOIN OJDT ON RCT2.InvType = '30' AND RCT2.BASEABS = OJDT.TransId
LEFT OUTER JOIN NNM1 NNM1_JDT ON OJDT.Series = NNM1_JDT.Series
CROSS JOIN OADM
WHERE RCT2.InvType IN ('13', '14', '203', '30')
AND ORCT.DocENTRY = {?DocKey@}

ORDER BY 13