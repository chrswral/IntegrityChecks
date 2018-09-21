CREATE PROCEDURE sup.GeneralIntegrityFixes
AS 

SET XACT_ABORT ON 

/* Create Pending Table */
DECLARE @AuditHistoryPending TABLE (
    BaseTableID INT NOT NULL,
    Fix VARCHAR(50) NOT NULL,
    BaseTable VARCHAR(50)
)

BEGIN TRANSACTION

/* Delete Stock records without valid receipts */
DELETE sStock
OUTPUT deleted.ID,'Deleted: Missing Receipt','sStock'
INTO @AuditHistoryPending   
FROM sStock
LEFT JOIN sOrderPartReceipt ON sStock.sOrderPartReceipt_ID = sOrderPartReceipt.ID
WHERE sOrderPartReceipt.ID IS NULL

/*Remove orphaned links to missing sDemandPart */
UPDATE sStock
SET sStockOwnership_ID = sOrderPartReceipt.sStockOwnership_ID
OUTPUT deleted.ID,'Missing Stock Ownership','sStock' 
INTO @AuditHistoryPending
FROM sStock 
JOIN sOrderPartReceipt ON sOrderPartReceipt.ID = sStock.sOrderPartReceipt_ID
WHERE sStock.sStockOwnership_ID = 0

/* Fix missing stock locations */
UPDATE sStock
SET sBaseWarehouseLocation_ID = 
ISNULL(
	(SELECT TOP 1 sBaseWarehouseLocation_ID FROM sStockLog WHERE BaseTableID = sStock.ID  AND sBaseWarehouseLocation_ID > 0 ORDER BY ID DESC) ,  -- Try and get location from sStockLog first
	(SELECT TOP 1 sBaseWarehouseLocation_ID FROM sOrderPartReceipt WHERE ID = sStock.sOrderPartReceipt_ID ORDER BY ID DESC))	  -- Otherwise, get from receipt
OUTPUT deleted.ID,'Missing Location','sStock'
INTO @AuditHistoryPending    
FROM sStock 
LEFT JOIN sBaseWarehouseLocation ON sStock.sBaseWarehouseLocation_ID = sBaseWarehouseLocation.ID 
WHERE sBaseWarehouseLocation.ID IS NULL


/*Remove FK to completed sDemandPart */
UPDATE sStock
SET sDemandPart_ID = 0
OUTPUT deleted.ID,'Remove FK to completed sDemandPart','sStock'
INTO @AuditHistoryPending
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID
WHERE sDemandItemStatus.Completed = 1 AND sPartTransactionType.Replenishment = 1

/*Remove FK to Issued sDemandPart */
UPDATE sStock
SET sDemandPart_ID = 0
OUTPUT deleted.ID,'Remove FK to Issued sDemandPart','sStock'
INTO @AuditHistoryPending
FROM sStock 
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID 
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID 
JOIN sPart on sPart_IDDemanded = sPart.ID
JOIN sPartClassification on sPartClassification.ID = sPart.sPartClassification_ID
WHERE sDemandItemStatus.Issued = 1 and sPartClassification.Tool <> 1


/*Remove orphaned links to missing sDemandPart */
UPDATE sStock
SET sDemandPart_ID = 0
OUTPUT deleted.ID,'Remove orphaned links to missing sDemandPart','sStock'
INTO @AuditHistoryPending
FROM sStock
LEFT JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
WHERE sDemandPart.ID IS NULL AND sStock.sDemandPart_ID > 0

/* Fix Menu &s */
UPDATE uRALMenu
SET NodeText = REPLACE(NodeText, ' & ', ' && ')
OUTPUT deleted.ID,'Fixed Menu &s ','uRALMenu'
INTO @AuditHistoryPending   
FROM uRALMenu
WHERE NodeText LIKE '% & %'

/* Fix Cancelled Demands with WIP or COS transaction (Zero Value Only) */
UPDATE sDemandPart
SET aTransaction_IDWIP = 0, aTransaction_IDCOS = 0
OUTPUT deleted.ID,'Cancelled Demands with WIP or COS ','sDemandPart'
INTO @AuditHistoryPending  
FROM sDemandPart
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID
WHERE(sDemandItemStatus.Issued = 0
      AND sDemandItemStatus.Credit = 0)
     AND (aTransaction_IDWIP + aTransaction_IDCOS > 0)
     AND (AmountBaseWIP + AmountBaseCOS = 0);

INSERT INTO sup.AuditHistory(BaseTable,BaseTableID,Fix)
SELECT BaseTable,BaseTableID,Fix FROM @AuditHistoryPending

COMMIT

SELECT * FROM @AuditHistoryPending


GO