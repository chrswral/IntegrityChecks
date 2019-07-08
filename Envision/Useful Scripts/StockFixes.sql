/*-----CREATE MISSING STOCK RECORD FROM RECEIPT-----*/
/****** Object:  StoredProcedure [sup].[FixMissingStockFromReceipt]    Script Date: 25/10/2018 09:31:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--IF THERE IS NO STOCK LOG RECORD
IF EXISTS (

	SELECT * 
	FROM sys.procedures
	WHERE name = 'FixMissingStockFromReceipt'  
)
 
DROP PROCEDURE sup.FixMissingStockFromReceipt
	
	GO
  
CREATE PROC [sup].[FixMissingStockFromReceipt]  

	 @sOrderPartReceiptID int

 AS

SET NOCOUNT ON


DECLARE @AuditHistoryPending TABLE (
    BaseTableID INT NOT NULL,
    Fix VARCHAR(50) NOT NULL,
    BaseTable VARCHAR(50)
)

BEGIN TRAN 

BEGIN TRY 
	IF NOT EXISTS 
		(SELECT sOrderPartReceipt_ID 
		 FROM   sup.StockIntegrityCheck
		 WHERE  sOrderPartReceipt_ID = @sOrderPartReceiptID)
	THROW 50001, 'The Receipt ID provided does not exist as an integrity error',1

	IF  EXISTS 
		(SELECT sStock.ID
		 FROM   sStock
		 WHERE  sStock.sOrderPartReceipt_ID = @sOrderPartReceiptID)
	THROW 50002, 'The Receipt ID provided already has a Stock record',1

	IF EXISTS
		(SELECT sStockLog.ID 
		 FROM   sStockLog
		 WHERE  sStockLog.sOrderPartReceipt_ID = @sOrderPartReceiptID)
	THROW 50003, 'The Receipt ID provided has a Stock Log record',1


	INSERT INTO sStock
	(
		 sOrderPartReceipt_ID
		,sBaseWarehouseLocation_ID
		,sPartCondition_ID
		,Qty
		,GUID
		,uRALUser_ID
		,uRALUser_IDCreated
		,RecordTimeStampCreated
		,RecordTimeStamp
		,sBaseWarehouseLocation_IDLast
		,sStockOwnership_ID
	)
	OUTPUT inserted.ID,'Inserted: Missing Stock Record from Receipt','sStock'
	INTO @AuditHistoryPending   

	SELECT 
	 sOrderPartReceipt.ID
	,sOrderPartReceipt.sBaseWarehouseLocation_ID
	,sOrderPartReceipt.sPartCondition_ID
	,sOrderPartReceipt.Qty
	,NEWID()
	,sOrderReceiptNo.uRALUser_IDCreated
	,sOrderReceiptNo.uRALUser_IDCreated
	,sOrderReceiptNo.ReceiptDate
	,sOrderReceiptNo.ReceiptDate
	,sOrderPartReceipt.sBaseWarehouseLocation_ID
	,sOrderPartReceipt.sStockOwnership_ID
	FROM sOrderPartReceipt
	JOIN sOrderReceiptNo on sOrderReceiptNo.ID = sOrderPartReceipt.sOrderReceiptNo_ID
	WHERE sOrderPartReceipt.ID = @sOrderPartReceiptID;

	INSERT INTO sup.AuditHistory(BaseTable,BaseTableID,Fix)
	SELECT BaseTable,BaseTableID,Fix FROM @AuditHistoryPending

	

	IF EXISTS 
		(SELECT sOrderPartReceipt_ID 
		 FROM   sup.StockIntegrityCheck
		 WHERE  sOrderPartReceipt_ID = @sOrderPartReceiptID)
	THROW 50004, 'The Receipt ID provided is still present in the stock integrity check, the insert will be rolled back',1

	  COMMIT
	END TRY 
BEGIN CATCH

	ROLLBACK
	SELECT ERROR_MESSAGE()

END CATCH

GO



/*-----CREATE MISSING STOCK RECORD FROM sStockLog-----*/
/****** Object:  StoredProcedure [sup].[FixMissingStockFromReceipt]    Script Date: 25/10/2018 09:56:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--IF THERE IS NO STOCK LOG RECORD
IF EXISTS (

	SELECT * 
	FROM sys.procedures
	WHERE name = 'FixMissingStockFromStockLog'  
)
 
DROP PROCEDURE sup.FixMissingStockFromStockLog
	
	GO


CREATE PROC [sup].[FixMissingStockFromStockLog]  

	 @sStockLog int

 AS

SET NOCOUNT ON


DECLARE @AuditHistoryPending TABLE (
    BaseTableID INT NOT NULL,
    Fix VARCHAR(50) NOT NULL,
    BaseTable VARCHAR(50)
)

BEGIN TRAN 

BEGIN TRY 
	IF NOT EXISTS 
		(SELECT sOrderPartReceipt_ID 
		 FROM   sup.StockIntegrityCheck
		 WHERE  sOrderPartReceipt_ID IN 
		 		(SELECT sOrderPartReceipt_ID 
				 FROM   sStockLog 
				 WHERE  sStockLog.ID = @sStockLog)
				 )
	THROW 50001, 'The sStock Log ID provided does not exist as an integrity error',1

	INSERT INTO sStock
	(
		 sOrderPartReceipt_ID
		,sBaseWarehouseLocation_ID
		,sPartCondition_ID
		,Qty
		,GUID
		,uRALUser_ID
		,uRALUser_IDCreated
		,RecordTimeStampCreated
		,RecordTimeStamp
		,sBaseWarehouseLocation_IDLast
		,sStockOwnership_ID
	)
	OUTPUT inserted.ID,'Inserted: Missing Stock Record from StockLog','sStock'
	INTO @AuditHistoryPending   

SELECT TOP 1
	 sStockLog.sOrderPartReceipt_ID
	,sStockLog.sBaseWarehouseLocation_ID
	,sStockLog.sPartCondition_ID
	,sStockLog.Qty
	,NEWID()
	,sOrderReceiptNo.uRALUser_IDCreated
	,sOrderReceiptNo.uRALUser_IDCreated
	,sOrderReceiptNo.ReceiptDate
	,sOrderReceiptNo.ReceiptDate
	,sStockLog.sBaseWarehouseLocation_ID
	,sStockLog.sStockOwnership_ID
	FROM sStockLog
	JOIN sOrderPartReceipt ON sStockLog.sOrderPartReceipt_ID = sOrderPartReceipt.ID
    JOIN sOrderReceiptNo ON sOrderPartReceipt.sOrderReceiptNo_ID = sOrderReceiptNo.ID
	WHERE sStockLog.ID = @sStockLog
	ORDER BY sStockLog.RecordTimeStampCreated DESC;


	INSERT INTO sup.AuditHistory(BaseTable,BaseTableID,Fix)
	SELECT BaseTable,BaseTableID,Fix FROM @AuditHistoryPending	

	IF EXISTS 
		(SELECT sOrderPartReceipt_ID 
		 FROM   sup.StockIntegrityCheck
		 WHERE  sOrderPartReceipt_ID IN 
		 		(SELECT sOrderPartReceipt_ID 
				 FROM   sStockLog 
				 WHERE  sStockLog.ID = @sStockLog)
				 )
	THROW 50004, 'The Receipt ID provided is still present in the stock integrity check, the insert will be rolled back',1

	  COMMIT
	END TRY 
BEGIN CATCH

	ROLLBACK
	SELECT ERROR_MESSAGE()

END CATCH

GO




