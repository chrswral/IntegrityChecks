SET XACT_ABORT ON 

BEGIN TRAN

/*Remove orphaned links to missing sDemandPart */

DECLARE @AuditHistoryPending TABLE (
    BaseTableID INT NOT NULL,
    Fix VARCHAR(50) NOT NULL,
    BaseTable VARCHAR(50)
)


UPDATE sStock
SET sStockOwnership_ID = sOrderPartReceipt.sStockOwnership_ID
OUTPUT deleted.ID,'Missing Stock Ownership','sStock' 
INTO @AuditHistoryPending
FROM sStock 
JOIN sOrderPartReceipt ON sOrderPartReceipt.ID = sStock.sOrderPartReceipt_ID
WHERE sStock.sStockOwnership_ID = 0

INSERT INTO sup.AuditHistory(BaseTable,BaseTableID,Fix)
SELECT BaseTable,BaseTableID,Fix FROM @AuditHistoryPending

SELECT * FROM @AuditHistoryPending
SELECT * FROM sup.AuditHistory



ROLLBACK

