
/* REQUIRES RUNING INDIVIDUALLY AND TESTING 

NOT SET UP TO RUN EVERYTHING AT ONCE, YET */


---Update aCompany-----
SELECT * FROM aCompany


  BEGIN TRAN 
  UPDATE aCompany
  SET CompanyName ='Rusada Aviation', TaxRegNo ='123 4567 89', Code='RAL'
  WHERE ID = 1 

  SELECT CompanyName,TaxRegNo,Code, * FROM aCompany

  ROLLBACK

  SELECT EmployeeNo,Surname,ShortDisplayName,Email,*
  FROM lEmployee

  -----Update lEmployee---------
   BEGIN TRAN 

  UPDATE lEmployee
  SET EmployeeNo =  FORMAT(ID, 'RAL0000')

  UPDATE lEmployee
  SET Surname = SUBSTRING(Surname, 1,1)

  UPDATE uRALUser
  SET Surname = SUBSTRING(Surname, 1,1)


  UPDATE uRALUser
  SET UserEmail = FirstName+'.'+Surname+'@RusadaAviation.Com'
  

  UPDATE lEmployee
  SET EmployeeRemarks =''


  Update lEmployee
  SET Mobile =  FORMAT(ID, '07 555 000')

  UPDATE lEmployee 
  SET Tel= ''

  UPDATE lEmployee
  SET Fax =''

    SELECT EmployeeNo,Surname,ShortDisplayName,Email,*
  FROM lEmployee

  ROLLBACK 


 
---------Update sOrder and Treg------


----Run First to Amend desciription----------------


BEGIN TRAN 
UPDATE sOrder
SET Description = REPLACE(S.Description,S.Reg collate Latin1_General_BIN,'')
FROM sOrder S
WHERE  S.Description collate Latin1_General_CS_AS LIKE CONCAT('%',  S.Reg ,'%')
AND Reg >= '1'

SELECT Description,*
FROM sOrder

ROLLBACK


-----------------


  BEGIN TRAN


    UPDATE tReg
SET tReg.Reg = tmp.Reg
FROM tReg
JOIN (
	SELECT tReg.ID, 'G-RA' + CAST(ROW_NUMBER() OVER (ORDER BY ID) AS Varchar(10)) Reg
	FROM tReg
) tmp ON tmp.ID = tReg.ID


  UPDATE sOrder
SET sOrder.Reg = tmp.Reg
FROM sOrder
JOIN (
	SELECT tReg.ID, 'G-RA' + CAST(ROW_NUMBER() OVER (ORDER BY ID) AS Varchar(10)) Reg
	FROM tReg
) tmp ON tmp.ID = sOrder.tReg_ID


UPDATE tReg
SET Operator = 'Rusada Aviation'


SELECT TOP  100 sOrder.Reg,tReg_ID, * 
FROM sOrder

SELECT TOP 100 Reg,ID,*
FROM tReg	

ROLLBACK


 ----sVendor-----

 BEGIN TRAN

 UPDATE sVendorOrder
 SET ShippingAddress = 'Rusada Avaition 1 Rusada House Rusada Lane Adderbury'

 ROLLBACK


 -----SOrderRange-------


BEGIN TRAN 
UPDATE SO
SET SO.OrderNo=SUBSTRING(TR.Reg,3,4) COLLATE Latin1_General_CS_AS + SUBSTRING(SO.OrderNo,4,7)
FROM sOrder SO
LEFT JOIN sOrderRange SR ON SO.sOrderRange_ID=SR.ID
LEFT JOIN tReg TR ON SR.tReg_IDDefault=TR.ID
WHERE TR.Reg IS NOT NULL 


SELECT SO.OrderNo,SR.OrderPrefix,SR.OrderNoDigits,TR.Reg, 

 *
FROM sOrder SO
LEFT JOIN sOrderRange SR ON SO.sOrderRange_ID=SR.ID
LEFT JOIN tReg TR ON SR.tReg_IDDefault=TR.ID
WHERE TR.Reg IS NOT NULL 
ROLLBACK


 BEGIN TRAN 
 UPDATE SR
 SET SR.OrderPrefix = SUBSTRING(TR.Reg,3,4),
 SR.LastOrderNo = SUBSTRING(TR.Reg,3,4) COLLATE Latin1_General_BIN + SUBSTRING(SR.LastOrderNo,4,6)
FROM sOrder SO
LEFT JOIN sOrderRange SR ON SO.sOrderRange_ID=SR.ID
LEFT JOIN tReg TR ON SR.tReg_IDDefault=TR.ID
WHERE TR.Reg IS NOT NULL 


UPDATE SR
SET Description = OrderPrefix + ' Maintenance'
FROM sOrderRange SR LEFT JOIN tReg TR ON SR.tReg_IDDefault=TR.ID
WHERE TR.Reg IS NOT NULL 

SELECT SR.Description,  SR.OrderPrefix,SR.OrderNoDigits, TR.Reg, SR.LastOrderNo, SUBSTRING(TR.Reg,3,4), *
FROM sOrderRange SR LEFT JOIN tReg TR ON SR.tReg_IDDefault=TR.ID
WHERE TR.Reg IS NOT NULL 

UPDATE sOrderStatus
SET Description = 'Closed'
WHERE DefaultClosed = 1

/* Addresses */

UPDATE aAddress
SET AddressCode = 'RAL/001',
Name = 'Rusada Aviation',
Address1 = 'Rusada House',
Address2 = 'Adderbury',
Address3 = '',
Country = 'United Kingdom',
Telephone = '',
Fax = '',EMail = 'support@rusada.com'
FROM aAddress WHERE ID IN (
SELECT aAddress_IDCompany
FROM aCompany)

UPDATE uRALMenu
SET NodeText = REPLACE(NodeText, '&', '&&')
FROM uRALMenu
WHERE NodeText LIKE '%[&]%'

UPDATE aAddress
SET AddressCode = REPLACE(AddressCode, 'SUN-AIR', 'RUSADA')
WHERE AddressCode LIKE '%SUN-AIR%'

UPDATE aAddress
SET Name = REPLACE(Name, 'Sun-Air of Scandinavia A/S', 'Rusada')
WHERE Name LIKE '%Sun-Air%'

SELECT ID, *
FROM aAddress
WHERE ID IN (1 ,11630 ,14380)

ROLLBACK



/* Company Accounts */

BEGIN TRAN

UPDATE uRALRight
SET SecVar = REPLACE(SecVar, 'SUN AIR', 'RAL')
FROM uRALRight WHERE ID IN ( 1856, 1855, 1857, 2740, 2739)

SELECT * FROM uRALRight WHERE ID IN ( 1856, 1855, 1857, 2740, 2739)

ROLLBACK