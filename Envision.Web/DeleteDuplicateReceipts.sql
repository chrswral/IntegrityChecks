SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (

	SELECT * 
	FROM sys.procedures
	WHERE name = 'DeleteDuplicateReceipts'  
)
 
DROP PROCEDURE sup.DeleteDuplicateReceipts
	
	GO
  
CREATE PROC [sup].[DeleteDuplicateReceipts]  

	 @ReceiptID int

 AS

SET NOCOUNT ON

DECLARE @NewJournalID int = 0

DECLARE @TableVariable TABLE (ReceiptID int, ReceiptTransactionID int, TransactionID int, JournalID int, ReceiptNoID int, ReceiptQty int)

INSERT INTO @TableVariable
SELECT R.ID ReceiptID, RT.ID ReceiptTransactionID, T.ID TransactionID, J.ID JournalID , RNo.ID, R.Qty
FROM sOrderPartReceipt R
JOIN sOrderReceiptNo RNo ON RNo.ID = R.sOrderReceiptNo_ID
JOIN sOrderPartReceiptTransaction RT ON RT.sOrderPartReceipt_ID = R.ID
JOIN aTransaction T ON T.ID = RT.aTransaction_ID
JOIN aJournal J ON J.ID = T.aJournal_ID
WHERE RNo.ID = @ReceiptID


IF  EXISTS (SELECT ID FROM sStock JOIN @TableVariable TV ON TV.ReceiptID = sStock.sOrderPartReceipt_ID WHERE TV.ReceiptQty = sStock.Qty)
BEGIN 

	PRINT 'Exists'

	SELECT * FROM @TableVariable

	

		PRINT 'Inserting aJournal Record'
		INSERT INTO aJournal	(JournalNo,JournalReference,aTerm_ID,aPeriod_ID,aJournalRange_ID,aAccount_ID,aCurrency_ID,aCurrencyExchangeRate_ID,aTaxCode_ID,AmountNett,AmountTax,aAddress_IDInvoice,aAddress_IDDelivery,Description,JournalDate,DueDate,uRALUser_IDApproved,ApprovedDate,aJournalSI_ID,aJournalPI_ID,aJournalStatus_ID,aJournalStatus_IDExport,aJournalPIRemark_ID,JournalTypeCredit,JournalExchangeRate,Proforma,aJournalExportFile_ID,Marked,SpecialJournalType
				,AutoFOC,Reversing,aJournal_IDFinalSalesInvoice,aSettlementDiscount_ID,aLanguage_ID,uRALUser_IDPartsInvoiceTicketPrint,uRALUser_IDServiceInvoiceTicketPrint,DatePartsInvoiceTicketPrint,DateServiceInvoiceTicketPrint,GUID,uRALUser_ID,uRALUser_IDCreated
				,RecordTimeStampCreated,RecordLocked,Closed,ReadOnly,RecordTimeStamp,aPurchaseInvoiceCategory_ID,Prepayment,ExportMessage,sOrderPartReceipt_IDCosting,uRALUser_IDPrinted,PrintedDate,FinanceSystemReference,aJournal_IDReversalOf,InvoiceTotal,uRALBase_ID,aJournal_IDCredit,aAddressContact_IDInvoice	)
	
		SELECT	 JournalNo+'*'
				,JournalReference,aTerm_ID,aPeriod_ID,aJournalRange_ID,aAccount_ID,aCurrency_ID,aCurrencyExchangeRate_ID,aTaxCode_ID,AmountNett,AmountTax,aAddress_IDInvoice,aAddress_IDDelivery,Description,JournalDate,DueDate,uRALUser_IDApproved,ApprovedDate,aJournalSI_ID,aJournalPI_ID
				,(SELECT TOP 1 ID FROM aJournalStatus WHERE Posted = 1)
				,aJournalStatus_IDExport
				,aJournalPIRemark_ID,JournalTypeCredit,JournalExchangeRate,Proforma,aJournalExportFile_ID,Marked,SpecialJournalType,AutoFOC,Reversing,aJournal_IDFinalSalesInvoice,aSettlementDiscount_ID,aLanguage_ID,uRALUser_IDPartsInvoiceTicketPrint,uRALUser_IDServiceInvoiceTicketPrint,DatePartsInvoiceTicketPrint,DateServiceInvoiceTicketPrint,GUID
				,uRALUser_ID,uRALUser_IDCreated,RecordTimeStampCreated,RecordLocked,Closed,ReadOnly,RecordTimeStamp,aPurchaseInvoiceCategory_ID,Prepayment,ExportMessage,sOrderPartReceipt_IDCosting,uRALUser_IDPrinted,PrintedDate,FinanceSystemReference,aJournal_IDReversalOf,InvoiceTotal
				,uRALBase_ID,aJournal_IDCredit,aAddressContact_IDInvoice
		FROM aJournal J
		JOIN @TableVariable TV ON TV.JournalID = J.ID


		SELECT @NewJournalID = SCOPE_IDENTITY()
	
 		PRINT 'Inserting aTransaction Records'
		INSERT INTO aTransaction (	 aAccount_ID	,aAccountAnalysis_ID	,aJournalLine_ID	,aTaxCode_ID	,tAsset_ID	,TransactionLineNumber	,TransactionLineDescription	,Credit 	,PostingPeriod	,AmountFC	,AmountBase	,AmountRC
				,aTransaction_IDTaxLine	,AmountTaxFC	,AmountTaxBase	,AmountTaxRC	,DontMerge	,Manual	,GUID	,uRALUser_ID	,uRALUser_IDCreated	,RecordTimeStampCreated	,RecordLocked	,Closed	,ReadOnly
				,RecordTimeStamp	,uRALBase_ID	,irImportID	,sBudget_ID	,aJournal_ID	,IsFromMerge)

		SELECT 	 aAccount_ID	,aAccountAnalysis_ID	,aJournalLine_ID	,aTaxCode_ID	,tAsset_ID	,TransactionLineNumber	,TransactionLineDescription	,IIF(Credit > 0, 0, 1),PostingPeriod	,AmountFC	,AmountBase	,AmountRC
				,aTransaction_IDTaxLine	,AmountTaxFC	,AmountTaxBase	,AmountTaxRC	,DontMerge	,Manual	,GUID	,uRALUser_ID	,uRALUser_IDCreated	,RecordTimeStampCreated	,RecordLocked	,Closed	,ReadOnly
				,RecordTimeStamp	,uRALBase_ID	,irImportID	,sBudget_ID	,@NewJournalID	,IsFromMerge
		FROM aTransaction T
		JOIN @TableVariable TV ON TV.JournalID = T.aJournal_ID

		
		PRINT 'Deleting sStock record'
		DELETE sStock
		FROM sStock 
		JOIN @TableVariable TV ON TV.ReceiptID = sStock.sOrderPartReceipt_ID

		PRINT 'Deleting sOrderPartReceiptTransaction record'
		DELETE sOrderPartReceiptTransaction
		FROM sOrderPartReceiptTransaction
		JOIN @TableVariable TV ON TV.ReceiptID = sOrderPartReceiptTransaction.sOrderPartReceipt_ID

		PRINT 'Deleting sOrderReceiptNo record'
		DELETE sOrderReceiptNo
		FROM sOrderReceiptNo
		JOIN sOrderPartReceipt ON sOrderPartReceipt.sOrderReceiptNo_ID = sOrderReceiptNo.ID
		JOIN @TableVariable TV ON TV.ReceiptID = sOrderPartReceipt.ID

		PRINT 'Deleting sOrderPartReceipt record'
		DELETE sOrderPartReceipt
		FROM sOrderPartReceipt
		JOIN @TableVariable TV ON TV.ReceiptID = sOrderPartReceipt.ID

		SELECT JournalNo, * 
		FROM aTransaction T
		JOIN aJournal J ON J.ID = T.aJournal_ID
		WHERE J.ID = @NewJournalID

END
