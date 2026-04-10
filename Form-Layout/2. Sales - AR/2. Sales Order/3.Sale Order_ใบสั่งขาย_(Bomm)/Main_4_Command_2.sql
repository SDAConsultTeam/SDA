-- ============================================================
-- Report: 3.Sale Order_ใบสั่งขาย_(Bomm).rpt
Path:   3.Sale Order_ใบสั่งขาย_(Bomm).rpt
Extracted: 2026-04-10 10:22:54
-- Source: Main Report
-- Table:  Command_2
-- ============================================================

SELECT OHEM.picture
FROM OPRQ
        INNER JOIN OHEM ON OPRQ."UserSign" = OHEM."userId"
        INNER JOIN 
            (select  OWDD."WddCode" , WDD1."Status" , OWDD.DocEntry , OWDD."ObjType" 
                from OWDD 
                    LEFT JOIN WDD1 ON OWDD."WddCode" = WDD1."WddCode" AND WDD1."Status" = 'Y') T6 ON OPRQ."DocEntry" = T6."DocEntry" AND T6."ObjType" = '1470000113'
                    WHERE OPRQ.DocEntry = {?DocKey@}
