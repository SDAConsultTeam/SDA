SELECT [LineText]
FROM RIN10
WHERE [DocEntry] = {?DocKey@}
  AND [AftLineNum] = -1
ORDER BY [LineSeq] ASC
