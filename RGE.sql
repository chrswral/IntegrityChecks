
ALTER PROCEDURE sup.RGE

AS

UPDATE sStock
SET sStock.BarCode = ''
FROM sStock
WHERE ID IN 
(SELECT ID 
FROM sStock
ORDER BY ID DESC
OFFSET 10 ROWS FETCH NEXT 5 ROWS ONLY)


UPDATE sStock
SET sStock.BarCode = '012345'
FROM sStock
WHERE ID IN 
(SELECT ID 
FROM sStock
ORDER BY ID DESC
OFFSET 20 ROWS FETCH NEXT 5 ROWS ONLY)

UPDATE sDemandPart
SET sDemandItemStatus_ID = (SELECT TOP 1 ID FROM sDemandItemStatus WHERE Planned = 1)
FROM sDemandPart
WHERE ID IN (
SELECT sDemandPart.ID
FROM sDemandPart
JOIN sStock ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID
WHERE sDemandItemStatus.Planned = 0
ORDER BY sStock.ID
OFFSET 30 ROWS FETCH NEXT 5 ROWS ONLY)

UPDATE sDemandPart
SET sDemandItemStatus_ID = (SELECT TOP 1 ID FROM sDemandItemStatus WHERE Cancelled = 1)
FROM sDemandPart
WHERE ID IN (
SELECT sDemandPart.ID
FROM sDemandPart
JOIN sStock ON sStock.sDemandPart_ID = sDemandPart.ID
JOIN sDemandItemStatus ON sDemandItemStatus.ID = sDemandItemStatus_ID
WHERE sDemandItemStatus.Cancelled = 0
ORDER BY sStock.ID
OFFSET 40 ROWS FETCH NEXT 5 ROWS ONLY)

DELETE FROM sStock
WHERE sOrderPartReceipt_ID IN (
		  SELECT sOrderPartReceipt_ID
		  FROM sStock 
		  JOIN sOrderPartReceipt ON sOrderPartReceipt.ID = sOrderPartReceipt_ID
		  JOIN sPart ON sPart.ID = sOrderPartReceipt.sPart_ID
		  JOIN sPartClassification ON sPartClassification.ID = sPartClassification_ID
		  WHERE sStock.sDemandPart_ID = 0 
		  AND sPartClassification.Tool = 0
		  GROUP BY sOrderPartReceipt_ID, sOrderPartReceipt.Qty
		  HAVING SUM(sStock.Qty) = sOrderPartReceipt.Qty
		  ORDER BY sOrderPartReceipt_ID
		  OFFSET 50 ROWS FETCH NEXT 1 ROWS ONLY)