
/* TO BE IMPROVED

ADD VALIDATION

*/

DECLARE @JournalID int = 4992

BEGIN TRAN

UPDATE sDemandPart
SET aTransaction_IDWIP = 0
,AmountBaseWIP = 0
FROM sDemandPart
JOIN aTransaction ON aTransaction.ID = sDemandPart.aTransaction_IDWIP
JOIN aJournalLine ON aJournalLine.ID = aJournalLine_ID
WHERE aJournalLine.aJournal_ID = @JournalID

UPDATE sDemandPart
SET aTransaction_IDWIPSTOCKAccount = 0
,AmountBaseWIP = 0
FROM sDemandPart
JOIN aTransaction ON aTransaction.ID = sDemandPart.aTransaction_IDWIPSTOCKAccount
JOIN aJournalLine ON aJournalLine.ID = aJournalLine_ID
WHERE aJournalLine.aJournal_ID = @JournalID

DELETE aTransaction 
FROM aTransaction 
JOIN aJournalLine ON aJournalLine.ID = aJournalLine_ID
WHERE aJournalLine.aJournal_ID = @JournalID

DELETE 
FROM aJournalLine 
WHERE aJournalLine.aJournal_ID = @JournalID

ROLLBACK