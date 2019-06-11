IF EXISTS
(
SELECT *
FROM sys.views
WHERE name = 'StockIntegrityChecks'
)
DROP VIEW sup.StockIntegrityChecks;

GO

CREATE VIEW [sup].[StockIntegrityCheck]

AS

SELECT T.sOrderPartReceipt_ID,
       PartNo,
       ReceiptNo,
       ReceiptDate,
       SerialNo,
       ReceiptQty,
       StockQty,
       IssueQty,
	   DespatchQty, 
	   WriteOffQty,
       ReceiptQty - StockQty - IssueQty - DespatchQty - WriteOffQty AS Discrepancy
FROM
(
SELECT sOrderPartReceipt.ID AS sOrderPartReceipt_ID,
       sPart.PartNo,
       sOrderReceiptNo.ReceiptNo,
       sOrderReceiptNo.ReceiptDate,
       sOrderPartReceipt.SerialNo,
       sOrderPartReceipt.Qty AS ReceiptQty,
       ISNULL(
             (
             SELECT SUM(Qty)
             FROM dbo.sStock
             WHERE(sOrderPartReceipt_ID = dbo.sOrderPartReceipt.ID)
             ), 0) AS StockQty,
 
       ISNULL(
             (
             SELECT SUM(IIF(sPartTransactionType_ID = 0, -1, 1)*Qty)
             FROM dbo.sPartIssue
             WHERE(sOrderPartReceipt_ID = sOrderPartReceipt.ID)
             ), 0) AS IssueQty,
       ISNULL(
             (
             SELECT SUM(Qty)
             FROM dbo.sPartDespatch
             WHERE(sOrderPartReceipt_ID = sOrderPartReceipt.ID)
             ), 0) AS DespatchQty,
       ISNULL(
             (
             SELECT SUM(Qty)
             FROM dbo.sPartWriteOff
             WHERE(sOrderPartReceipt_ID = sOrderPartReceipt.ID)
             ), 0) AS WriteOffQty			 
FROM dbo.sOrderPartReceipt
INNER JOIN sOrderReceiptNo ON sOrderPartReceipt.sOrderReceiptNo_ID = sOrderReceiptNo.ID
INNER JOIN sPart ON sOrderPartReceipt.sPart_ID = sPart.ID
INNER JOIN sPartClassification ON sPart.sPartClassification_ID = sPartClassification.ID
INNER JOIN sOrderReceiptRange ON sOrderReceiptRange.ID = sOrderReceiptNo.sOrderReceiptRange_ID
WHERE sOrderPartReceiptStatus_ID IN
(
      SELECT ID
      FROM sOrderPartReceiptStatus
      WHERE Inspection = 0
)
      AND sPartClassification.Tool = 0
   
) AS T(sOrderPartReceipt_ID, PartNo, ReceiptNo, ReceiptDate, SerialNo, ReceiptQty, StockQty, IssueQty, DespatchQty, WriteOffQty)
WHERE ReceiptQty - StockQty - IssueQty - DespatchQty - WriteOffQty <> 0;
GO


