USE [RALSUN]
GO

/****** Object:  StoredProcedure [sup].[StockIntegrityMissingIssues]    Script Date: 20/09/2018 15:45:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure  [sup].[StockIntegrityMissingIssues]
AS

/*** Check before fix ***/
SELECT * 
FROM sup.StockIntegrityCheck;


/*** CTE for most recent stock history ***/
 WITH StockLogID AS(

SELECT MAX(ID) AS ID, sOrderPartReceipt_ID FROM sStockLog WHERE sDemandPart_ID > 0 GROUP BY sOrderPartReceipt_ID
)


/*** Fix by instering Missing Record ***/

 INSERT INTO sStock(
 sOrderPartReceipt_ID,
 sBaseWarehouseLocation_ID, 
 sDemandPart_ID, 
 sDemandPart_IDStockRepair, 
 sStockCheckPart_ID, 
 sPartCondition_ID, 
 Qty, 
 BarCode, 
 StockRemarks, 
 DoNotAllocate, 
 uRALImport_ID, 
 GUID, 
 uRALUser_ID, 
 uRALUser_IDCreated, 
 RecordTimeStampCreated, 
 RecordLocked, 
 Closed, 
 ReadOnly, 
 RecordTimeStamp, 
 sBaseWarehouseLocation_IDLast, 
 sOrderPart_IDSI, 
 irImportID, 
 sStockInstructionItem_ID, 
 sStockOwnership_ID)  

 SELECT 
sup.StockIntegrityCheck.sOrderPartReceipt_ID, 
 sStockLog.sBaseWarehouseLocation_ID, 
 0, 
 0, 
 0, 
 sStockLog.sPartCondition_ID, 
 sup.StockIntegrityCheck.Discrepancy, 
 sStockLog.BarCode, 
 '', 
 0, 
 0, 
 sStockLog.GUID, 
 (SELECT TOP 1 ID FROM uRALUser WHERE LOWER(RALUser) IN('ra','rusada')), 
 (SELECT TOP 1 ID FROM uRALUser WHERE LOWER(RALUser) IN('ra','rusada')), 
 getdate(), 
 0, 
 0, 
 0, 
 getdate(), 
 0, 
 0, 
 (SELECT CONVERT(VARCHAR(35),GETDATE(),112)), 
 0, 
 sOrderPartReceipt.sStockOwnership_ID
 FROM  sStockLog  
 JOIN sup.StockIntegrityCheck on sup.StockIntegrityCheck.sOrderPartReceipt_ID = sStockLog.sOrderPartReceipt_ID
 JOIN sOrderPartReceipt on sup.StockIntegrityCheck.sOrderPartReceipt_ID = sOrderPartReceipt.ID
 JOIN StockLogID ON sStockLog.ID = StockLogID.ID
 WHERE [Stock Issue ] = 'Missing Stock'
 AND [Cause Of Issue] = 'Issue Error'


 /*** Check the results ***/
 SELECT * 
 FROM sup.StockIntegrityCheck 

 



GO


