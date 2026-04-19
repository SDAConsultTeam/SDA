SELECT
    OIGE.DocEntry,
    IGE1.ItemCode,
    OITM.InvntryUom,
    Serial.SQTY,
    Serial.SerialNum,
    Batch_N.BQTY,
    Batch_N.BatchNum AS 'BATCH',
    Batch_N.ReceiveDate AS 'Bdate',
    Batch_N.ExpDate AS 'Bexp'
FROM OIGE
LEFT JOIN IGE1 ON OIGE.DocEntry = IGE1.DocEntry
LEFT JOIN OITM ON IGE1.ItemCode = OITM.ItemCode
LEFT JOIN OCRD ON OIGE.CardCode = OCRD.CardCode
LEFT JOIN CRD1 ON (OCRD.CardCode = CRD1.CardCode AND OIGE.PayToCode = CRD1.Address AND CRD1.AdresType ='B')
LEFT JOIN (
    SELECT
        SRI.BaseEntry,
        SRI.BaseLinNum,
        SRI.ItemCode,
        SUM(SN.Quantity) AS SQTY,
        STRING_AGG(SN.DistNumber, ', ') WITHIN GROUP (ORDER BY SN.DistNumber ASC) AS SerialNum
    FROM SRI1_LINK SRI
    INNER JOIN OSRN SN ON SRI.SysSerial = SN.SysNumber AND SN.ItemCode = SRI.ItemCode
    WHERE SRI.BaseType = '60'
    GROUP BY SRI.BaseEntry, SRI.BaseLinNum, SRI.ItemCode
) AS Serial
    ON IGE1.DocEntry = Serial.BaseEntry
    AND IGE1.LineNum = Serial.BaseLinNum
    AND IGE1.ItemCode = Serial.ItemCode
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
    WHERE IBT.BaseType = '60'
    GROUP BY IBT.BaseEntry, IBT.BaseLinNum, IBT.ItemCode
) AS Batch_N
    ON IGE1.DocEntry = Batch_N.BaseEntry
    AND IGE1.LineNum = Batch_N.BaseLinNum
    AND IGE1.ItemCode = Batch_N.ItemCode
WHERE
    OIGE.DocEntry = {?DocKey@}
    AND IGE1.ItemCode = '{?ItemCode@}'
ORDER BY OIGE.DocEntry, IGE1.VisOrder
