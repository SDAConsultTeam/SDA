SELECT 
    TOP 1 RPD10.LineText
FROM RPD1 
INNER JOIN RPD10 ON RPD1.[DocEntry] = RPD10.[DocEntry] AND RPD10.AftLineNum = 0
WHERE RPD1.[DocEntry] = {?DocKey@}