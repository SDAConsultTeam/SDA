SELECT picture 
FROM OQUT 
LEFT JOIN OHEM ON OQUT.SlpCode = OHEM.salesPrson
WHERE OQUT.DocEntry  = {?Dockey@}