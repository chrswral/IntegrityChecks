/* CREATE SCHEMA Support */

IF EXISTS(SELECT * FROM sys.views WHERE Name = 'GeneralIntegrityChecks')
DROP VIEW Support.GeneralIntegrityChecks

GO

CREATE VIEW Support.GeneralIntegrityChecks

AS

SELECT '' Priority, 'Stock Records without Ownership' AS Description, ISNULL(COUNT(sStock.ID),0) AS ErrorCount, 'SELECT sStock.ID, (SELECT TOP 1 sStockOwnership_ID FROM sOrderPartReceipt WHERE ID = sStock.sOrderPartReceipt_ID ) AS ReceiptOwnership FROM sStock LEFT JOIN sStockOwnership ON sStock.sStockOwnership_ID = sStockOwnership.ID WHERE sStockOwnership.ID IS NULL' Query
FROM sStock 
LEFT JOIN sStockOwnership ON sStock.sStockOwnership_ID = sStockOwnership.ID
WHERE sStockOwnership.ID IS NULL

UNION

SELECT '', 'Stock Records without Location', ISNULL(COUNT(sStock.ID), 0), 'SELECT sStock.ID, (SELECT TOP 1 sBaseWarehouseLocation_ID FROM sStockLog WHERE BaseTableID = sStock.ID  AND sBaseWarehouseLocation_ID > 0 ORDER BY ID DESC) FROM sStock LEFT JOIN sBaseWarehouseLocation ON sStock.sBaseWarehouseLocation_ID = sBaseWarehouseLocation.ID WHERE sBaseWarehouseLocation.ID IS NULL'
FROM sStock 
LEFT JOIN sBaseWarehouseLocation ON sStock.sBaseWarehouseLocation_ID = sBaseWarehouseLocation.ID
WHERE sBaseWarehouseLocation.ID IS NULL

UNION

SELECT '', 'Cancelled Demands with WIP or COS', ISNULL(COUNT(sDemandPart.ID),0), 'SELECT sDemandPart.Qty, sDemandItemStatus.Status, sPartTransactionType.TransactionType, AmountBaseWIP, aTransaction_IDWIP, AmountBaseCOS, aTransaction_IDCOS FROM sDemandPart JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID WHERE (sDemandItemStatus.Issued = 0 AND sDemandItemStatus.Credit = 0) AND (aTransaction_IDWIP + aTransaction_IDCOS > 0) AND (AmountBaseWIP + AmountBaseCOS > 0)'
FROM sDemandPart
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID
WHERE (sDemandItemStatus.Issued = 0 AND sDemandItemStatus.Credit = 0) AND (aTransaction_IDWIP + aTransaction_IDCOS > 0) AND (AmountBaseWIP + AmountBaseCOS > 0)

UNION

SELECT '', 'Demands with WIP or COS created after the WIP or COS Journal', ISNULL(COUNT(sDemandPart.ID),0), 'SELECT sDemandPart.ID, sDemandPart.RecordTimeStampCreated , AmountBaseWIP, aT_WIP.RecordTimeStampCreated, AmountBaseCOS, aT_COS.RecordTimeStampCreated, sDemandItemStatus.Status FROM sDemandPart JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID JOIN aTransaction aT_WIP ON aT_WIP.ID = sDemandPart.aTransaction_IDWIP JOIN aTransaction aT_COS ON aT_COS.ID = sDemandPart.aTransaction_IDCOS WHERE sDemandPart.RecordTimeStampCreated > aT_WIP.RecordTimeStampCreated OR sDemandPart.RecordTimeStampCreated > aT_COS.RecordTimeStampCreated '
FROM sDemandPart
JOIN aTransaction aT_WIP ON aT_WIP.ID = sDemandPart.aTransaction_IDWIP
JOIN aTransaction aT_COS ON aT_COS.ID = sDemandPart.aTransaction_IDCOS
WHERE sDemandPart.RecordTimeStampCreated > aT_WIP.RecordTimeStampCreated OR sDemandPart.RecordTimeStampCreated > aT_COS.RecordTimeStampCreated 

--UNION

--SELECT '', 'PIs Matched to Stock but coded to non stock account', ISNULL(COUNT(sOrderPartReceiptTransaction.ID),0), 'SELECT sOPT.RecordTimeStampCreated, JournalNo, aA.Account, aA.Name, * FROM sOrderPartReceiptTransaction sOPT JOIN aTransaction aT ON aT.ID = sOPT.aTransaction_ID JOIN aJournalLine aJL ON aJL.ID = aJournalLine_ID JOIN aJournal aJ ON aJ.ID = aJournal_ID JOIN aAccount aA ON aT.aAccount_ID = aA.ID WHERE sOPT.RecordTimeStampCreated > ''01Jan2017'' AND sOPT.AllocateCostToStock = 1 AND aA.StockCode = 0 AND aA.RepairCode = 0 AND aT.aAccount_ID NOT IN (SELECT aAccount_IDCOS FROM aCompany UNION SELECT aAccount_IDStockWIP FROM aCompany UNION SELECT DISTINCT aAccount_IDCostPart FROM sOrder UNION SELECT aAccount_IDDespatch FROM aCompany)'
--FROM sOrderPartReceiptTransaction
--JOIN aTransaction ON aTransaction.ID = sOrderPartReceiptTransaction.aTransaction_ID
--JOIN aAccount ON aTransaction.aAccount_ID = aAccount.ID
--WHERE 
--sOrderPartReceiptTransaction.RecordTimeStampCreated > '01Jan2017'
--AND sOrderPartReceiptTransaction.AllocateCostToStock = 1 
--AND aAccount.StockCode = 0 AND aAccount.RepairCode = 0
--AND aTransaction.aAccount_ID NOT IN (SELECT aAccount_IDCOS FROM aCompany UNION SELECT aAccount_IDStockWIP FROM aCompany UNION SELECT DISTINCT
--aAccount_IDCostPart FROM sOrder UNION SELECT aAccount_IDDespatch FROM aCompany)

UNION

SELECT '', 'Demand Parts not equal WIP PE', ISNULL(COUNT(JournalNo),0), 'SELECT JournalNo, SUM(Qty * (AmountBaseWIP+AmountBaseTransferCost)) sDemandPart_AmountBase, aT.AmountBase, aT.ID FROM sDemandPart sDP JOIN aTransaction aT ON aT.ID = aTransaction_IDWIP JOIN aJournalLine aJL ON aJL.ID = aJournalLine_ID JOIN aJournal aJ ON aJ.ID = aJournal_ID WHERE aT.AmountBase > 0 GROUP BY aTransaction_IDWIP, aT.AmountBase, JournalNo, aT.ID HAVING SUM(Qty * (AmountBaseWIP+AmountBaseTransferCost)) <> aT.AmountBase' 
FROM (
SELECT JournalNo
FROM sDemandPart 
JOIN aTransaction ON aTransaction.ID = aTransaction_IDWIP
JOIN aJournalLine ON aJournalLine.ID = aJournalLine_ID
JOIN aJournal ON aJournal.ID = aJournalLine.aJournal_ID
WHERE aTransaction.AmountBase > 0
GROUP BY aTransaction_IDWIP, aTransaction.AmountBase, JournalNo, aTransaction.ID
HAVING SUM(Qty * (AmountBaseWIP+AmountBaseTransferCost)) <> aTransaction.AmountBase)ds

GO
EXEC sys.sp_addextendedproperty @name=N'HelpText', @value=N'Returns general integrity errors' , @level0type=N'SCHEMA',@level0name=N'Support', @level1type=N'VIEW',@level1name=N'GeneralIntegrityChecks'

GO



IF EXISTS(SELECT * FROM sys.views WHERE Name = 'StockIntegrityCheck')
DROP VIEW Support.StockIntegrityCheck

GO

CREATE VIEW [Support].[StockIntegrityCheck]

AS

SELECT T.sOrderPartReceipt_ID,
PartNo, 
 ReceiptNo,
ReceiptDate, 
(SELECT  MAX(sDemandPart.IssueDate)
FROM sDemandPart
WHERE sDemandPart.sOrderPartReceipt_ID = T.sOrderPartReceipt_ID ) AS 'Issue Date' ,
SerialNo, 
 ReceiptQty,
StockQty, 
 IssueQty, 
 ReceiptQty-StockQty-IssueQty AS Discrepancy, 
 'Stock Issue '= 
 CASE    
 WHEN ReceiptQty > StockQty + IssueQty THEN 'Missing Stock'   
 WHEN ReceiptQty < StockQty + IssueQty THEN 'Surplus Stock'   
 ELSE 'Stock Integrity Error Further Investigation'   
 END ,  
 'Cause Of Issue' = 
 CASE     
 WHEN (SELECT Count(sOrderPartReceipt_ID) FROM sStockLog WHERE sStockLog.sOrderPartReceipt_ID                =T.sOrderPartReceipt_ID  ) <= 0 THEN 'Reciept Error'  
 WHEN (SELECT MAX(sDemandPart.IssueDate)  FROM sDemandPart WHERE sDemandPart.sOrderPartReceipt_ID = T.sOrderPartReceipt_ID) IS NULL THEN  'Allocation Error'   
 WHEN (SELECT Count(sOrderPartReceipt_ID) FROM sStockLog WHERE sStockLog.sOrderPartReceipt_ID                =T.sOrderPartReceipt_ID  ) >0   THEN 'Issue Error'  
 ELSE 'Further Investigation is required'    END   
 FROM (
SELECT sOrderPartReceipt.ID AS sOrderPartReceipt_ID,
sPart.PartNo,
sOrderReceiptNo.ReceiptNo,
sOrderReceiptNo.ReceiptDate,
sOrderPartReceipt.SerialNo
,sOrderPartReceipt.Qty AS ReceiptQty,
ISNULL((SELECT SUM(Qty) FROM dbo.sStock WHERE (sOrderPartReceipt_ID = dbo.sOrderPartReceipt.ID)), 0) AS StockQty,
ISNULL((SELECT SUM(Qty) FROM dbo.sDemandPart WHERE (sOrderPartReceipt_ID = dbo.sOrderPartReceipt.ID) AND ((sDemand_ID = - 2) 
 OR(sDemandItemStatus_ID IN(SELECT ID FROM dbo.sDemandItemStatus WHERE ((Issued = 1) OR (Credit = 1)))) )), 0) AS IssueQty
FROM dbo.sOrderPartReceipt
INNER JOIN sOrderReceiptNo ON sOrderPartReceipt.sOrderReceiptNo_ID = sOrderReceiptNo.ID
INNER JOIN sPart ON sOrderPartReceipt.sPart_ID = sPart.ID
INNER JOIN sPartClassification ON sPart.sPartClassification_ID = sPartClassification.ID
INNER JOIN sOrderReceiptRange ON sOrderReceiptRange.ID = sOrderReceiptNo.sOrderReceiptRange_ID
WHERE sOrderPartReceiptStatus_ID IN (SELECT ID FROM sOrderPartReceiptStatus WHERE Inspection =0)
AND sPartClassification.Tool = 0 
AND sOrderReceiptRange.aCompany_ID = IIF((SELECT COUNT(ID) FROM aCompany WHERE Code = 'WAS') > 0, 2, sOrderReceiptRange.aCompany_ID) --Limit to WAS company in WAS

) AS T
(sOrderPartReceipt_ID,PartNo, ReceiptNo, ReceiptDate, SerialNo, ReceiptQty, StockQty, IssueQty)
WHERE ReceiptQty <> StockQty + IssueQty  
 


GO

EXEC sys.sp_addextendedproperty @name=N'HelpText', @value=N'Returns Stock Integrity Errors' , @level0type=N'SCHEMA',@level0name=N'Support', @level1type=N'VIEW',@level1name=N'StockIntegrityCheck'
GO



IF EXISTS(SELECT * FROM sys.procedures WHERE Name = 'sp_ReceiptsNotInStock')
DROP PROCEDURE  Support.sp_ReceiptsNotInStock

GO

CREATE PROC [Support].[sp_ReceiptsNotInStock] @ReceiptNo varchar(30)
AS 
BEGIN

SELECT sOrderPartReceipt.RecordTimeStampCreated 'Receipt Created'
, sOrderPartReceipt.ID 'Receipt ID'
, ReceiptNo
, ISNULL(sStock.Qty, 0) 'Stock Qty'
, sOrderPartReceipt.Qty 'Receipt Qty'
, sOrderPartReceipt.SerialNo
, sOrder.OrderNo
, sOrderTask.TaskNo
, DemandNo
, sDemandPart.DemandItem + '/' + sDemandPart.DemandItemSequence 'Item/Sequence'
, Status 'Demand Item Status'
, sDemandPart.RecordTimeStamp 'DemandPart Time Stamp'
, CASE WHEN sDemandItemStatus.Issued = 1 THEN 'Stock Issued' 
                   WHEN (sStockLog.ID IS NULL AND sStock.ID IS NULL)  
                   THEN 'Integrity error'
                   WHEN sStock.ID > 0 THEN 'No issue found'
                   ELSE ''
END AS Problem,
CASE WHEN sStock.ID > 0 THEN 'Yes'
                   ELSE 'No'
END AS 'In Stock',
sOrderReceiptRange.aCompany_ID
FROM sOrderPartReceipt
                LEFT JOIN sStockLog ON sStockLog.sOrderPartReceipt_ID = sOrderPartReceipt.ID 
                LEFT JOIN sStock ON sStock.sOrderPartReceipt_ID = sOrderPartReceipt.ID
                LEFT JOIN sDemandPart ON sDemandPart.ID = sStockLog.sDemandPart_ID
                LEFT JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID
                LEFT JOIN sDemand ON sDemand.ID = sDemand_ID
                LEFT JOIN sOrderTask ON sOrderTask.ID = sOrderTask_ID
                LEFT JOIN sOrder ON sOrder.ID = sOrder_ID
                JOIN sOrderReceiptNo ON sOrderReceiptNo.ID = sOrderReceiptNo_ID
                JOIN sOrderReceiptRange ON sOrderReceiptRange.ID = sOrderReceiptNo.sOrderReceiptRange_ID
WHERE ReceiptNo = @ReceiptNo
ORDER BY sStockLog.ID
END

GO

EXEC sys.sp_addextendedproperty @name=N'HelpText', @value=N'Shows Receipts not in stock' , @level0type=N'SCHEMA',@level0name=N'Support', @level1type=N'PROCEDURE',@level1name=N'sp_ReceiptsNotInStock'

GO



IF EXISTS(SELECT * FROM sys.procedures WHERE Name = 'sp_InsertMissingStockRecord')
DROP PROCEDURE Support.sp_InsertMissingStockRecord

GO

CREATE PROCEDURE [Support].[sp_InsertMissingStockRecord](@sOrderPartReceiptID int)
as
BEGIN 

INSERT INTO sStock (sOrderPartReceipt_ID
,sBaseWarehouseLocation_ID
,sPartCondition_ID
,Qty
,BarCode
,GUID
,uRALUser_ID
,uRALUser_IDCreated
,RecordTimeStampCreated
,RecordTimeStamp)

SELECT ID
,sBaseWarehouseLocation_ID
,sPartCondition_ID
,Qty
,BarCode
,NEWID()
,1
,1
,GETDATE()
,GETDATE()
FROM sOrderPartReceipt
WHERE sOrderPartReceipt.ID =  @sOrderPartReceiptID
END

GO

EXEC sys.sp_addextendedproperty @name=N'HelpText', @value=N'Inserts a new stock record based on the receipt ID' , @level0type=N'SCHEMA',@level0name=N'Support', @level1type=N'PROCEDURE',@level1name=N'sp_InsertMissingStockRecord'

GO

IF EXISTS(SELECT * FROM sys.procedures WHERE Name = 'sp_BatchHistory')
DROP PROCEDURE Support.sp_BatchHistory

GO

CREATE PROCEDURE [Support].[sp_BatchHistory]


   @sOrderPartReceiptID AS int

AS

BEGIN

--SET @sOrderPartReceiptID = 321472

--*****************

-- Script to get receipt, demand and stock history.

-- Provide receipt ID above

--*****************

SELECT RecordTimeStamp AS TimeStamp,
      uRALUser_IDCreated AS [User],
      (
       SELECT TOP 1 RALUser
       FROM uRALUser
       WHERE uRALUser.ID = aa.uRALUser_IDCreated) AS [User],
      [Table],
      Qty,
      [Action],
     ID,
      (
       SELECT TOP 1 Message
       FROM uRALEvent
       WHERE aa.uRALUser_IDCreated = uRALEvent.uRALUser_IDCreated
        AND uRALEvent.RecordTimeStampCreated BETWEEN DATEADD(S,-2, aa.RecordTimeStamp) AND DATEADD(S,2, aa.RecordTimeStamp)) AS Event,
      (
       SELECT TOP 1 DatabaseVersion
       FROM uRALDatabaseInfo
       WHERE aa.RecordTimeStamp > uRALDatabaseInfo.RecordTimeStampCreated
       ORDER BY ID DESC) AS dbVersion
FROM (
     SELECT sDemandPart.Version,
           sDemandPart.RecordTimeStamp AS RecordTimeStamp,
           sDemandPart.uRALUser_ID AS uRALUser_IDCreated,
           -- Hack; sorry CW.

           'sDemandPart' AS [Table],
           sDemand.ID AS DemandID,
           sDemandPart.ID AS DemandPartID,
           sDemand.DemandNo AS Demand,
           sDemandPart.DemandItem + '/' + sDemandPart.DemandItemSequence AS ItemSequence,
           sDemandPart.Qty,
           'Demand: ' + DemandNo + '\' + DemandItem + '\' + DemandItemSequence + ' ReceiptID:' + CAST (sDemandPart.sOrderPartReceipt_ID AS varchar) + ' - Status:' + sDemandItemStatus.Description + ' - Trans:' + sPartTransactionType.Description AS [Action],
           sDemandPart.ID
     FROM sDemandPart
         INNER JOIN sDemandItemStatus ON sDemandPart.sDemandItemStatus_ID = sDemandItemStatus.ID
         INNER JOIN sPartTransactionType ON sDemandPart.sPartTransactionType_ID = sPartTransactionType.ID
         INNER JOIN sDemand ON sDemandPart.sDemand_ID = sDemand.ID
     WHERE sOrderPartReceipt_ID = @sOrderPartReceiptID
        OR sDemandPart.ID IN (
          SELECT sDemandPart_ID
          FROM sStockLog
          WHERE sStockLog.sOrderPartReceipt_ID = @sOrderPartReceiptID)
     UNION
     SELECT sDemandPartLog.Version,
           sDemandPartLog.RecordTimeStampCreated AS RecordTimeStamp,
           sDemandPartLog.uRALUser_IDCreated,
           'sDemandPartLog' AS [Table],
           sDemand.ID AS DemandID,
           BaseTableID AS DemandPartID,
           sDemand.DemandNo AS Demand,
           sDemandPartLog.DemandItem + '/' + sDemandPartLog.DemandItemSequence AS ItemSequence,
           sDemandPartLog.Qty,
           'Demand: ' + DemandNo + '\' + DemandItem + '\' + DemandItemSequence + CASE
                                                                   WHEN sDemandPartLog.sOrderPartReceipt_ID > 0 THEN ' ReceiptID:' + CAST (sDemandPartLog.sOrderPartReceipt_ID AS varchar)
                                                                      ELSE ''
                                                                   END + ' - Status:' + sDemandItemStatus.Description + CASE
                                                                                                             WHEN sDemandItemStatus.OnOrder = 0
                                                                                                               OR ISNULL (sOrder.OrderNo, '0') = '0' THEN ''
                                                                                                                ELSE ' ' + sOrder.OrderNo + '\' + CAST (sOrderPart.OrderItem AS varchar)
                                                                                                             END + ' - Trans:' + sPartTransactionType.Description + CASE
                                                                                                                                                         WHEN sDemandPartLog.aTransaction_IDWIP > 0 THEN ' - WIP ID:' + CAST (sDemandPartLog.aTransaction_IDWIP AS varchar)
                                                                                                                                                            ELSE ' '
                                                                                                                                                         END AS [Action],
           sDemandPartLog.ID
     FROM sDemandPartLog
         INNER JOIN sDemandItemStatus ON sDemandPartLog.sDemandItemStatus_ID = sDemandItemStatus.ID
         INNER JOIN sPartTransactionType ON sDemandPartLog.sPartTransactionType_ID = sPartTransactionType.ID
         INNER JOIN sDemand ON sDemandPartLog.sDemand_ID = sDemand.ID
         LEFT JOIN sOrderPart ON sDemandPartLog.sOrderPart_ID = sOrderPart.ID
         LEFT JOIN sOrder ON sOrderPart.sOrder_ID = sOrder.ID
     WHERE sOrderPartReceipt_ID = @sOrderPartReceiptID
        OR sDemandPartLog.BaseTableID IN (
          SELECT sDemandPart_ID
          FROM sStockLog
          WHERE sStockLog.sOrderPartReceipt_ID = @sOrderPartReceiptID)
     UNION
     SELECT sDemandPartEvent.Version,
           sDemandPartEvent.RecordTimeStampCreated AS RecordTimeStamp,
           sDemandPartEvent.uRALUser_IDCreated,
           'sDemandPartEvent' AS [Table],
           sDemand.ID AS DemandID,
           sDemandPartEvent.sDemandPart_ID AS DemandPartID,
           sDemand.DemandNo AS Demand,
           sDemandPart.DemandItem + '/' + sDemandPart.DemandItemSequence AS ItemSequence,
           sDemandPart.Qty,
           'Demand: ' + DemandNo + '\' + DemandItem + '\' + DemandItemSequence + CASE
                                                                   WHEN sDemandPartEvent.sOrderPartReceipt_ID > 0 THEN ' ReceiptID:' + CAST (sDemandPartEvent.sOrderPartReceipt_ID AS varchar)
                                                                      ELSE ''
                                                                   END + ' - Status:' + sDemandItemStatus.Description + CASE
                                                                                                             WHEN sDemandItemStatus.OnOrder = 0
                                                                                                               OR ISNULL (sOrder.OrderNo, '0') = '0' THEN ''
                                                                                                                ELSE ' ' + sOrder.OrderNo + '\' + CAST (sOrderPart.OrderItem AS varchar)
                                                                                                             END + ' - Trans:' + sPartTransactionType.Description + CASE
                                                                                                                                                         WHEN sDemandPartEvent.sDespatchPart_ID > 0 THEN ' - Despatched'
                                                                                                                                                            ELSE ''
                                                                                                                                                         END AS [Action],
           sDemandPartEvent.ID
     FROM sDemandPartEvent
         INNER JOIN sDemandItemStatus ON sDemandPartEvent.sDemandItemStatus_ID = sDemandItemStatus.ID
         LEFT OUTER JOIN sDemandPart ON sDemandPartEvent.sDemandPart_ID = sDemandPart.ID
         INNER JOIN sPartTransactionType ON sDemandPartEvent.sPartTransactionType_ID = sPartTransactionType.ID
         LEFT OUTER JOIN sDemand ON sDemandPart.sDemand_ID = sDemand.ID
         LEFT JOIN sOrderPart ON sDemandPartEvent.sOrderPart_ID = sOrderPart.ID
         LEFT JOIN sOrder ON sOrderPart.sOrder_ID = sOrder.ID
     WHERE sDemandPartEvent.sOrderPartReceipt_ID = @sOrderPartReceiptID
     UNION
     SELECT sStockLog.Version,
           sStockLog.RecordTimeStampCreated AS RecordTimeStamp,
           sStockLog.uRALUser_IDCreated,
           'sStockLog' AS [Table],
           sDemandLog.ID AS DemandID,
           sDemandPartLog.ID AS DemandPartID,
           sDemandLog.DemandNo AS Demand,
           sDemandPartLog.DemandItem + '/' + sDemandPartLog.DemandItemSequence AS ItemSequence,
           sStockLog.Qty,
           'Stock BaseTableID: ' + CAST (sStockLog.BaseTableID AS varchar) + ISNULL(CASE
                                                        WHEN sStockLog.sDemandPart_ID > 0 THEN ' - DemandPart: ' + sDemandLog.DemandNo + '\' + sDemandPartLog.DemandItem + '\' + sDemandPartLog.DemandItemSequence
                                                           ELSE ''
                                                        END,'' ) AS [Action],
           sStockLog.ID
     FROM sStockLog
         LEFT OUTER JOIN sDemandPartLog ON sStockLog.sDemandPart_ID = sDemandPartLog.ID
         LEFT OUTER JOIN sDemandLog ON sDemandPartLog.sDemand_ID = sDemandLog.ID
     WHERE sStockLog.sOrderPartReceipt_ID = @sOrderPartReceiptID
     UNION
     SELECT sOrderPartReceiptLog.Version,
           sOrderPartReceiptLog.RecordTimeStampCreated AS RecordTimeStamp,
           sOrderPartReceiptLog.uRALUser_IDCreated,
           'sOrderPartReceiptLog' AS [Table],
           '',--sOrderPartReceiptLog.sDemandPart_ID AS DemandID,
           '',--sDemandPart.ID AS DemandPartID,
           '',--sDemand.DemandNo AS Demand,
           '',--sDemandPart.DemandItem + '/' + sDemandPart.DemandItemSequence AS ItemSequence,
           sOrderPartReceiptLog.Qty,
           'Receipt: ' + sOrderReceiptNo.ReceiptNo + ' PartNo: ' + sPart.PartNo COLLATE Latin1_General_CI_AS + CASE
                                                                                           WHEN sOrderPartReceiptLog.SerialNo > '' THEN ' SerialNo: ' + sOrderPartReceiptLog.SerialNo
                                                                                              ELSE ''
                                                                                           END + ' Status: ' + sOrderPartReceiptStatus.Description AS [Action],
           sOrderPartReceiptLog.ID
     FROM sOrderPartReceiptLog
         --LEFT OUTER JOIN sDemandPart ON sOrderPartReceiptLog.sDemandPart_ID = sDemandPart.ID
         --LEFT OUTER JOIN sDemand ON sDemandPart.sDemand_ID = sDemand.ID
         LEFT OUTER JOIN sOrderReceiptNo ON sOrderPartReceiptLog.sOrderReceiptNo_ID = sOrderReceiptNo.ID
         LEFT OUTER JOIN sPart ON sOrderPartReceiptLog.sPart_ID = sPart.ID
         LEFT OUTER JOIN sOrderPartReceiptStatus ON sOrderPartReceiptLog.sOrderPartReceiptStatus_ID = sOrderPartReceiptStatus.ID
     WHERE sOrderPartReceiptLog.BaseTableID = @sOrderPartReceiptID
     UNION
     SELECT sOrderPartReceipt.Version,
           sOrderPartReceipt.RecordTimeStampCreated AS RecordTimeStamp,
           sOrderPartReceipt.uRALUser_IDCreated,
           'sOrderPartReceipt' AS [Table],
           '',--sOrderPartReceipt.sDemandPart_ID AS DemandID,
           '',--sDemandPart.ID AS DemandPartID,
           '',--sDemand.DemandNo AS Demand,
           '',--sDemandPart.DemandItem + '/' + sDemandPart.DemandItemSequence AS ItemSequence,
           sOrderPartReceipt.Qty,
           'Receipt: ' + sOrderReceiptNo.ReceiptNo + ' - PartNo: ' + sPart.PartNo COLLATE Latin1_General_CI_AS + CASE
                                                                                            WHEN sOrderPartReceipt.SerialNo > '' THEN ' SerialNo: ' + sOrderPartReceipt.SerialNo
                                                                                                ELSE ''
                                                                                            END AS [Action],
           sOrderPartReceipt.ID
     FROM sOrderPartReceipt
         --LEFT OUTER JOIN sDemandPart ON sOrderPartReceipt.sDemandPart_ID = sDemandPart.ID
         --LEFT OUTER JOIN sDemand ON sDemandPart.sDemand_ID = sDemand.ID
         LEFT OUTER JOIN sOrderReceiptNo ON sOrderPartReceipt.sOrderReceiptNo_ID = sOrderReceiptNo.ID
         LEFT OUTER JOIN sPart ON sOrderPartReceipt.sPart_ID = sPart.ID
     WHERE sOrderPartReceipt.ID = @sOrderPartReceiptID
     UNION
     SELECT sStock.Version,
           sStock.RecordTimeStamp AS RecordTimeStamp,
           sStock.uRALUser_ID AS uRALUser_IDCreated,
           -- Hack; sorry CW

           'sStock' AS [Table],
           sStock.sDemandPart_ID AS DemandID,
           sDemandPart.ID AS DemandPartID,
           sDemand.DemandNo AS Demand,
           sDemandPart.DemandItem + '/' + sDemandPart.DemandItemSequence AS ItemSequence,
           sStock.Qty,
           'IN STOCK' AS [Action],
           sStock.ID
     FROM sStock
         LEFT OUTER JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
         LEFT OUTER JOIN sDemand ON sDemandPart.sDemand_ID = sDemand.ID
     WHERE sStock.sOrderPartReceipt_ID = @sOrderPartReceiptID
     UNION
     SELECT sBaseWarehouseLocationHistory.Version,
           sBaseWarehouseLocationHistory.RecordTimeStampCreated AS RecordTimeStamp,
           sBaseWarehouseLocationHistory.uRALUser_IDCreated,
           'sBaseWarehouseLocationHistory' AS [Table],
           NULL AS DemandID,
           NULL AS DemandPartID,
           NULL AS Demand,
           NULL AS ItemSequence,
           sBaseWarehouseLocationHistory.Qty AS Qty,
           'Location Changed: ' + uRALBaseFrom.RALBase + '\' + sBaseWarehouseFrom.Warehouse + '\' + sBaseWarehouseLocationFrom.Location + ' to ' + uRALBaseTo.RALBase + '\' + sBaseWarehouseTo.Warehouse + '\' + sBaseWarehouseLocationTo.Location AS [Action],
           sBaseWarehouseLocationHistory.ID
     FROM sBaseWarehouseLocationHistory
         LEFT OUTER JOIN sBaseWarehouseLocation AS sBaseWarehouseLocationFrom ON sBaseWarehouseLocationHistory.sBaseWarehouseLocation_IDFrom = sBaseWarehouseLocationFrom.ID
         LEFT OUTER JOIN sBaseWarehouse AS sBaseWarehouseFrom ON sBaseWarehouseLocationFrom.sBaseWarehouse_ID = sBaseWarehouseFrom.ID
         LEFT OUTER JOIN uRALBase AS uRALBaseFrom ON sBaseWarehouseFrom.uRALBase_ID = uRALBaseFrom.ID
         LEFT OUTER JOIN sBaseWarehouseLocation AS sBaseWarehouseLocationTo ON sBaseWarehouseLocationHistory.sBaseWarehouseLocation_IDTo = sBaseWarehouseLocationTo.ID
         LEFT OUTER JOIN sBaseWarehouse AS sBaseWarehouseTo ON sBaseWarehouseLocationTo.sBaseWarehouse_ID = sBaseWarehouseTo.ID
         LEFT OUTER JOIN uRALBase AS uRALBaseTo ON sBaseWarehouseTo.uRALBase_ID = uRALBaseTo.ID
     WHERE sBaseWarehouseLocationHistory.sOrderPartReceipt_ID = @sOrderPartReceiptID
     UNION
     SELECT sDespatchPart.Version,
           sDespatchPart.RecordTimeStampCreated AS RecordTimeStamp,
           sDespatchPart.uRALUser_IDCreated,
           'sDespatchPart' AS [Table],
           sDespatchPart.sDemandPart_ID AS DemandID,
           sDespatchPart.sDemandPart_ID AS DemandPartID,
           sDemand.DemandNo AS Demand,
           sDemandPart.DemandItem + '/' + sDemandPart.DemandItemSequence AS ItemSequence,
           sDemandPart.Qty AS Qty,
           'DESPATCHED' AS [Action],
           sDespatchPart.ID
     FROM sDespatchPart
         LEFT OUTER JOIN sDemandPart ON sDespatchPart.sDemandPart_ID = sDemandPart.ID
         LEFT OUTER JOIN sDemand ON sDemandPart.sDemand_ID = sDemand.ID
     WHERE sDemandPart.sOrderPartReceipt_ID = @sOrderPartReceiptID
     UNION
     SELECT sOrderPartLog.Version,
           sOrderPartLog.RecordTimeStamp,
           sOrderPartLog.uRALUser_IDCreated,
           [Table],
           0 AS DemandID,
           0 AS DemandPartID,
           '' AS Demand,
           '' AS ItemSequence,
           Qty,
           sOrderPartLog.[Action],
           sOrderPartLog.ID
     FROM (
         SELECT sOrderPartLog.Version,
               sOrderPartLog.RecordTimeStampCreated AS RecordTimeStamp,
               sOrderPartLog.uRALUser_IDCreated,
               'sOrderPartLog' AS [Table],
               (
               SELECT SUM (sOrderPartSchedule.Qty)
               FROM sOrderPartSchedule
               WHERE sOrderPartSchedule.sOrderPart_ID = sOrderPartLog.BaseTableID) AS Qty,
               'Order: ' + CAST (OrderNo AS varchar) + '\' + CAST (sOrderPartLog.OrderItem AS varchar) + ' Received: ' + ISNULL (CAST ((
               SELECT SUM (sOrderPartReceipt.Qty)
               FROM sOrderPartReceipt
               WHERE sOrderPartReceipt.RecordTimeStampCreated <= sOrderPartLog.RecordTimeStampCreated + 1
                AND sOrderPartReceipt.sOrderPartSchedule_ID IN (
                    SELECT ID
                    FROM sOrderPartSchedule
                    WHERE sOrderPartSchedule.sOrderPart_ID = sOrderPartLog.BaseTableID)) AS varchar) , 0) + ' Status: ' + ISNULL (sOrderItemStatus.Description, 'Open') + ' Type: ' + ISNULL (sOrderPartType.Description, '') AS [Action],
               sOrderPartLog.ID
         FROM sOrderPartLog
             LEFT OUTER JOIN sOrderItemStatus ON sOrderPartLog.sOrderItemStatus_ID = sOrderItemStatus.ID
             LEFT OUTER JOIN sDemandPartLog ON sDemandPartLog.sOrderPart_ID = sOrderPartLog.BaseTableID
             LEFT OUTER JOIN sOrderPartType ON sOrderPartLog.sOrderPartType_ID = sOrderPartType.ID
             LEFT OUTER JOIN sOrder ON sOrderPartLog.sOrder_ID = sOrder.ID
             LEFT OUTER JOIN sDemand ON sDemandPartLog.sDemand_ID = sDemand.ID
         WHERE sOrderPartLog.BaseTableID IN (
              SELECT sOrderPart_ID
              FROM sOrderPartSchedule
              WHERE sOrderPartSchedule.ID IN (
                   SELECT sOrderPartSchedule_ID
                   FROM sOrderPartReceipt
                   WHERE ID = @sOrderPartReceiptID))) AS sOrderPartLog
     GROUP BY sOrderPartLog.Version,
            sOrderPartLog.RecordTimeStamp,
            sOrderPartLog.uRALUser_IDCreated,
            [Table],
            Qty,
            [Action],
            sOrderPartLog.ID) AS aa
ORDER BY RecordTimeStamp, Version

END
GO

EXEC sys.sp_addextendedproperty @name=N'HelpText', @value=N'Checks through all stores transaction tables and retrurns chronological events.' , @level0type=N'SCHEMA',@level0name=N'Support', @level1type=N'PROCEDURE',@level1name=N'sp_BatchHistory'
GO


IF EXISTS(SELECT * FROM sys.procedures WHERE Name = 'Help')
DROP PROCEDURE [Support].[Help]

GO

CREATE PROCEDURE [Support].[Help]

AS

BEGIN

SELECT 
'SP' AS Type, p.name, ep.value
FROM sys.procedures p
JOIN sys.schemas s ON s.schema_id = p.schema_id
LEFT JOIN sys.extended_properties ep ON ep.major_id = p.object_id
WHERE s.name = 'Support'

UNION 

SELECT 'View', v.name, ep.value
FROM sys.views v
JOIN sys.schemas s ON s.schema_id = v.schema_id
LEFT JOIN sys.extended_properties ep ON ep.major_id = v.object_id
WHERE s.name = 'Support'


END

GO

DECLARE @HelpText VARCHAR (100) = N'Support ToolBox Created ' + CAST(GETDATE()AS varchar(30)) 

EXEC sys.sp_addextendedproperty @name=N'HelpText', @value=@HelpText, @level0type=N'SCHEMA',@level0name=N'Support', @level1type=N'PROCEDURE',@level1name=N'Help'

GO


PRINT 'Support Procedures and Views created.'
PRINT 'Run EXEC Support.Help'

EXEC Support.Help
