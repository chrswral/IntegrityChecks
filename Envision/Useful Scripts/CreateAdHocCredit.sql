

/* Created AdHoc stock Check */

/* WARNING - Check and test */


DECLARE @ReceiptID int = 49215
DECLARE @Qty int = 2       -- Qty to be credited (Positive)
DECLARE @BaseID int = 1006 -- Ensure correct base is credited back to avoid finance problems. Use BaseQtyCheck.sql if needed

DECLARE @RusadaID int = 1

BEGIN TRAN


	INSERT INTO sDemandPart(
	sDemand_ID
	,sDemandItemStatus_ID
	,sPartTransactionType_ID
	,sPart_IDOriginal
	,sPart_IDDemanded
	,uRALBase_ID
	,uRALUser_IDIssue
	,IssueDate
	,sPartUnit_ID
	,sPartCondition_ID
	,DemandItem   
	,DemandItemSequence
	,OriginalPartNo
	,CustomerDemandItemDate
	,Qty
	,sOrderPartReceipt_ID
	,sBaseWarehouseLocation_ID
	,aCurrency_IDSale
	,aPeriod_ID
	,OriginalRequisitionCreateDate
	,uRALUser_ID
	,uRALUser_IDCreated
	,RecordTimeStampCreated
	,RecordTimeStamp
	,sReasonCode_ID
	,aTransaction_IDWIP
	,AmountBaseWIP
	, sStockOwnership_ID)

	SELECT 

	(SELECT TOP 1 ID
		FROM sDemand
		WHERE AdhocStockAdjustment = 1
		AND aPeriod_ID=0 
	)  -- Stock Check ID  sDemandID For Adhoc stock Check 
	,(SELECT ID FROM sDemandItemStatus WHERE Credit = 1) -- Demand Item Status  needs to be a credited status
	,(SELECT TOP 1 ID FROM sPartTransactionType WHERE Credit = 1) -- Tran Type is going to need to be a credit
	,sOrderPartReceipt.sPart_ID    -- Part ID 
	,sOrderPartReceipt.sPart_ID   -- Partt ID
	,@BaseID -- Ral Base the base it was issued from 
	,@RusadaID  -- Issued User the user who did the first issue
	,GETDATE()  -- Issued Date the date of the first issue 
	,sPartUnit_ID  -- Part Unit unit of stock measure	
	,sPartCondition_ID -- Condition stock condidition 
	,'0001' --Leave as 
	,'0001' -- Leave as
	,''  -- Part Number
	,GETDATE() -- Issue Date 
	,@Qty * -1    -- Credit Qty 
	,sOrderPartReceipt.ID  --  ReceiptID
	,sBaseWarehouseLocation_ID   -- Location is the last known stock location
	,(SELECT TOP 1 aCurrency_IDBase FROM aCompany) -- Currency
	,(
	SELECT TOP 1 ID 
	FROM aPeriod
	WHERE CurrentPeriod = 1 ) -- PeriodID Needs to be the current period
	,GETDATE()  -- Requstion  date
	,@RusadaID --- Issued User the user who did the first issue
	,@RusadaID --- Issued User the user who did the first issue
	,GETDATE()  -- Rec Time Stamps
	,GETDATE()  -- Rec Time Stamps
	,1  -- Reason Code should be fine as is 
	,0  --aT WIP ID 
	,0  -- Leave as it is 
	, sStockOwnership_ID
	FROM sOrderPartReceipt
	WHERE ID = @ReceiptID

	SELECT * FROM sup.StockIntegrityCheck

ROLLBACK 
