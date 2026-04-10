SELECT OHEM.picture
FROM OPRQ
        INNER JOIN OHEM ON OPRQ."UserSign" = OHEM."userId"
        INNER JOIN 
            (select  OWDD."WddCode" , WDD1."Status" , OWDD.DocEntry , OWDD."ObjType" 
                from OWDD 
                    LEFT JOIN WDD1 ON OWDD."WddCode" = WDD1."WddCode" AND WDD1."Status" = 'Y') T6 ON OPRQ."DocEntry" = T6."DocEntry" AND T6."ObjType" = '1470000113'
                    WHERE OPRQ.DocEntry = {?DocKey@}