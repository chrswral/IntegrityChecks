USE [ENVGAE]
GO

/****** Object:  View [Support].[GeneralIntegrityChecks]    Script Date: 7/30/2018 11:15:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [Support].[GeneralIntegrityChecks]

AS

SELECT TOP 100 PERCENT * FROM 

(

SELECT '2' Priority, 'Stock Records without Ownership' AS Description, ISNULL(COUNT(sStock.ID),0) AS ErrorCount, 'SELECT sStock.ID, (SELECT TOP 1 sStockOwnership_ID FROM sOrderPartReceipt WHERE ID = sStock.sOrderPartReceipt_ID ) AS ReceiptOwnership FROM sStock LEFT JOIN sStockOwnership ON sStock.sStockOwnership_ID = sStockOwnership.ID WHERE sStockOwnership.ID IS NULL' Query
FROM sStock 
LEFT JOIN sStockOwnership ON sStock.sStockOwnership_ID = sStockOwnership.ID
WHERE sStockOwnership.ID IS NULL

UNION

SELECT '2', 'Stock Records without Location', ISNULL(COUNT(sStock.ID), 0), 'SELECT sStock.ID, 
																			ISNULL(
																				(SELECT TOP 1 sBaseWarehouseLocation_ID FROM sStockLog WHERE BaseTableID = sStock.ID  AND sBaseWarehouseLocation_ID > 0 ORDER BY ID DESC) , 
																				(SELECT TOP 1 sBaseWarehouseLocation_ID FROM sOrderPartReceipt WHERE ID = sStock.sOrderPartReceipt_ID ORDER BY ID DESC))
																			FROM sStock 
																			LEFT JOIN sBaseWarehouseLocation ON sStock.sBaseWarehouseLocation_ID = sBaseWarehouseLocation.ID 
																			WHERE sBaseWarehouseLocation.ID IS NULL'
FROM sStock 
LEFT JOIN sBaseWarehouseLocation ON sStock.sBaseWarehouseLocation_ID = sBaseWarehouseLocation.ID
WHERE sBaseWarehouseLocation.ID IS NULL

UNION

SELECT '3', 'Cancelled Demands with WIP or COS', ISNULL(COUNT(sDemandPart.ID),0), 'SELECT sDemandPart.Qty, sDemandItemStatus.Status, sPartTransactionType.TransactionType, AmountBaseWIP, aTransaction_IDWIP, AmountBaseCOS, aTransaction_IDCOS FROM sDemandPart JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID WHERE (sDemandItemStatus.Issued = 0 AND sDemandItemStatus.Credit = 0) AND (aTransaction_IDWIP + aTransaction_IDCOS > 0) AND (AmountBaseWIP + AmountBaseCOS > 0)'
FROM sDemandPart
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID
WHERE (sDemandItemStatus.Issued = 0 AND sDemandItemStatus.Credit = 0) AND (aTransaction_IDWIP + aTransaction_IDCOS > 0) AND (AmountBaseWIP + AmountBaseCOS > 0)

UNION

SELECT '3', 'Demands with WIP or COS created after the WIP or COS Journal', ISNULL(COUNT(sDemandPart.ID),0), 'SELECT sDemandPart.ID, sDemandPart.RecordTimeStampCreated , AmountBaseWIP, aT_WIP.RecordTimeStampCreated, AmountBaseCOS, aT_COS.RecordTimeStampCreated, sDemandItemStatus.Status FROM sDemandPart JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID JOIN aTransaction aT_WIP ON aT_WIP.ID = sDemandPart.aTransaction_IDWIP JOIN aTransaction aT_COS ON aT_COS.ID = sDemandPart.aTransaction_IDCOS WHERE sDemandPart.RecordTimeStampCreated > aT_WIP.RecordTimeStampCreated OR sDemandPart.RecordTimeStampCreated > aT_COS.RecordTimeStampCreated '
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

SELECT '3', 'Demand Parts not equal WIP PE', ISNULL(COUNT(JournalNo),0), 'SELECT JournalNo, SUM(Qty * (AmountBaseWIP+AmountBaseTransferCost)) sDemandPart_AmountBase, aT.AmountBase, aT.ID FROM sDemandPart sDP JOIN aTransaction aT ON aT.ID = aTransaction_IDWIP JOIN aJournalLine aJL ON aJL.ID = aJournalLine_ID JOIN aJournal aJ ON aJ.ID = aJournal_ID WHERE aT.AmountBase > 0 GROUP BY aTransaction_IDWIP, aT.AmountBase, JournalNo, aT.ID HAVING SUM(Qty * (AmountBaseWIP+AmountBaseTransferCost)) <> aT.AmountBase' 
FROM (
SELECT JournalNo
FROM sDemandPart 
JOIN aTransaction ON aTransaction.ID = aTransaction_IDWIP
JOIN aJournalLine ON aJournalLine.ID = aJournalLine_ID
JOIN aJournal ON aJournal.ID = aJournalLine.aJournal_ID
WHERE aTransaction.AmountBase > 0
GROUP BY aTransaction_IDWIP, aTransaction.AmountBase, JournalNo, aTransaction.ID
HAVING SUM(Qty * (AmountBaseWIP+AmountBaseTransferCost)) <> aTransaction.AmountBase)ds

UNION

SELECT '2', 'Stock linked to missing Demand Part records', ISNULL(COUNT(sStock.ID),0),'SELECT sStock.ID, sDemandPart_ID FROM sStock LEFT JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID WHERE sDemandPart.ID IS NULL AND sStock.sDemandPart_ID > 0'
FROM sStock
LEFT JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
WHERE sDemandPart.ID IS NULL AND sStock.sDemandPart_ID > 0


UNION

SELECT '2', 'Stock linked to Issued Demand Part records', ISNULL(COUNT(sStock.ID),0),'SELECT sStock.ID, sDemandPart_ID FROM sStock JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID WHERE sDemandItemStatus.Issued = 1 '
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
WHERE sDemandItemStatus.Issued = 1 

UNION

SELECT '2', 'Stock linked to Completed Demand Part records', ISNULL(COUNT(sStock.ID),0),'SELECT sStock.ID, sDemandPart_ID FROM sStock JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID WHERE sDemandItemStatus.Completed = 1 AND sPartTransactionType.Replenishment = 1 '
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID
WHERE sDemandItemStatus.Completed = 1 AND sPartTransactionType.Replenishment = 1

) ds 
WHERE ds.ErrorCount > 0 
ORDER BY Priority

GO

EXEC sys.sp_addextendedproperty @name=N'HelpText', @value=N'Returns general integrity errors' , @level0type=N'SCHEMA',@level0name=N'Support', @level1type=N'VIEW',@level1name=N'GeneralIntegrityChecks'
GO


