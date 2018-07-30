
/* General Integrity Fixes */

BEGIN TRAN

/*Remove orphaned links to missing sDemandPart */
UPDATE sStock
SET sDemandPart_ID = 0
FROM sStock
LEFT JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
WHERE sDemandPart.ID IS NULL AND sStock.sDemandPart_ID > 0

GO

/*Remove FK to Issued sDemandPart */
UPDATE sStock
SET sDemandPart_ID = 0
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
WHERE sDemandItemStatus.Issued = 1

GO

/*Remove FK to completed sDemandPart */
UPDATE sStock
SET sDemandPart_ID = 0
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID
WHERE sDemandItemStatus.Completed = 1 AND sPartTransactionType.Replenishment = 1

GO

/* Fix missing stock ownerships */
UPDATE sStock
SET sStockOwnership_ID = sOrderPartReceipt.sStockOwnership_ID
FROM sStock
JOIN sOrderPartReceipt ON sOrderPartReceipt.ID = sStock.sOrderPartReceipt_ID
WHERE sStock.sStockOwnership_ID = 0

GO

/* Fix missing stock locations */
UPDATE sStock
SET sBaseWarehouseLocation_ID = 
ISNULL(
	(SELECT TOP 1 sBaseWarehouseLocation_ID FROM sStockLog WHERE BaseTableID = sStock.ID  AND sBaseWarehouseLocation_ID > 0 ORDER BY ID DESC) ,  -- Try and get location from sStockLog first
	(SELECT TOP 1 sBaseWarehouseLocation_ID FROM sOrderPartReceipt WHERE ID = sStock.sOrderPartReceipt_ID ORDER BY ID DESC))	  -- Otherwise, get from receipt
FROM sStock 
LEFT JOIN sBaseWarehouseLocation ON sStock.sBaseWarehouseLocation_ID = sBaseWarehouseLocation.ID 
WHERE sBaseWarehouseLocation.ID IS NULL

GO

ROLLBACK TRAN