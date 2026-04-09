SELECT OINV.DocEntry, OINV.DocDate, OINV.DocDueDate, OINV.DocStatus, OINV.DocType, OINV.DocNum ,OINV.CardCode, OINV.CardName ,OINV.DocTotal,OINV.DocDate

From OINV
Where OINV.DocDate >= '2026-01-01'
And OINV.DocDate <= '2026-01-31'
And OINV.DocStatus = 'O'
And OINV.DocType = 'I'
And OINV.DocDueDate >= '2026-01-01'
And OINV.DocDueDate <= '2026-01-31'
And OINV.DocDueDate >= '2026-01-01'