
/* CREATE SCHEMA sup */

/*** Create Sup Audit History Table ***/
IF NOT EXISTS (select * from sys.tables t join sys.schemas s on (t.schema_id = s.schema_id) where s.name = 'sup' and t.name = 'AuditHistory') 

CREATE TABLE sup.AuditHistory(
	ID int IDENTITY PRIMARY KEY ,
	TimeStampCreated datetime DEFAULT GETDATE() NOT NULL,
	Fix varchar(50) NOT NULL,
	BaseTable varchar(250) NOT NULL,
	BaseTableID int NOT NULL)


GO
 
/*** General Integrity Checks ***/
IF EXISTS
(
SELECT *
FROM sys.views
WHERE name = 'GeneralIntegrityChecks'
)
DROP VIEW sup.GeneralIntegrityChecks;

GO

CREATE VIEW [sup].[GeneralIntegrityChecks]
AS

SELECT TOP 1000 *
FROM
(

SELECT '2' AS Priority,
       'Stock Records without Location' AS Description,
       ISNULL(COUNT(sStock.ID), 0) AS ErrorCount,
            'SELECT sStock.ID,
                sPart.PartNo,
                sOrderReceiptNo.ReceiptNo,
                ISNULL(
                        (
                        SELECT TOP 1 sBaseWarehouseLocation_ID
                        FROM sStockLog
                        WHERE BaseTableID = sStock.ID
                            AND sBaseWarehouseLocation_ID > 0
                        ORDER BY ID DESC
                        ),
                        (
                        SELECT TOP 1 sBaseWarehouseLocation_ID
                        FROM sOrderPartReceipt
                        WHERE ID = sStock.sOrderPartReceipt_ID
                        ORDER BY ID DESC
                        )) NewLocationID
            FROM sStock
            LEFT JOIN sBaseWarehouseLocation ON sStock.sBaseWarehouseLocation_ID = sBaseWarehouseLocation.ID
            INNER JOIN sOrderPartReceipt ON sStock.sOrderPartReceipt_ID = sOrderPartReceipt.ID
            LEFT JOIN sOrderReceiptNo ON sOrderPartReceipt.sOrderReceiptNo_ID = sOrderReceiptNo.ID
            LEFT JOIN sPart ON sOrderPartReceipt.sPart_ID = sPart.ID
            WHERE sBaseWarehouseLocation.ID IS NULL;' AS Query
FROM sStock
LEFT JOIN sBaseWarehouseLocation ON sStock.sBaseWarehouseLocation_ID = sBaseWarehouseLocation.ID
INNER JOIN sOrderPartReceipt ON sStock.sOrderPartReceipt_ID = sOrderPartReceipt.ID
WHERE sBaseWarehouseLocation.ID IS NULL

UNION

SELECT '2' Priority,
       'Stock Records without Ownership' AS Description,
       ISNULL(COUNT(sStock.ID), 0) AS ErrorCount,
       'SELECT sStock.ID, (SELECT TOP 1 sStockOwnership_ID FROM sOrderPartReceipt WHERE ID = sStock.sOrderPartReceipt_ID ) AS ReceiptOwnership FROM sStock LEFT JOIN sStockOwnership ON sStock.sStockOwnership_ID = sStockOwnership.ID WHERE sStockOwnership.ID IS NULL' Query
FROM sStock
LEFT JOIN sStockOwnership ON sStock.sStockOwnership_ID = sStockOwnership.ID
WHERE sStockOwnership.ID IS NULL

UNION

SELECT '2' Priority,
       'Stock Records without Receipt' AS Description,
       ISNULL(COUNT(sStock.ID), 0) AS ErrorCount,
	       'SELECT sStock.ID, ISNULL((SELECT MAX(BaseTableID) FROM sOrderPartReceiptLog WHERE BaseTableID = sStock.sOrderPartReceipt_ID),0) AS BaseTableID
			FROM sStock
			LEFT JOIN sOrderPartReceipt ON sStock.sOrderPartReceipt_ID = sOrderPartReceipt.ID
			WHERE sOrderPartReceipt.ID IS NULL' Query
FROM sStock
LEFT JOIN sOrderPartReceipt ON sStock.sOrderPartReceipt_ID = sOrderPartReceipt.ID
WHERE sOrderPartReceipt.ID IS NULL


UNION

SELECT '2',
       'Stock linked to missing Demand Part records',
       ISNULL(COUNT(sStock.ID), 0),
       'SELECT sStock.ID, sDemandPart_ID FROM sStock LEFT JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID WHERE sDemandPart.ID IS NULL AND sStock.sDemandPart_ID > 0'
FROM sStock
LEFT JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
WHERE sDemandPart.ID IS NULL
      AND sStock.sDemandPart_ID > 0
UNION
SELECT '2',
       'Stock linked to Issued Demand Part records',
       ISNULL(COUNT(sStock.ID), 0),
       'SELECT sStock.ID, sDemandPart_ID 
        FROM sStock 
        JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID 
        JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID 
        JOIN sPart on sPart_IDDemanded = sPart.ID
        JOIN sPartClassification on sPartClassification.ID = sPart.sPartClassification_ID
        WHERE sDemandItemStatus.Issued = 1 and sPartClassification.Tool <> 1 '
FROM sStock 
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID 
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID 
JOIN sPart on sPart_IDDemanded = sPart.ID
JOIN sPartClassification on sPartClassification.ID = sPart.sPartClassification_ID
WHERE sDemandItemStatus.Issued = 1 and sPartClassification.Tool <> 1
UNION
SELECT '2',
       'Stock linked to Completed Demand Part records',
       ISNULL(COUNT(sStock.ID), 0),
       'SELECT sStock.ID, sDemandPart_ID FROM sStock JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID WHERE sDemandItemStatus.Completed = 1 AND sPartTransactionType.Replenishment = 1 '
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID
WHERE sDemandItemStatus.Completed = 1
      AND sPartTransactionType.Replenishment = 1
UNION
SELECT '2',
       'Stock linked to Cancelled Demand Part records',
       ISNULL(COUNT(sStock.ID), 0),
       'SELECT sStock.ID, sDemandPart_ID FROM sStock JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID WHERE sDemandItemStatus.Cancelled = 1 '
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
WHERE sDemandItemStatus.Cancelled = 1

UNION
SELECT '2',
       'Stock linked to Planned Demand Part records',
       ISNULL(COUNT(sStock.ID), 0),
       'SELECT sStock.ID, sDemandPart_ID FROM sStock JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID WHERE sDemandItemStatus.Planned = 1 '
FROM sStock
JOIN sDemandPart ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
WHERE sDemandItemStatus.Planned = 1


UNION
SELECT '3',
       'Unbalanced Part PE Journals',
       ISNULL(COUNT(ds.JournalNo), 0),
	   'SELECT * FROM (
						SELECT 
						JournalNo,
						(SELECT SUM(AmountBase) FROM aTransaction WHERE aTransaction.Credit = 0 AND aJournalLine_ID = aJournalLine.ID) DebitAmount,
						(SELECT SUM(AmountBase) FROM aTransaction WHERE aTransaction.Credit = 1 AND aJournalLine_ID = aJournalLine.ID) CreditAmount
						FROM aJournal
						JOIN aJournalLine ON aJournalLine.aJournal_ID = aJournal.ID
						JOIN aJournalRange ON aJournalRange.ID = aJournalRange_ID
						JOIN aJournalType ON aJournalType.ID = aJournalType_ID
						WHERE aJournalType.NominalJournal = 1
						AND aJournalRange.ID IN (SELECT aJournalRange_IDPartWIP FROM aCompany UNION SELECT aJournalRange_IDPartCOS FROM aCompany )
						) ds
						WHERE DebitAmount <> CreditAmount
						ORDER BY JournalNo'

FROM (
SELECT 
JournalNo,
(SELECT SUM(AmountBase) FROM aTransaction WHERE aTransaction.Credit = 0 AND aJournalLine_ID = aJournalLine.ID) DebitAmount,
(SELECT SUM(AmountBase) FROM aTransaction WHERE aTransaction.Credit = 1 AND aJournalLine_ID = aJournalLine.ID) CreditAmount
FROM aJournal
JOIN aJournalLine ON aJournalLine.aJournal_ID = aJournal.ID
JOIN aJournalRange ON aJournalRange.ID = aJournalRange_ID
JOIN aJournalType ON aJournalType.ID = aJournalType_ID
WHERE aJournalType.NominalJournal = 1
AND aJournalRange.ID IN (SELECT aJournalRange_IDPartWIP FROM aCompany UNION SELECT aJournalRange_IDPartCOS FROM aCompany )
) ds
WHERE DebitAmount <> CreditAmount


UNION
SELECT '3',
       'Demand Parts not equal WIP PE (WIPSTOCK)',
       ISNULL(COUNT(JournalNo), 0),
       'SELECT JournalNo, aJ.RecordTimeStampCreated,
       SUM(Qty * (AmountBaseWIP)) sDemandPart_AmountBase, 
       AmountBase AmountBase,
	   SUM(Qty * (AmountBaseWIP)) - AmountBase  AS Diff
       , aT.ID 
       FROM sDemandPart sDP 
       JOIN aTransaction aT ON aT.ID = aTransaction_IDWIPSTOCKAccount
       JOIN aJournalLine aJL ON aJL.ID = aJournalLine_ID 
       JOIN aJournal aJ ON aJ.ID = aJL.aJournal_ID 
       JOIN aJournalRange aJR ON aJR.ID = aJ.aJournalRange_ID
       JOIN aJournalType aJT ON aJT.ID = aJR.aJournalType_ID
       WHERE aT.AmountBase > 0 
       AND sDP.AmountBaseWIP > 0
       AND aJT.NominalJournal = 1
       GROUP BY aTransaction_IDWIPSTOCKAccount, aT.AmountBase, JournalNo, aT.ID , aJ.RecordTimeStampCreated, aT.Credit
       HAVING SUM(Qty * (AmountBaseWIP)) <> aT.AmountBase'

FROM (
SELECT JournalNo, aJ.RecordTimeStampCreated,
       SUM(Qty * (AmountBaseWIP)) sDemandPart_AmountBase, 
       AmountBase AmountBase,
	   SUM(Qty * (AmountBaseWIP)) - AmountBase  AS Diff
       , aT.ID 
       FROM sDemandPart sDP 
       JOIN aTransaction aT ON aT.ID = aTransaction_IDWIPSTOCKAccount
       JOIN aJournalLine aJL ON aJL.ID = aJournalLine_ID 
       JOIN aJournal aJ ON aJ.ID = aJL.aJournal_ID 
       JOIN aJournalRange aJR ON aJR.ID = aJ.aJournalRange_ID
       JOIN aJournalType aJT ON aJT.ID = aJR.aJournalType_ID
       WHERE aT.AmountBase > 0 
       AND sDP.AmountBaseWIP > 0
       AND aJT.NominalJournal = 1
       GROUP BY aTransaction_IDWIPSTOCKAccount, aT.AmountBase, JournalNo, aT.ID , aJ.RecordTimeStampCreated, aT.Credit
       HAVING SUM(Qty * (AmountBaseWIP)) <> aT.AmountBase ) ds

UNION 



SELECT '3', 
       'Duplicate Barcodes', 
       COUNT(*) AS 'Count', 
       'SELECT MAX (ID) ID FROM sStock GROUP BY BarCode HAVING COUNT(*) > 1'
FROM
(
    SELECT MAX(ID) ID
    FROM sStock
    GROUP BY BarCode
    HAVING COUNT(*) > 1
) Stock

UNION

SELECT '3', 
       'Missing Barcodes', 
       COUNT(*) AS 'Count', 
       'SELECT sStock.ID FROM sStock WHERE BarCode = '''''
FROM
(
    SELECT sStock.ID
    FROM sStock
    WHERE BarCode = ''
) Stock


UNION

SELECT '2', 
       'Missing Demand Statuses', 
       COUNT(*) AS 'Count', 
       'SELECT sDemandItemStatus_ID, * FROM sDemandPart WHERE sDemandItemStatus_ID = 0'
FROM
(
    SELECT sDemandItemStatus_ID FROM sDemandPart WHERE sDemandItemStatus_ID = 0
) Stock



)ds
WHERE ds.ErrorCount > 0
ORDER BY Priority;


GO


