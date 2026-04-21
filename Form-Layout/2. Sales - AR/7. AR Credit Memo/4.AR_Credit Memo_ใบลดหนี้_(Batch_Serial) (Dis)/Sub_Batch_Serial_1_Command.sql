SELECT
    ORIN.DocEntry,
    RIN1.ItemCode,
    OITM.InvntryUom,
    Serial.SQTY,
    Serial.SerialNum,
    Batch_N.BQTY,
    Batch_N.BatchNum AS 'BATCH',
    Batch_N.ReceiveDate AS 'Bdate',
    Batch_N.ExpDate AS 'Bexp'
FROM ORIN
LEFT JOIN RIN1 ON ORIN.DocEntry = RIN1.DocEntry
LEFT JOIN OITM ON RIN1.ItemCode = OITM.ItemCode
LEFT JOIN OCRD ON ORIN.CardCode = OCRD.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND ORIN.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT JOIN (
    SELECT
        SRI.BaseEntry,
        SRI.BaseLinNum,
        SRI.ItemCode,
        SUM(SN.Quantity) AS SQTY,
        STRING_AGG(SN.DistNumber, ', ') WITHIN GROUP (ORDER BY SN.DistNumber ASC) AS SerialNum
    FROM SRI1_LINK SRI
    INNER JOIN OSRN SN ON SRI.SysSerial = SN.SysNumber AND SN.ItemCode = SRI.ItemCode
    WHERE SRI.BaseType = '14'
    GROUP BY SRI.BaseEntry, SRI.BaseLinNum, SRI.ItemCode
) AS Serial
    ON RIN1.DocEntry = Serial.BaseEntry
    AND RIN1.LineNum = Serial.BaseLinNum
    AND RIN1.ItemCode = Serial.ItemCode
LEFT JOIN (
    SELECT
        IBT.BaseEntry,
        IBT.BaseLinNum,
        IBT.ItemCode,
        SUM(IBT.Quantity) AS BQTY,
        STRING_AGG(BN.DistNumber, ', ') WITHIN GROUP (ORDER BY BN.DistNumber ASC) AS BatchNum,
        MAX(COALESCE(BN.MnfDate, BN.InDate)) AS ReceiveDate,
        MAX(BN.ExpDate) AS ExpDate
    FROM IBT1_LINK IBT
    INNER JOIN OBTN BN ON IBT.BatchNum = BN.DistNumber AND IBT.ItemCode = BN.ItemCode
    WHERE IBT.BaseType = '14'
    GROUP BY IBT.BaseEntry, IBT.BaseLinNum, IBT.ItemCode
) AS Batch_N
    ON RIN1.DocEntry = Batch_N.BaseEntry
    AND RIN1.LineNum = Batch_N.BaseLinNum
    AND RIN1.ItemCode = Batch_N.ItemCode
WHERE
    ORIN.DocEntry = {?DocKey@}
    AND RIN1.ItemCode = '{?ItemCode@}'
ORDER BY ORIN.DocEntry, RIN1.VisOrder
