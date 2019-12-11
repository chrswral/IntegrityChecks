
/******* WARNING - Probably contains errors, use with caution and check results in client */

/* TODO - Check despatch issues for IBT's and make sure don't get counted in BaseTransfers */

DECLARE @ReceiptID int = 49215

;WITH Issues AS (
SELECT uRALBase_ID, SUM(Qty) Qty
FROM sDemandPart
JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID
WHERE sOrderPartReceipt_ID	= @ReceiptID
AND (sDemandItemStatus.Issued = 1 OR sDemandItemStatus.Credit = 1)
GROUP BY uRALBase_ID) 

, Receipts AS (
SELECT uRALBase_ID, SUM(Qty) Qty
FROM sOrderPartReceipt
JOIN sOrderPartReceiptStatus ON sOrderPartReceiptStatus.ID = sOrderPartReceiptStatus_ID
JOIN sBaseWarehouseLocation ON sBaseWarehouseLocation.ID = sBaseWarehouseLocation_ID
JOIN sBaseWarehouse ON sBaseWarehouse.ID = sBaseWarehouse_ID
WHERE sOrderPartReceipt.ID = @ReceiptID
AND sOrderPartReceiptStatus.Inspection = 0
GROUP BY uRALBase_ID)

, BaseTransfersOut AS (
SELECT uRALBase_ID, SUM(Qty) Qty
FROM sBaseWarehouseLocationHistory
JOIN sBaseWarehouseLocation ON sBaseWarehouseLocation.ID = sBaseWarehouseLocation_IDFrom
JOIN sBaseWarehouse ON sBaseWarehouse.ID = sBaseWarehouse_ID
WHERE sOrderPartReceipt_ID = @ReceiptID
GROUP BY uRALBase_ID)

, BaseTransfersIn AS (
SELECT uRALBase_ID, SUM(Qty) Qty
FROM sBaseWarehouseLocationHistory
JOIN sBaseWarehouseLocation ON sBaseWarehouseLocation.ID = sBaseWarehouseLocation_IDTo
JOIN sBaseWarehouse ON sBaseWarehouse.ID = sBaseWarehouse_ID
WHERE sOrderPartReceipt_ID = @ReceiptID
GROUP BY uRALBase_ID)

, Stock AS (
SELECT uRALBase_ID, SUM(Qty) Qty
FROM sStock 
JOIN sBaseWarehouseLocation ON sBaseWarehouseLocation.ID = sBaseWarehouseLocation_ID
JOIN sBaseWarehouse ON sBaseWarehouse.ID = sBaseWarehouse_ID
WHERE sOrderPartReceipt_ID = @ReceiptID
GROUP BY uRALBase_ID)

SELECT uRALBase.ID
, RALBase
, ISNULL(Receipts.Qty,0) Receipts
, ISNULL(BaseTransfersIn.Qty,0) IBTIn
, ISNULL(BaseTransfersOut.Qty,0) IBTOut
, ISNULL(Issues.Qty,0) Issues
, ISNULL(Stock.Qty,0) Stock
, ISNULL(Receipts.Qty,0) + ISNULL(BaseTransfersIn.Qty,0) - ISNULL(BaseTransfersOut.Qty,0) - ISNULL(Issues.Qty,0) - ISNULL(Stock.Qty,0) AS Diff
FROM uRALBase
LEFT JOIN Receipts ON Receipts.uRALBase_ID = uRALBase.ID
LEFT JOIN BaseTransfersIn ON BaseTransfersIn.uRALBase_ID = uRALBase.ID
LEFT JOIN BaseTransfersOut ON BaseTransfersOut.uRALBase_ID = uRALBase.ID
LEFT JOIN Issues ON Issues.uRALBase_ID = uRALBase.ID
LEFT JOIN Stock ON Stock.uRALBase_ID = uRALBase.ID
WHERE ISNULL(Receipts.Qty,0) + ISNULL(BaseTransfersIn.Qty,0) + ISNULL(BaseTransfersOut.Qty,0) + ISNULL(Issues.Qty,0) + ISNULL(Stock.Qty,0) > 0