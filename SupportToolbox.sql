
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
SELECT '3',
       'Cancelled Demands with WIP or COS',
       ISNULL(COUNT(sDemandPart.ID), 0),
       'SELECT sDemandPart.Qty, sDemandItemStatus.Status, sPartTransactionType.TransactionType, AmountBaseWIP, aTransaction_IDWIP, AmountBaseCOS, aTransaction_IDCOS FROM sDemandPart JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID JOIN sPartTransactionType ON sPartTransactionType.ID = sPartTransactionType_ID WHERE (sDemandItemStatus.Issued = 0 AND sDemandItemStatus.Credit = 0) AND (aTransaction_IDWIP + aTransaction_IDCOS > 0) AND (AmountBaseWIP + AmountBaseCOS > 0)'
FROM sDemandPart
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID
WHERE(sDemandItemStatus.Issued = 0
      AND sDemandItemStatus.Credit = 0)
     AND (aTransaction_IDWIP + aTransaction_IDCOS > 0)

UNION
SELECT '3',
       'Demands with WIP or COS created after the WIP or COS Journal',
       ISNULL(COUNT(sDemandPart.ID), 0),
       'SELECT sDemandPart.ID, sDemandPart.RecordTimeStampCreated , AmountBaseWIP, aT_WIP.RecordTimeStampCreated, AmountBaseCOS, aT_COS.RecordTimeStampCreated, sDemandItemStatus.Status FROM sDemandPart JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID JOIN aTransaction aT_WIP ON aT_WIP.ID = sDemandPart.aTransaction_IDWIP JOIN aTransaction aT_COS ON aT_COS.ID = sDemandPart.aTransaction_IDCOS WHERE sDemandPart.RecordTimeStampCreated > aT_WIP.RecordTimeStampCreated OR sDemandPart.RecordTimeStampCreated > aT_COS.RecordTimeStampCreated '
FROM sDemandPart
JOIN aTransaction aT_WIP ON aT_WIP.ID = sDemandPart.aTransaction_IDWIP
JOIN aTransaction aT_COS ON aT_COS.ID = sDemandPart.aTransaction_IDCOS
WHERE sDemandPart.RecordTimeStampCreated > aT_WIP.RecordTimeStampCreated
      OR sDemandPart.RecordTimeStampCreated > aT_COS.RecordTimeStampCreated 


UNION
SELECT '3',
       'Demand Parts not equal WIP PE',
       ISNULL(COUNT(JournalNo), 0),
       'SELECT JournalNo, aJ.RecordTimeStampCreated,
              SUM(Qty * (AmountBaseWIP)) sDemandPart_AmountBase, 
              (aT.AmountBase * IIF(aT.Credit=1,-1,1)) AmountBase
              , aT.ID 
              FROM sDemandPart sDP 
              JOIN aTransaction aT ON aT.ID = aTransaction_IDWIP 
              JOIN aJournalLine aJL ON aJL.ID = aJournalLine_ID 
              JOIN aJournal aJ ON aJ.ID = aJournal_ID 
              JOIN aJournalRange aJR ON aJR.ID = aJ.aJournalRange_ID
              JOIN aJournalType aJT ON aJT.ID = aJR.aJournalType_ID
              WHERE aT.AmountBase > 0 
              AND sDP.AmountBaseWIP > 0
              AND aJT.NominalJournal = 1
              GROUP BY aTransaction_IDWIP, aT.AmountBase, JournalNo, aT.ID , aJ.RecordTimeStampCreated, aT.Credit
              HAVING SUM(Qty * (AmountBaseWIP)) <> (aT.AmountBase * IIF(aT.Credit=1,-1,1))'
FROM
(
       SELECT JournalNo, aJ.RecordTimeStampCreated,
       SUM(Qty * (AmountBaseWIP)) sDemandPart_AmountBase, 
       (aT.AmountBase * IIF(aT.Credit=1,-1,1)) AmountBase
       , aT.ID 
       FROM sDemandPart sDP 
       JOIN aTransaction aT ON aT.ID = aTransaction_IDWIP 
       JOIN aJournalLine aJL ON aJL.ID = aJournalLine_ID 
       JOIN aJournal aJ ON aJ.ID = aJournal_ID 
       JOIN aJournalRange aJR ON aJR.ID = aJ.aJournalRange_ID
       JOIN aJournalType aJT ON aJT.ID = aJR.aJournalType_ID
       WHERE aT.AmountBase > 0 
       AND sDP.AmountBaseWIP > 0
       AND aJT.NominalJournal = 1
       GROUP BY aTransaction_IDWIP, aT.AmountBase, JournalNo, aT.ID , aJ.RecordTimeStampCreated, aT.Credit
       HAVING SUM(Qty * (AmountBaseWIP)) <> (aT.AmountBase * IIF(aT.Credit=1,-1,1))
) ds
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
       'Duplicate Stock Config Settings',
       ISNULL(COUNT(sStockConfig.ID), 0),
       'SELECT ConfigName FROM sStockConfig GROUP BY ConfigName HAVING COUNT(ConfigName) > 1'
FROM sStockConfig
GROUP BY ConfigName
HAVING COUNT(ConfigName) > 1

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

SELECT '3', 'Old Support Schema Procs', ISNULL(COUNT(*),0), 'SELECT ''SP'' AS Type,
               p.name,
               ep.value
        FROM sys.procedures p
        JOIN sys.schemas s ON s.schema_id = p.schema_id
        LEFT JOIN sys.extended_properties ep ON ep.major_id = p.object_id
        WHERE s.name = ''Support''
        UNION
        SELECT ''View'',
               v.name,
               ep.value
        FROM sys.views v
        JOIN sys.schemas s ON s.schema_id = v.schema_id
        LEFT JOIN sys.extended_properties ep ON ep.major_id = v.object_id
        WHERE s.name = ''Support'''

FROM (  SELECT 'SP' AS Type,
               p.name,
               ep.value
        FROM sys.procedures p
        JOIN sys.schemas s ON s.schema_id = p.schema_id
        LEFT JOIN sys.extended_properties ep ON ep.major_id = p.object_id
        WHERE s.name = 'Support'
        UNION
        SELECT 'View',
               v.name,
               ep.value
        FROM sys.views v
        JOIN sys.schemas s ON s.schema_id = v.schema_id
        LEFT JOIN sys.extended_properties ep ON ep.major_id = v.object_id
        WHERE s.name = 'Support') ds
UNION 

SELECT '2',
       'Bad Config Settings', 
       ISNULL(COUNT(*),0),
       'SELECT * FROM sup.BadConfig'
FROM
sup.BadConfig

UNION

SELECT '2'
        , 'Unbalanced Labour WIP Lines'
        , ISNULL(COUNT(*),0)
        , 'SELECT vTransaction.ID, JournalNo, vTransaction.TransactionLineNumber, vTransaction.TransactionLineDescription, vTransaction.AmountBase, vTransaction.Credit, SUM(AmountBaseWIP) AS AmountBaseWIP
        FROM sup.vTransaction JOIN lEmployeeDayHours ON lEmployeeDayHours.aTransaction_IDWIPWIPAccount = vTransaction.ID	OR lEmployeeDayHours.aTransaction_IDWIP = vTransaction.ID GROUP BY vTransaction.ID, JournalNo, vTransaction.AmountBase, vTransaction.Credit, vTransaction.TransactionLineNumber, vTransaction.TransactionLineDescription 
        HAVING SUM(AmountBaseWIP) <> vTransaction.AmountBase ORDER BY JournalNo, TransactionLineNumber'
FROM (SELECT 
aTransaction.ID
, SUM(AmountBaseWIP) AS AmountBaseWIP
FROM aTransaction
JOIN lEmployeeDayHours ON lEmployeeDayHours.aTransaction_IDWIPWIPAccount = aTransaction.ID
	OR lEmployeeDayHours.aTransaction_IDWIP = aTransaction.ID
GROUP BY aTransaction.ID, aTransaction.AmountBase
HAVING SUM(AmountBaseWIP) <> aTransaction.AmountBase
)ds


)

 ds
WHERE ds.ErrorCount > 0
ORDER BY Priority;



GO

EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = N'Returns general integrity errors',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'VIEW',
     @level1name = N'GeneralIntegrityChecks';

GO


/*** Stock Integrity Checks ***/

IF EXISTS
(
SELECT *
FROM sys.views
WHERE name = 'StockIntegrityCheck'
)
    DROP VIEW sup.StockIntegrityCheck;

GO
CREATE VIEW [sup].[StockIntegrityCheck]
AS
SELECT T.sOrderPartReceipt_ID,
       PartNo,
       ReceiptNo,
       ReceiptDate,
(
       SELECT MAX(sDemandPart.IssueDate)
       FROM sDemandPart
       WHERE sDemandPart.sOrderPartReceipt_ID = T.sOrderPartReceipt_ID
) AS 'Issue Date',
       SerialNo,
       ReceiptQty,
       StockQty,
       IssueQty,
       ReceiptQty - StockQty - IssueQty AS Discrepancy,
      'Fix Required' = CASE 
                            WHEN ReceiptQty > StockQty + IssueQty AND EXISTS(SELECT * 
                                                                                 FROM sStockLog
                                                                                 WHERE sOrderPartReceipt_ID = T.sOrderPartReceipt_ID )
                            THEN 'Missing Stock Fix From Stock Log Proc'
                            WHEN ReceiptQty > StockQty + IssueQty THEN 'Missing Stock Fix From sOrderPartReciept Proc'
                            ELSE 'Not A Missing Stock Fix'                                                 
--- NEW CASE LOGIC NEEDED TO WORK OUT WHICH FIX TO APPLY IF STOCK LOG RECORD EXISTS AND STOCK IS MISSING THEN USE Stock Log FIX IF MISSING AND NO STOCK LOG THEN FIX FROM ORDER RECIEPT

                        END
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
             SELECT SUM(Qty)
             FROM dbo.sDemandPart
             WHERE(sOrderPartReceipt_ID = dbo.sOrderPartReceipt.ID)
                  AND ((sDemand_ID = -2)
                       OR (sDemandItemStatus_ID IN
                          (
                       SELECT ID
                       FROM dbo.sDemandItemStatus
                       WHERE((Issued = 1)
                             OR (Credit = 1))
                          )))
             ), 0) AS IssueQty
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
      AND sOrderReceiptRange.aCompany_ID = IIF(
                                              (
                                              SELECT COUNT(ID)
                                              FROM aCompany
                                              WHERE Code = 'WAS'
                                              ) > 0, 2, sOrderReceiptRange.aCompany_ID) --Limit to WAS company in WAS

) AS T(sOrderPartReceipt_ID, PartNo, ReceiptNo, ReceiptDate, SerialNo, ReceiptQty, StockQty, IssueQty)
WHERE ReceiptQty <> StockQty + IssueQty;
GO
EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = N'Returns Stock Integrity Errors',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'VIEW',
     @level1name = N'StockIntegrityCheck';
GO


/*** Insert missing stock records ***/

IF EXISTS
(
SELECT *
FROM sys.procedures
WHERE name = 'sp_InsertMissingStockRecord'
)
    DROP PROCEDURE sup.sp_InsertMissingStockRecord;
GO



/*** Batch History ***/

IF EXISTS
(
SELECT *
FROM sys.procedures
WHERE name = 'sp_BatchHistory'
)
    DROP PROCEDURE sup.sp_BatchHistory;
GO
CREATE PROCEDURE [sup].[sp_BatchHistory] @sOrderPartReceiptID AS INT
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
               WHERE uRALUser.ID = aa.uRALUser_IDCreated
        ) AS [User],
               [Table],
               Qty,
               [Action],
               ID,
        (
               SELECT TOP 1 Message
               FROM uRALEvent
               WHERE aa.uRALUser_IDCreated = uRALEvent.uRALUser_IDCreated
                     AND uRALEvent.RecordTimeStampCreated BETWEEN DATEADD(S, -2, aa.RecordTimeStamp) AND DATEADD(S, 2, aa.RecordTimeStamp)
        ) AS Event,
        (
               SELECT TOP 1 DatabaseVersion
               FROM uRALDatabaseInfo
               WHERE aa.RecordTimeStamp > uRALDatabaseInfo.RecordTimeStampCreated
               ORDER BY ID DESC
        ) AS dbVersion
        FROM
        (
        SELECT sDemandPart.Version,
               sDemandPart.RecordTimeStamp AS RecordTimeStamp,
               sDemandPart.uRALUser_ID AS uRALUser_IDCreated,
           -- Hack; sorry CW.

               'sDemandPart' AS [Table],
               sDemand.ID AS DemandID,
               sDemandPart.ID AS DemandPartID,
               sDemand.DemandNo AS Demand,
               sDemandPart.DemandItem+'/'+sDemandPart.DemandItemSequence AS ItemSequence,
               sDemandPart.Qty,
               'Demand: '+DemandNo+'\'+DemandItem+'\'+DemandItemSequence+' ReceiptID:'+CAST(sDemandPart.sOrderPartReceipt_ID AS VARCHAR)+' - Status:'+sDemandItemStatus.Description+' - Trans:'+sPartTransactionType.Description AS [Action],
               sDemandPart.ID
        FROM sDemandPart
        INNER JOIN sDemandItemStatus ON sDemandPart.sDemandItemStatus_ID = sDemandItemStatus.ID
        INNER JOIN sPartTransactionType ON sDemandPart.sPartTransactionType_ID = sPartTransactionType.ID
        INNER JOIN sDemand ON sDemandPart.sDemand_ID = sDemand.ID
        WHERE sOrderPartReceipt_ID = @sOrderPartReceiptID
              OR sDemandPart.ID IN
        (
              SELECT sDemandPart_ID
              FROM sStockLog
              WHERE sStockLog.sOrderPartReceipt_ID = @sOrderPartReceiptID
        )
        UNION
        SELECT sDemandPartLog.Version,
               sDemandPartLog.RecordTimeStampCreated AS RecordTimeStamp,
               sDemandPartLog.uRALUser_IDCreated,
               'sDemandPartLog' AS [Table],
               sDemand.ID AS DemandID,
               BaseTableID AS DemandPartID,
               sDemand.DemandNo AS Demand,
               sDemandPartLog.DemandItem+'/'+sDemandPartLog.DemandItemSequence AS ItemSequence,
               sDemandPartLog.Qty,
               'Demand: '+DemandNo+'\'+DemandItem+'\'+DemandItemSequence+CASE WHEN sDemandPartLog.sOrderPartReceipt_ID > 0
                                                                             THEN ' ReceiptID:'+CAST(sDemandPartLog.sOrderPartReceipt_ID AS VARCHAR)
                                                                             ELSE ''
                                                                         END+' - Status:'+sDemandItemStatus.Description+CASE WHEN sDemandItemStatus.OnOrder = 0
                                                                                                                                  OR ISNULL(sOrder.OrderNo, '0') = '0'
                                                                                                                            THEN ''
                                                                                                                            ELSE ' '+sOrder.OrderNo+'\'+CAST(sOrderPart.OrderItem AS VARCHAR)
                                                                                                                        END+' - Trans:'+sPartTransactionType.Description+CASE WHEN sDemandPartLog.aTransaction_IDWIP > 0
                                                                                                                                                                             THEN ' - WIP ID:'+CAST(sDemandPartLog.aTransaction_IDWIP AS VARCHAR)
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
              OR sDemandPartLog.BaseTableID IN
        (
              SELECT sDemandPart_ID
              FROM sStockLog
              WHERE sStockLog.sOrderPartReceipt_ID = @sOrderPartReceiptID
        )
        UNION
        SELECT sDemandPartEvent.Version,
               sDemandPartEvent.RecordTimeStampCreated AS RecordTimeStamp,
               sDemandPartEvent.uRALUser_IDCreated,
               'sDemandPartEvent' AS [Table],
               sDemand.ID AS DemandID,
               sDemandPartEvent.sDemandPart_ID AS DemandPartID,
               sDemand.DemandNo AS Demand,
               sDemandPart.DemandItem+'/'+sDemandPart.DemandItemSequence AS ItemSequence,
               sDemandPart.Qty,
               'Demand: '+DemandNo+'\'+DemandItem+'\'+DemandItemSequence+CASE WHEN sDemandPartEvent.sOrderPartReceipt_ID > 0
                                                                             THEN ' ReceiptID:'+CAST(sDemandPartEvent.sOrderPartReceipt_ID AS VARCHAR)
                                                                             ELSE ''
                                                                         END+' - Status:'+sDemandItemStatus.Description+CASE WHEN sDemandItemStatus.OnOrder = 0
                                                                                                                                  OR ISNULL(sOrder.OrderNo, '0') = '0'
                                                                                                                            THEN ''
                                                                                                                            ELSE ' '+sOrder.OrderNo+'\'+CAST(sOrderPart.OrderItem AS VARCHAR)
                                                                                                                        END+' - Trans:'+sPartTransactionType.Description+CASE WHEN sDemandPartEvent.sDespatchPart_ID > 0
                                                                                                                                                                             THEN ' - Despatched'
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
               sDemandPartLog.DemandItem+'/'+sDemandPartLog.DemandItemSequence AS ItemSequence,
               sStockLog.Qty,
               'Stock BaseTableID: '+CAST(sStockLog.BaseTableID AS VARCHAR)+ISNULL(CASE WHEN sStockLog.sDemandPart_ID > 0
                                                                                       THEN ' - DemandPart: '+sDemandLog.DemandNo+'\'+sDemandPartLog.DemandItem+'\'+sDemandPartLog.DemandItemSequence
                                                                                       ELSE ''
                                                                                   END, '') AS [Action],
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
               '', --sOrderPartReceiptLog.sDemandPart_ID AS DemandID,
               '', --sDemandPart.ID AS DemandPartID,
               '', --sDemand.DemandNo AS Demand,
               '', --sDemandPart.DemandItem + '/' + sDemandPart.DemandItemSequence AS ItemSequence,
               sOrderPartReceiptLog.Qty,
               'Receipt: '+sOrderReceiptNo.ReceiptNo+' PartNo: '+sPart.PartNo COLLATE Latin1_General_CI_AS+CASE WHEN sOrderPartReceiptLog.SerialNo > ''
                                                                                                               THEN ' SerialNo: '+sOrderPartReceiptLog.SerialNo
                                                                                                               ELSE ''
                                                                                                           END+' Status: '+sOrderPartReceiptStatus.Description AS [Action],
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
               '', --sOrderPartReceipt.sDemandPart_ID AS DemandID,
               '', --sDemandPart.ID AS DemandPartID,
               '', --sDemand.DemandNo AS Demand,
               '', --sDemandPart.DemandItem + '/' + sDemandPart.DemandItemSequence AS ItemSequence,
               sOrderPartReceipt.Qty,
               'Receipt: '+sOrderReceiptNo.ReceiptNo+' - PartNo: '+sPart.PartNo COLLATE Latin1_General_CI_AS+CASE WHEN sOrderPartReceipt.SerialNo > ''
                                                                                                                 THEN ' SerialNo: '+sOrderPartReceipt.SerialNo
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
               sDemandPart.DemandItem+'/'+sDemandPart.DemandItemSequence AS ItemSequence,
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
               'Location Changed: '+uRALBaseFrom.RALBase+'\'+sBaseWarehouseFrom.Warehouse+'\'+sBaseWarehouseLocationFrom.Location+' to '+uRALBaseTo.RALBase+'\'+sBaseWarehouseTo.Warehouse+'\'+sBaseWarehouseLocationTo.Location AS [Action],
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
               sDemandPart.DemandItem+'/'+sDemandPart.DemandItemSequence AS ItemSequence,
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
        FROM
        (
        SELECT sOrderPartLog.Version,
               sOrderPartLog.RecordTimeStampCreated AS RecordTimeStamp,
               sOrderPartLog.uRALUser_IDCreated,
               'sOrderPartLog' AS [Table],
        (
               SELECT SUM(sOrderPartSchedule.Qty)
               FROM sOrderPartSchedule
               WHERE sOrderPartSchedule.sOrderPart_ID = sOrderPartLog.BaseTableID
        ) AS Qty,
               'Order: '+CAST(OrderNo AS VARCHAR)+'\'+CAST(sOrderPartLog.OrderItem AS VARCHAR)+' Received: '+ISNULL(CAST(
                                                                                                                        (
                                                                                                                        SELECT SUM(sOrderPartReceipt.Qty)
                                                                                                                        FROM sOrderPartReceipt
                                                                                                                        WHERE sOrderPartReceipt.RecordTimeStampCreated <= sOrderPartLog.RecordTimeStampCreated + 1
                                                                                                                              AND sOrderPartReceipt.sOrderPartSchedule_ID IN
                                                                                                                        (
                                                                                                                              SELECT ID
                                                                                                                              FROM sOrderPartSchedule
                                                                                                                              WHERE sOrderPartSchedule.sOrderPart_ID = sOrderPartLog.BaseTableID
                                                                                                                        )
                                                                                                                        ) AS VARCHAR), 0)+' Status: '+ISNULL(sOrderItemStatus.Description, 'Open')+' Type: '+ISNULL(sOrderPartType.Description, '') AS [Action],
               sOrderPartLog.ID
        FROM sOrderPartLog
        LEFT OUTER JOIN sOrderItemStatus ON sOrderPartLog.sOrderItemStatus_ID = sOrderItemStatus.ID
        LEFT OUTER JOIN sDemandPartLog ON sDemandPartLog.sOrderPart_ID = sOrderPartLog.BaseTableID
        LEFT OUTER JOIN sOrderPartType ON sOrderPartLog.sOrderPartType_ID = sOrderPartType.ID
        LEFT OUTER JOIN sOrder ON sOrderPartLog.sOrder_ID = sOrder.ID
        LEFT OUTER JOIN sDemand ON sDemandPartLog.sDemand_ID = sDemand.ID
        WHERE sOrderPartLog.BaseTableID IN
        (
        SELECT sOrderPart_ID
        FROM sOrderPartSchedule
        WHERE sOrderPartSchedule.ID IN
        (
        SELECT sOrderPartSchedule_ID
        FROM sOrderPartReceipt
        WHERE ID = @sOrderPartReceiptID
        )
        )
        ) AS sOrderPartLog
        GROUP BY sOrderPartLog.Version,
                 sOrderPartLog.RecordTimeStamp,
                 sOrderPartLog.uRALUser_IDCreated,
                 [Table],
                 Qty,
                 [Action],
                 sOrderPartLog.ID
        ) AS aa
        ORDER BY RecordTimeStamp,
                 Version;
    END;
GO
EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = N'Checks through all stores transaction tables and retrurns chronological events.',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'PROCEDURE',
     @level1name = N'sp_BatchHistory';
GO

/*** Tool Integrity Check ***/

IF EXISTS
(
SELECT *
FROM sys.views
WHERE name = 'ToolIntegrityCheck'
)
    DROP VIEW sup.ToolIntegrityCheck;
GO
CREATE VIEW [sup].[ToolIntegrityCheck]
AS
SELECT ID AS sOrderPartReceipt_ID,
       ReceiptNo,
       PartNo,
       ReceiptQty,
       ToolQty,
       IssueQty,
       SerialNo,
       (ToolQty + IssueQty) - ReceiptQty AS DiscrepancyQty
FROM
(
SELECT TransactionType.Tool,
       sOrderPartReceipt.ID AS sOrderPartReceipt_ID,
       sOrderReceiptNo.ReceiptNo,
       sOrderPartReceipt.SerialNo,
(
       SELECT PartNo
       FROM sPart
       WHERE ID = sPart_ID
) AS PartNo,
       Qty AS ReceiptQty,
       ISNULL(
             (
             SELECT SUM(Qty)
             FROM dbo.sStock
             WHERE(sOrderPartReceipt_ID = dbo.sOrderPartReceipt.ID)
             ), 0) AS ToolQty,
       ISNULL(
             (
             SELECT SUM(sDemandPart.Qty)
             FROM sDemandPart
             LEFT JOIN sPartTransactionType ON sPartTransactionType.ID = sDemandPart.sPartTransactionType_ID
             LEFT JOIN sDemandItemStatus ON sDemandPart.sDemandItemStatus_ID = sDemandItemStatus.ID
             LEFT JOIN sDemandPart AS Parent ON sDemandPart.sDemandPart_IDIssued = Parent.ID
             LEFT JOIN sPartTransactionType AS ParentsPTT ON Parent.sPartTransactionType_ID = ParentsPTT.ID
             WHERE sDemandPart.sOrderPartReceipt_ID = sOrderPartReceipt.ID
                   AND ((sDemandItemStatus.Issued = 1
                         AND sPartTransactionType.Loan = 0) 
                     -- Need to include genuine credit lines
                        OR (sDemandItemStatus.Credit = 1
                            AND sPartTransactionType.Credit = 1
                            AND (ISNULL(ParentsPTT.Tool, 0) = 0
                                 AND ISNULL(ParentsPTT.Loan, 0) = 0)))
             ), 0) AS IssueQty
FROM sOrderPartReceipt
JOIN sOrderReceiptNo ON sOrderPartReceipt.sOrderReceiptNo_ID = sOrderReceiptNo.ID
JOIN sPart ON sOrderPartReceipt.sPart_ID = sPart.ID
JOIN sPartClassification ON sPart.sPartClassification_ID = sPartClassification.ID
JOIN sPartTransactionType AS TransactionType ON sPartClassification.sPartTransactionType_IDDefault = TransactionType.ID
WHERE dbo.sOrderPartReceipt.sOrderPartReceiptStatus_ID IN
(
SELECT ID
FROM dbo.sOrderPartReceiptStatus
WHERE sOrderPartReceiptStatus.Inspection = 0
)
) AS T1(Tool, ID, ReceiptNo, SerialNo, PartNo, ReceiptQty, ToolQty, IssueQty)
WHERE Tool = 1
      AND ReceiptQty != ToolQty + IssueQty;
GO
EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = N'Returns tool integrity errors',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'VIEW',
     @level1name = N'ToolIntegrityCheck';
GO


/*** Bad Config ***/

IF EXISTS
(
SELECT *
FROM sys.views
WHERE name = 'BadConfig'
)
    DROP VIEW sup.BadConfig;
GO
CREATE VIEW sup.BadConfig
AS
SELECT *
FROM
(
SELECT ConfigName,
       'Should be False. True allows possible overruns' AS Problem
FROM uRALConfig
WHERE ConfigName LIKE 'AllowMIRemainingToBeGreaterThanLife'
UNION

-- IF ForecastingBasedOnAuditedTechLogs not true (NULL), then bad
SELECT IIF(COUNT(ID) = 0, 'ForecastingBasedOnAuditedTechLogs', NULL),
       ' Should be True. False does not recalculate asset and MI due values correctly'
FROM uRALConfig
WHERE ConfigName LIKE 'ForecastingBasedOnAuditedTechLogs'
) ds
WHERE ConfigName IS NOT NULL;
GO
EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = 'Looks for bad config setup',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'VIEW',
     @level1name = N'BadConfig';
GO

/*** Support Object Views ***/

IF EXISTS
(
SELECT *
FROM sys.views
WHERE name = 'vDemandPart'
)
    DROP VIEW sup.vDemandPart;

GO

CREATE VIEW sup.vDemandPart

AS

SELECT 
sDemandPart.ID
DemandNo, 
DemandItem+'\'+DemandItemSequence AS Item,
sPart.PartNo,
sPart.Description,
sOrderReceiptNo.ReceiptNo,
sOrderPartReceipt.SerialNo,
sDemandPart.Qty,
sPartTransactionType.TransactionType,
sDemandItemStatus.Status,
sDemandPart.RecordTimeStampCreated,
uRALUser.RALUser AS uRALUser_Created,
uRALUser.FirstName+' '+uRALUser.Surname AS UserCreated
FROM sDemandPart
JOIN sDemand ON sDemand.ID = sDemandPart.sDemand_ID
JOIN sOrderPartReceipt ON sOrderPartReceipt.ID = sDemandPart.sOrderPartReceipt_ID
JOIN sOrderReceiptNo ON sOrderPartReceipt.sOrderReceiptNo_ID = sOrderReceiptNo.ID
JOIN sPart ON sPart.ID = sDemandPart.sPart_IDDemanded
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandPart.sDemandItemStatus_ID
JOIN sPartTransactionType ON sDemandPart.sPartTransactionType_ID = sPartTransactionType.ID
JOIN uRALUser ON uRALUser.ID = sDemandPart.uRALUser_IDCreated

GO

EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = N'sDemandPart object view',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'VIEW',
     @level1name = N'vDemandPart';

GO     


IF EXISTS
(
SELECT *
FROM sys.views
WHERE name = 'vOrderPartReceipt'
)
    DROP VIEW sup.vOrderPartReceipt;

GO

CREATE VIEW sup.vOrderPartReceipt

AS

SELECT 
sOrderPartReceipt.ID AS ID,
sPart.PartNo AS PartNo,
sPart.Description,
sOrderReceiptNo.ReceiptNo,
sOrderPartReceipt.SerialNo AS SerialNo,
sOrderPartReceipt.Qty AS ReceiptQty,
sOrderPartReceipt.UnitCost,
sOrderPartReceiptStatus.Status,
sOrderPartReceipt.RecordTimeStampCreated,
uRALUser.RALUser AS uRALUser_Created,
uRALUser.FirstName+' '+uRALUser.Surname AS UserCreated
FROM sOrderPartReceipt
JOIN sPart ON sPart.ID = sOrderPartReceipt.sPart_ID
JOIN sOrderReceiptNo ON sOrderReceiptNo.ID = sOrderPartReceipt.sOrderReceiptNo_ID
JOIN sOrderPartReceiptStatus ON sOrderPartReceiptStatus.ID = sOrderPartReceipt.sOrderPartReceiptStatus_ID
JOIN uRALUser ON uRALUser.ID = sOrderPartReceipt.uRALUser_IDCreated

GO

EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = N'sOrderPartReceipt object view',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'VIEW',
     @level1name = N'vOrderPartReceipt';

GO    

GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vEmployeeDayHoursLog')
	DROP VIEW sup.vEmployeeDayHoursLog;
GO

CREATE VIEW sup.vEmployeeDayHoursLog
AS

SELECT
L.BaseTableID
, L.ID
,IIF(LAG(L.ID,1,0) OVER(PARTITION BY L.lEmployeeDay_ID ORDER BY L.ID)=L.ID-1,NULL,1) AS NewEdit
,L.LogChangeType
,CONVERT(smalldatetime,L.RecordTimeStampCreated) RecordTimeStampCreated
,CONCAT(sO.OrderNo,'\',sOT.TaskNo) AS OrderTask
,CONVERT(smalldatetime, L.StartTime) StartTime
,NULLIF(CONVERT(smalldatetime, L.FinishTime),'1900-01-01 00:00:00') FinishTime
,DurationMinutes
,lHC.HoursCode
,CONVERT(smalldatetime,lED.EnterWorkTime) EnterWorkTime
,CONVERT(smalldatetime,lED.LeaveWorkTime) LeaveWorkTime
, L.lEmployeeDay_ID
, L.lEmployee_ID
, CONCAT(lE.FirstName,' ',lE.Surname) AS EmployeeName
FROM lEmployeeDayHoursLog L
JOIN sOrderTask sOT ON sOT.ID = L.sOrderTask_ID
JOIN sOrder sO ON sOT.sOrder_ID = sO.ID
JOIN lEmployee lE ON lE.ID = L.lEmployee_ID
JOIN lEmployeeDay lED ON lED.ID = L.lEmployeeDay_ID
JOIN lHoursCode lHC ON L.lHoursCode_ID = lHC.ID 


GO

EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = N'lEmployeeDayHoursLog object view',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'VIEW',
     @level1name = N'vEmployeeDayHoursLog';

GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vEmployeeDayHours')
	DROP VIEW sup.vEmployeeDayHours;
GO    


CREATE VIEW sup.vEmployeeDayHours
AS

SELECT
H.ID
,IIF(LAG(H.ID,1,0) OVER(PARTITION BY H.lEmployeeDay_ID ORDER BY H.ID)=H.ID-1,NULL,1) AS NewEdit
,CONVERT(smalldatetime,H.RecordTimeStampCreated) RecordTimeStampCreated
,CONCAT(sO.OrderNo,'\',sOT.TaskNo) AS OrderTask
,CONVERT(smalldatetime, H.StartTime) StartTime
,NULLIF(CONVERT(smalldatetime, H.FinishTime),'1900-01-01 00:00:00') FinishTime
,DurationMinutes
,lHC.HoursCode
,CONVERT(smalldatetime,lED.EnterWorkTime) EnterWorkTime
,CONVERT(smalldatetime,lED.LeaveWorkTime) LeaveWorkTime
, H.lEmployeeDay_ID
, H.lEmployee_ID
, CONCAT(lE.FirstName,' ',lE.Surname) AS EmployeeName
FROM lEmployeeDayHours H
JOIN sOrderTask sOT ON sOT.ID = H.sOrderTask_ID
JOIN sOrder sO ON sOT.sOrder_ID = sO.ID
JOIN lEmployee lE ON lE.ID = H.lEmployee_ID
JOIN lEmployeeDay lED ON lED.ID = H.lEmployeeDay_ID
JOIN lHoursCode lHC ON H.lHoursCode_ID = lHC.ID 

GO

EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = N'lEmployeeDayHours object view',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'VIEW',
     @level1name = N'vEmployeeDayHours';

GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vTransaction')
	DROP VIEW sup.vTransaction;
GO

CREATE VIEW sup.vTransaction
AS

SELECT aT.ID
, aJ.JournalNo
, aT.TransactionLineNumber
, aT.TransactionLineDescription
, aT.AmountBase
, aT.AmountFC
, aT.Credit
, aA.Account
FROM aTransaction aT
JOIN aJournalLine aJL ON aJL.ID = aT.aJournalLine_ID
JOIN aJournal aJ ON aJ.ID = aJL.aJournal_ID
JOIN aAccount aA ON aA.ID = aT.aAccount_ID

GO

EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = N'aTransaction object view',
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'VIEW',
     @level1name = N'vTransaction';

GO  


/*** Help Proc ***/

IF EXISTS
(
SELECT *
FROM sys.procedures
WHERE name = 'Help'
)
    DROP PROCEDURE [sup].[Help];
GO
CREATE PROCEDURE [sup].[Help]
AS
    BEGIN
        SELECT 'SP' AS Type,
               p.name,
               ep.value
        FROM sys.procedures p
        JOIN sys.schemas s ON s.schema_id = p.schema_id
        LEFT JOIN sys.extended_properties ep ON ep.major_id = p.object_id
        WHERE s.name = 'sup'
        UNION
        SELECT 'View',
               v.name,
               ep.value
        FROM sys.views v
        JOIN sys.schemas s ON s.schema_id = v.schema_id
        LEFT JOIN sys.extended_properties ep ON ep.major_id = v.object_id
        WHERE s.name = 'sup';

		SELECT 
		Left(@@Version,55) AS SQLVersion
		,cpu_count
		, physical_memory_kb
		,virtual_machine_type
		, virtual_machine_type_desc
		FROM sys.dm_os_sys_info


		SELECT name,
		compatibility_level
		, recovery_model_desc
		, (SELECT CAST((SUM(size*8.0/1024/1024)) AS Decimal(10,2)) FROM sys.database_files) AS SizeInGB
		, EnvisionVersion.*
		, (SELECT COALESCE(CONVERT(VARCHAR(12), MAX(bus.backup_finish_date), 101),'-') AS LastBackUpTime
			FROM sys.sysdatabases sdb
			LEFT OUTER JOIN msdb.dbo.backupset bus ON bus.database_name = sdb.name
			WHERE sdb.name = DB_NAME()
			) AS LastBackup
		FROM sys.databases
		OUTER APPLY (select top 1 DatabaseVersion,LastUpdated from uRALDatabaseInfo order by ID desc) EnvisionVersion
		WHERE name = DB_NAME()


    END;
GO


/*** Results ***/

DECLARE @HelpText VARCHAR(100)= N'Support ToolBox Created '+CAST(GETDATE() AS VARCHAR(30));
EXEC sys.sp_addextendedproperty
     @name = N'HelpText',
     @value = @HelpText,
     @level0type = N'SCHEMA',
     @level0name = N'sup',
     @level1type = N'PROCEDURE',
     @level1name = N'Help';



GO
PRINT 'Support Procedures and Views created.';
PRINT 'Run EXEC sup.Help';
EXEC sup.Help;