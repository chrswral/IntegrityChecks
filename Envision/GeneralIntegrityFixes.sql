SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE sup.GeneralIntegrityFixes
    @Commit int = 0
AS 

SET XACT_ABORT ON 

SET NOCOUNT ON

/* Create Pending Table */
DECLARE @AuditHistoryPending TABLE (
    BaseTableID INT NOT NULL,
    Fix VARCHAR(50) NOT NULL,
    BaseTable VARCHAR(50)
)

BEGIN TRANSACTION SIFixes

/* Delete Stock records without valid receipts */
DELETE sStock
OUTPUT deleted.ID,'Deleted: Missing Receipt','sStock'
INTO @AuditHistoryPending   
FROM sStock
LEFT JOIN sOrderPartReceipt ON sStock.sOrderPartReceipt_ID = sOrderPartReceipt.ID
WHERE sOrderPartReceipt.ID IS NULL

PRINT 'Deleted: Missing Receipt: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

/*Remove orphaned links to missing Stock Ownership */
UPDATE sStock
SET sStockOwnership_ID = sOrderPartReceipt.sStockOwnership_ID
OUTPUT deleted.ID,'Missing Stock Ownership','sStock' 
INTO @AuditHistoryPending
FROM sStock 
JOIN sOrderPartReceipt ON sOrderPartReceipt.ID = sStock.sOrderPartReceipt_ID
WHERE sStock.sStockOwnership_ID = 0

PRINT 'Missing Stock Ownership: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

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

PRINT 'Missing Location: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'


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

PRINT 'Remove FK to completed sDemandPart: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

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

PRINT 'Remove FK to Issued sDemandPart: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

/*Remove FK to planned sDemandPart */
UPDATE sStock
SET sDemandPart_ID = 0
OUTPUT deleted.ID,'Remove FK to planned sDemandPart','sStock'
INTO @AuditHistoryPending
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID
WHERE sDemandItemStatus.Planned = 1 

PRINT 'Remove FK to planned sDemandPart: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

/*Remove FK to Cancelled sDemandPart */
UPDATE sStock
SET sDemandPart_ID = 0
OUTPUT deleted.ID,'Remove FK to cancelled sDemandPart','sStock'
INTO @AuditHistoryPending
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
WHERE sDemandItemStatus.Cancelled = 1 

PRINT 'Remove FK to cancelled sDemandPart: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

/*Remove orphaned links to missing sDemandPart */
UPDATE sStock
SET sDemandPart_ID = 0
OUTPUT deleted.ID,'Remove orphaned links to missing sDemandPart','sStock'
INTO @AuditHistoryPending
FROM sStock
LEFT JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
WHERE sDemandPart.ID IS NULL AND sStock.sDemandPart_ID > 0

PRINT 'Remove orphaned links to missing sDemandPart: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

/* Fix Menu &s */
UPDATE uRALMenu
SET NodeText = REPLACE(NodeText, ' & ', ' && ')
OUTPUT deleted.ID,'Fixed Menu &s ','uRALMenu'
INTO @AuditHistoryPending   
FROM uRALMenu
WHERE NodeText LIKE '% & %'

PRINT 'Fixed Menu: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

/* Fix Cancelled Demands with WIP or COS transaction (Zero Value Only) */
UPDATE sDemandPart
SET aTransaction_IDWIP = 0, aTransaction_IDCOS = 0
OUTPUT deleted.ID,'Cancelled Demands with WIP or COS ','sDemandPart'
INTO @AuditHistoryPending  
FROM sDemandPart
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID
WHERE(sDemandItemStatus.Issued = 0
     AND sDemandItemStatus.Credit = 0
     AND sDemandItemStatus.Transferred = 0)
     AND (aTransaction_IDWIP + aTransaction_IDCOS > 0)
     AND (AmountBaseWIP + AmountBaseCOS = 0)

PRINT 'Cancelled Demands with WIP or COS: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

/* Fix Stock Repair requisitions without status */
UPDATE sDemandPart
SET sDemandItemStatus_ID = (SELECT TOP 1 ID FROM sDemandItemStatus WHERE Completed=1)
OUTPUT deleted.ID,'Missing Status for Stock Repairs ','sDemandPart'
INTO @AuditHistoryPending  
FROM sDemandPart
JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID
JOIN sOrderPartSchedule ON sOrderPartSchedule.ID = sOrderPartSchedule_ID
JOIN sOrderPart ON sOrderPart.ID = sOrderPartSchedule.sOrderPart_ID
JOIN sDemand ON sDemand.ID = sDemand_ID
JOIN sOrderPartReceipt ON sOrderPartReceipt.sOrderPartSchedule_ID = sOrderPartSchedule.ID
JOIN sBaseWarehouseLocation ON sBaseWarehouseLocation.ID = sOrderPartReceipt.sBaseWarehouseLocation_ID
JOIN sBaseWarehouse ON sBaseWarehouse.ID = sBaseWarehouseLocation.sBaseWarehouse_ID
WHERE sDemandItemStatus_ID = 0
AND sPartTransactionType.StockRepair = 1
AND sOrderPart.ReceivedQty = sOrderPart.OrderQty
AND sBaseWarehouse.uRALBase_ID = sDemandPart.uRALBase_ID



/* Remove duplicate barcodes*/
UPDATE sStock 
SET BarCode = ''
OUTPUT deleted.ID, 'Duplicate Barcodes', 'sStock'
INTO @AuditHistoryPending
FROM sStock
JOIN (SELECT MIN(ID) ID, BarCode
    FROM sStock 
    GROUP BY BarCode
    HAVING COUNT(*) >1) bc ON bc.BarCode = sStock.BarCode
WHERE bc.ID <> sStock.ID

PRINT 'Duplicate Barcodes: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'

/* Fix missing barcodes*/

    DECLARE @Updated table (ID int, BarCode varchar(10))
    DECLARE @BarcodeDigits int = (SELECT TOP 1 CAST(ConfigValue AS int) FROM sStockConfig WHERE ConfigName = 'BarcodeDigits')
    DECLARE @LastBarcode int = (SELECT TOP 1 CAST(ConfigValue AS int) FROM sStockConfig  WHERE ConfigName = 'LastBarcode')

    /* Lock the stock config record */
    UPDATE sStockConfig
    SET RecordLocked = 1
    FROM sStockConfig
    WHERE ConfigName = 'LastBarcode'

    /* Insert missing barcode */
    UPDATE sStock
    SET BarCode = ds.BarCode 
    OUTPUT inserted.ID, inserted.BarCode
    INTO @Updated
    FROM sStock
    JOIN (
	   SELECT sStock.ID, RIGHT(REPLICATE('0',@BarcodeDigits) + CAST(@LastBarcode+ROW_NUMBER() OVER (ORDER BY sStock.ID) AS varchar(10)),@BarcodeDigits) AS BarCode
	   FROM sStock
	   WHERE BarCode = '') ds ON ds.ID = sStock.ID 

		/* Update last barcode and unlock*/
		UPDATE sStockConfig
		SET ConfigValue = ISNULL((SELECT MAX(BarCode) FROM @Updated), ConfigValue), RecordLocked = 0
		FROM sStockConfig
		WHERE ConfigName = 'LastBarcode'

    /*Insert into Audit Table */
    INSERT INTO @AuditHistoryPending
    SELECT ID, 'Missing Barcodes', 'sStock'
    FROM @Updated

	PRINT 'Missing Barcodes: ' + CAST(@@ROWCOUNT AS varchar(10))+' rows affected'


INSERT INTO sup.AuditHistory(BaseTable,BaseTableID,Fix)
SELECT BaseTable,BaseTableID,Fix FROM @AuditHistoryPending

IF @Commit = 1
BEGIN
    COMMIT TRANSACTION SIFixes
    SELECT '** COMMITTED **' AS Status
    SELECT * FROM @AuditHistoryPending
END
ELSE
BEGIN
    SELECT '** ROLLING BACK **' AS Status
    SELECT * FROM @AuditHistoryPending
    SELECT * FROM sup.GeneralIntegrityChecks
    ROLLBACK TRANSACTION SIFixes

END
GO



DECLARE @HelpText VARCHAR(100)= N'Integrity Fixes Created '+CAST(GETDATE() AS VARCHAR(30));
EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = @HelpText,
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'PROCEDURE',
     @level1name = N'GeneralIntegrityFixes';