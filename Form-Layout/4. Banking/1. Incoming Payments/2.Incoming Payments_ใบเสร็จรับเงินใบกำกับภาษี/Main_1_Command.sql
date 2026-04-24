SELECT DISTINCT
    ORCT.Comments,
    CONCAT(OCPR.FirstName, ' ', OCPR.LastName) AS 'Coontact',
    BRANCH.Code,
    
    CASE 
        WHEN BRANCH.Code = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำนักงานใหญ่' 
        WHEN BRANCH.Code = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Head office' 
        WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN CONCAT(N'สาขาที่', ' ', BRANCH.Code) 
        WHEN BRANCH.Code <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN CONCAT('Branch', ' ', BRANCH.Code) 
    END AS 'GLN_H',
    
    CASE 
        WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN N'(สำนักงานใหญ่)' 
        WHEN CRD1.GlblLocNum = '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN '(Head office)' 
        WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr = OADM.MainCurncy THEN CONCAT(N'(สาขาที่', ' ', CRD1.GlblLocNum, ')') 
        WHEN CRD1.GlblLocNum <> '00000' AND ORCT.DocCurr <> OADM.MainCurncy THEN CONCAT('(Branch', ' ', CRD1.GlblLocNum, ')') 
        WHEN CRD1.GlblLocNum = '' OR CRD1.GlblLocNum IS NULL THEN ''
    END AS 'GLN_BP',

    CASE 
        WHEN ORCT.Printed = 'N' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Original'
        WHEN ORCT.Printed = 'N' AND ORCT.DocCurr = OADM.MainCurncy THEN N'ต้นฉบับ' 
        WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr <> OADM.MainCurncy THEN 'Copy'  
        WHEN ORCT.Printed = 'Y' AND ORCT.DocCurr = OADM.MainCurncy THEN N'สำเนา'
    END AS 'Print Status',

    BRANCH.[Name] AS 'BranchName',
    BRANCH.U_SLD_VTAXID AS 'TaxIdNum',
    BRANCH.U_SLD_VComName AS 'PrintHeadr',
    BRANCH.U_SLD_F_VComName AS 'PrintHdrF',
    
    CASE WHEN ORCT.DocCurr = OADM.MainCurncy THEN BRANCH.U_SLD_Building ELSE BRANCH.U_SLD_F_Building END AS 'Building',
    CASE WHEN ORCT.DocCurr = OADM.MainCurncy THEN BRANCH.U_SLD_Steet  ELSE BRANCH.U_SLD_F_Steet END AS 'Street',
    CASE WHEN ORCT.DocCurr = OADM.MainCurncy THEN BRANCH.U_SLD_Block  ELSE BRANCH.U_SLD_F_Block END AS 'Block',
    CASE WHEN ORCT.DocCurr = OADM.MainCurncy THEN BRANCH.U_SLD_City  ELSE BRANCH.U_SLD_F_City END AS 'City',
    CASE WHEN ORCT.DocCurr = OADM.MainCurncy THEN BRANCH.U_SLD_County ELSE BRANCH.U_SLD_F_County END AS 'County',
    
    BRANCH.U_SLD_ZipCode AS 'ZipCode',
    BRANCH.U_SLD_Tel AS 'Tel',
    BRANCH.U_SLD_Fax AS 'BFax',
    BRANCH.U_SLD_Email AS 'E-Mail',
--------------------------------------------------------------------------------------------------------
    CONVERT(NVARCHAR, ORCT.DocNum) AS 'RecNo', 
    (RCT2.InvoiceId + 1) AS 'No.',
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
    
    SupR_Vat.VatSum,
    SupR_Vat.VatSumFC,
    SupR_D.DocTotal,
    SupR_D.DocTotalFC, 
    
    ORCT.DocTotal AS 'T Total',
    ORCT.DocTotalFC AS 'F Total', 
    ORCT.CounterRef, 
    ORCT.DocDueDate,
    OCRD.LicTradNum,
    OCRD.U_SLD_Title,
    OCRD.U_SLD_FullName,
    OCPR.Cellolar,
    OCPR.E_MailL,
    OCPR.Name,
    OCPR.Tel1,

    CASE 
        WHEN OCRD.Phone2 IS NULL THEN ''
        WHEN OCRD.Phone2 IS NOT NULL THEN ', ' + OCRD.Phone2
    END AS 'Phone2',
    OCRD.Phone1,
    OCRD.Fax,	
    
    CASE WHEN RCT2.InvType = '14' THEN (RCT2.SumApplied * -1) ELSE RCT2.SumApplied END AS 'SumApplied', 
    CASE WHEN RCT2.InvType = '14' THEN (RCT2.AppliedFC * -1) ELSE RCT2.AppliedFC END AS 'AppliedFC',
    
    CASE 
        WHEN RCT2.InvType = '13' THEN CONVERT(NVARCHAR, OINV.DocNum)
        WHEN RCT2.InvType = '14' THEN CONVERT(NVARCHAR, ORIN.DocNum)
        WHEN RCT2.InvType = '203' THEN CONVERT(NVARCHAR, ODPI.DocNum)
        WHEN RCT2.InvType = '30' THEN CONVERT(NVARCHAR, OJDT.Number)
    END AS 'INVNo', 
    
    CASE 
        WHEN RCT2.InvType = '13' THEN OINV.TaxDate
        WHEN RCT2.InvType = '14' THEN ORIN.TaxDate
        WHEN RCT2.InvType = '203' THEN ODPI.TaxDate
        WHEN RCT2.InvType = '30' THEN OJDT.TaxDate
    END AS 'INVDate', 
    
    CASE 
        WHEN RCT2.InvType = '13' THEN OINV.DocDueDate
        WHEN RCT2.InvType = '14' THEN ORIN.DocDueDate
        WHEN RCT2.InvType = '203' THEN ODPI.DocDueDate
        WHEN RCT2.InvType = '30' THEN OJDT.DueDate
    END AS 'INVDueDate', 
    
    T_REC.BeginStr AS 'RECBeginStr',	
    
    CASE 
        WHEN RCT2.InvType = '13' THEN T_OINV.BeginStr
        WHEN RCT2.InvType = '14' THEN T_ORIN.BeginStr
        WHEN RCT2.InvType = '203' THEN T_ODPI.BeginStr
        WHEN RCT2.InvType = '30' THEN T_OJDT.BeginStr
    END AS 'INVBeginStr', 
    
    CONVERT(NVARCHAR(100), OCRD.Building) AS 'BPBuilding', 
    OCTG.PymntGroup,
    ORCT.TrsfrSum,
    ORCT.CashSum,
    RCT1.[CheckSum],
    (RCT1.LineID + 1) AS 'LineID',
    RCT1.CheckNum,
    ODSC.BankName,
    RCT1.DueDate,
    ORCT.PrjCode

    -- ----------------------------------------------------
    -- ส่วนที่เพิ่มเข้ามาใหม่: ดึง Project ระดับ Line
    -- ----------------------------------------------------
     --CASE 
        --WHEN RCT2.InvType = '13' THEN (SELECT TOP 1 Project FROM INV1 WHERE DocEntry = RCT2.BASEABS AND ISNULL(Project, '') <> '')
        --WHEN RCT2.InvType = '14' THEN (SELECT TOP 1 Project FROM RIN1 WHERE DocEntry = RCT2.BASEABS AND ISNULL(Project, '') <> '')
        --WHEN RCT2.InvType = '203' THEN (SELECT TOP 1 Project FROM DPI1 WHERE DocEntry = RCT2.BASEABS AND ISNULL(Project, '') <> '')
        --WHEN RCT2.InvType = '30' THEN (SELECT TOP 1 Project FROM JDT1 WHERE TransId = RCT2.BASEABS AND ISNULL(Project, '') <> '')
        --ELSE NULL
    --END AS 'Project'

  
FROM ORCT 
LEFT JOIN RCT2 ON ORCT.DocENTRY = RCT2.DocNum
LEFT JOIN RCT1 ON ORCT.DocEntry = RCT1.DocNum

-- Document Headers
LEFT JOIN OINV ON RCT2.InvType = '13' AND RCT2.BASEABS = OINV.DocEntry
LEFT JOIN ORIN ON RCT2.InvType = '14' AND RCT2.BASEABS = ORIN.DocEntry
LEFT JOIN ODPI ON RCT2.InvType = '203' AND RCT2.BASEABS = ODPI.DocEntry
LEFT JOIN OJDT ON RCT2.InvType = '30' AND RCT2.BASEABS = OJDT.TransId

-- Document Lines (ส่วนที่เพิ่มเข้ามาใหม่เพื่อเข้าถึงระดับไลน์)
LEFT JOIN INV1 ON RCT2.InvType = '13' AND OINV.DocEntry = INV1.DocEntry
LEFT JOIN RIN1 ON RCT2.InvType = '14' AND ORIN.DocEntry = RIN1.DocEntry
LEFT JOIN DPI1 ON RCT2.InvType = '203' AND ODPI.DocEntry = DPI1.DocEntry
LEFT JOIN JDT1 ON RCT2.InvType = '30' AND OJDT.TransId = JDT1.TransId 

-- Master Data Project (ผูกกับ Project ของแต่ละประเภทเอกสาร)
LEFT JOIN OPRJ ON OPRJ.PrjCode = 
    CASE 
        WHEN RCT2.InvType = '13' THEN INV1.Project
        WHEN RCT2.InvType = '14' THEN RIN1.Project
        WHEN RCT2.InvType = '203' THEN DPI1.Project
        WHEN RCT2.InvType = '30' THEN JDT1.Project
    END

-- Subquery สำหรับหา DocTotal รวม
LEFT JOIN (
    SELECT 
        SR2.DocNum AS DocEntry,
        SUM(
            CASE 
                WHEN SR2.InvType = '13' THEN (SOINV.DocTotal - SOINV.VatSum)
                WHEN SR2.InvType = '14' THEN (SORIN.DocTotal - SORIN.VatSum) * -1
                WHEN SR2.InvType = '203' THEN (SODPI.DocTotal - SODPI.VatSum)
                WHEN SR2.InvType = '30' THEN SR2.SumApplied
                ELSE 0 
            END
        ) AS 'DocTotal',
        SUM(
            CASE 
                WHEN SR2.InvType = '13' THEN (SOINV.DocTotalFC - SOINV.VatSumFC)
                WHEN SR2.InvType = '14' THEN (SORIN.DocTotalFC - SORIN.VatSumFC) * -1
                WHEN SR2.InvType = '203' THEN (SODPI.DocTotalFC - SODPI.VatSumFC)
                WHEN SR2.InvType = '30' THEN SR2.AppliedFC
                ELSE 0
            END
        ) AS 'DocTotalFC'
    FROM RCT2 SR2
    LEFT JOIN OINV SOINV ON SR2.InvType = '13' AND SR2.BASEABS = SOINV.DocEntry
    LEFT JOIN ORIN SORIN ON SR2.InvType = '14' AND SR2.BASEABS = SORIN.DocEntry
    LEFT JOIN ODPI SODPI ON SR2.InvType = '203' AND SR2.BASEABS = SODPI.DocEntry
    WHERE SR2.DocNum = {?DocKey@}
    GROUP BY SR2.DocNum
) AS SupR_D ON ORCT.DocEntry = SupR_D.DocEntry 

-- Subquery สำหรับหา VatTotal รวม
LEFT JOIN (
    SELECT 
        VR2.DocNum AS DocEntry,
        SUM(
            CASE 
                WHEN VR2.InvType = '13' THEN SOINV.VatSum
                WHEN VR2.InvType = '14' THEN SORIN.VatSum * -1
                WHEN VR2.InvType = '203' THEN SODPI.VatSum
                WHEN VR2.InvType = '30' THEN SORCT.VatSum 
                ELSE 0 
            END
        ) AS 'VatSum',
        SUM(
            CASE 
                WHEN VR2.InvType = '13' THEN SOINV.VatSumFC
                WHEN VR2.InvType = '14' THEN SORIN.VatSumFC * -1
                WHEN VR2.InvType = '203' THEN SODPI.VatSumFC
                WHEN VR2.InvType = '30' THEN SORCT.VatSumFC 
                ELSE 0 
            END
        ) AS 'VatSumFC'
    FROM RCT2 VR2
    LEFT JOIN OINV SOINV ON VR2.InvType = '13' AND VR2.BASEABS = SOINV.DocEntry
    LEFT JOIN ORIN SORIN ON VR2.InvType = '14' AND VR2.BASEABS = SORIN.DocEntry
    LEFT JOIN ODPI SODPI ON VR2.InvType = '203' AND VR2.BASEABS = SODPI.DocEntry
    LEFT JOIN ORCT SORCT ON VR2.InvType = '30' AND VR2.DocNum = SORCT.DocEntry 
    WHERE VR2.DocNum = {?DocKey@}
    GROUP BY VR2.DocNum
) SupR_Vat ON ORCT.DocEntry = SupR_Vat.DocEntry

LEFT JOIN ODSC ON RCT1.BankCode = ODSC.BankCode
LEFT OUTER JOIN OACT ON ORCT.CashAcct = OACT.AcctCode 
LEFT OUTER JOIN NNM1 T_REC ON ORCT.Series = T_REC.Series 

LEFT OUTER JOIN NNM1 T_OINV ON OINV.Series = T_OINV.Series
LEFT OUTER JOIN NNM1 T_ORIN ON ORIN.Series = T_ORIN.Series
LEFT OUTER JOIN NNM1 T_ODPI ON ODPI.Series = T_ODPI.Series
LEFT OUTER JOIN NNM1 T_OJDT ON OJDT.Series = T_OJDT.Series

LEFT OUTER JOIN OCRD ON ORCT.CardCode = OCRD.CardCode
LEFT OUTER JOIN OCPR ON ORCT.CardCode = OCPR.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORCT.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT OUTER JOIN OCRG ON OCRD.GroupCode = OCRG.GroupCode
LEFT JOIN OUSR ON ORCT.UserSign = OUSR.USERID
LEFT JOIN OCTG ON OCRD.GroupNum = OCTG.GroupNum
LEFT JOIN [dbo].[@SLDT_SET_BRANCH] BRANCH ON ORCT.U_SLD_VatBranch = BRANCH.Code
CROSS JOIN OADM

WHERE ORCT.DocENTRY = {?DocKey@}
ORDER BY 13