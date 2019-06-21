

BEGIN TRAN

SELECT *
FROM lEmployee
ORDER BY ID desc
----------------------------------------------------------------------------------------------------------------------------
/*****************************       CREATE NEW EMPLOYEE  *****************************************************************/
----------------------------------------------------------------------------------------------------------------------------

--Highlight value and right click Change all occurences, then enter new value (Only works in Data Studio)
DECLARE @FirstName nvarchar(20) = 'EnterFirstName'
DECLARE @Surname nvarchar(20) = 'EnterSurname'
DECLARE @ShortName nvarchar(20) = @Surname + ' '+ LEFT(@FirstName,1)
DECLARE @EmployeeUsername nvarchar(100) = 'EnterUsername'
DECLARE @EmployeePassword nvarchar(48) = 'cvesjf474kmEoNbPg2CTkw==' ---Default is ngen
DECLARE @EmployeeNo nvarchar(20) = 'EnterEmployeeNo'
DECLARE @RARole nvarchar(50) = 'EnterAdminRole'

IF NOT EXISTS(SELECT TOP 1 ID FROM lEmployee where EmployeeUsername = @EmployeeUsername)
BEGIN
	
INSERT INTO lEmployee
(
	lEmployeeRange_ID,
	uRALBase_ID,
	Title,
	Gender,
	FirstName,
	Surname,
	ShortDisplayName,
	EmployeeNo,
	EmployeeUsername,
	EmployeePassword
)
VALUES 
(
	(select TOP 1 ID from lEmployeeRange where IsEngineer = 1),
	(SELECT TOP 1 ID FROM uRALBase),
	'Mr',
	'M',
	@FirstName,
	@Surname,
	@ShortName,
	@FirstName,
	@EmployeeUsername,
	@EmployeePassword
)
END


GO

----------------------------------------------------------------------------------------------------------------------------
/*****************************       ASSIGN ROLE TO EMPLOYEE  *************************************************************/
----------------------------------------------------------------------------------------------------------------------------
DECLARE @EmployeeUsername nvarchar(100) = 'EnterUsername'
DECLARE @RARole nvarchar(50) = 'EnterAdminRole'
DECLARE @roleId INT = 0;
SET @roleId = (SELECT TOP 1 ID FROM uRole where Code = @RARole)

DECLARE @EmployeeID INT = 0;
SET @EmployeeID = (SELECT TOP 1 ID FROM lEmployee where EmployeeUsername = @EmployeeUsername)

INSERT INTO lEmployeeRole(lEmployee_ID, uRole_ID, IsDefault)
VALUES(@EmployeeID, @roleId, 1)

GO

----------------------------------------------------------------------------------------------------------------------------
/*****************************       CREATE USER TO EMPLOYEE  *************************************************************/
----------------------------------------------------------------------------------------------------------------------------
DECLARE @FirstName nvarchar(20) = 'EnterFirstName'
DECLARE @Surname nvarchar(20) = 'EnterSurname'
DECLARE @EmployeeUsername nvarchar(100) = 'EnterUsername'
DECLARE @EmployeePassword nvarchar(48) = 'cvesjf474kmEoNbPg2CTkw=='
DECLARE @EmployeeID INT = 0;
SET @EmployeeID = (SELECT TOP 1 ID FROM lEmployee where EmployeeUsername = @EmployeeUsername)

IF NOT EXISTS(SELECT TOP 1 ID FROM uRALUser where RALUser = @EmployeeUsername)
BEGIN
	INSERT INTO uRALUser
	(
	lEmployee_ID,
	RALUser,
	Password, 
	FirstName, 
	Surname,
	RalAdmin,
	uRALUserTypeLicense_ID)
	VALUES(
	@EmployeeID,
	@EmployeeUsername,
	@EmployeePassword,
	@FirstName,
	@Surname,
	1,
	1)

END

IF EXISTS(SELECT TOP 1 ID FROM uRALUser where RALUser = @EmployeeUsername)
BEGIN
	UPDATE uRALUser set lEmployee_ID = @EmployeeID where RALUser = @EmployeeUsername
END

GO

----------------------------------------------------------------------------------------------------------------------------
/*****************************       SET DEFAULT ROLE       *****************************************************************/
----------------------------------------------------------------------------------------------------------------------------
DECLARE @RARole nvarchar(50) = 'EnterAdminRole'
DECLARE @roleID INT = 0
SET @roleID = (SELECT TOP 1 ID FROM uRole where Code = @RARole)

----------------------------------------------------------------------------------------------------------------------------
/*****************************       EDIT ROLE WORKFLOW   *****************************************************************/
----------------------------------------------------------------------------------------------------------------------------
DECLARE @editRoleWorkFlow INT = 0
SET @editRoleWorkFlow = (SELECT TOP 1 ID FROM wWorkFlow WHERE Code = 'EDITROLE')

IF EXISTS(SELECT TOP 1 ID FROM uRoleComponent where uRole_ID = @roleID AND wWorkFlow_ID = @editRoleWorkFlow)
BEGIN
	Delete from uRoleComponent WHERE uRole_ID = @roleID AND wWorkFlow_ID = @editRoleWorkFlow
END

Declare @ROLEDETAILS INT = 0;
SET @ROLEDETAILS = (SELECT TOP 1 ID FROM wComponent where Code = 	'ROLEDETAILS')

Declare @ROLECOMPONENTRIGHTS INT = 0;
SET @ROLECOMPONENTRIGHTS = (SELECT TOP 1 ID FROM wComponent where Code = 	'ROLECOMPONENTRIGHTS')

Declare @ROLEWIDGETRIGHTS INT = 0;
SET @ROLEWIDGETRIGHTS = (SELECT TOP 1 ID FROM wComponent where Code = 	'ROLEWIDGETRIGHTS')

Declare @ROLEEMPLOYEELIST INT = 0;
SET @ROLEEMPLOYEELIST = (SELECT TOP 1 ID FROM wComponent where Code = 	'ROLEEMPLOYEELIST')

Declare @ROLEEMPLOYEEFILTER INT = 0;
SET @ROLEEMPLOYEEFILTER = (SELECT TOP 1 ID FROM wComponent where Code = 	'ROLEEMPLOYEEFILTER')

Declare @ROLEUSERRIGHTS INT = 0;
SET @ROLEUSERRIGHTS = (SELECT TOP 1 ID FROM wComponent where Code = 	'ROLEUSERRIGHTS')

Declare @ROLEEMPLOYEEUSERRIGHT INT = 0;
SET @ROLEEMPLOYEEUSERRIGHT = (SELECT TOP 1 ID FROM wComponent where Code = 	'ROLEEMPLOYEEUSERRIGHT')

Declare @ROLEUSERRIGHTCONTEXT INT = 0;
SET @ROLEUSERRIGHTCONTEXT = (SELECT TOP 1 ID FROM wComponent where Code = 	'ROLEUSERRIGHTCONTEXT')


INSERT INTO uRoleComponent(uRole_ID,wWorkFlow_ID,wComponent_ID,CanRead,CanWrite) VALUES (@roleID, @editRoleWorkFlow, @ROLEDETAILS, 1, 1)
INSERT INTO uRoleComponent(uRole_ID,wWorkFlow_ID,wComponent_ID,CanRead,CanWrite) VALUES (@roleID, @editRoleWorkFlow, @ROLECOMPONENTRIGHTS, 1, 1)
INSERT INTO uRoleComponent(uRole_ID,wWorkFlow_ID,wComponent_ID,CanRead,CanWrite) VALUES (@roleID, @editRoleWorkFlow, @ROLEWIDGETRIGHTS, 1, 1)
INSERT INTO uRoleComponent(uRole_ID,wWorkFlow_ID,wComponent_ID,CanRead,CanWrite) VALUES (@roleID, @editRoleWorkFlow, @ROLEEMPLOYEELIST, 1, 1)
INSERT INTO uRoleComponent(uRole_ID,wWorkFlow_ID,wComponent_ID,CanRead,CanWrite) VALUES (@roleID, @editRoleWorkFlow, @ROLEEMPLOYEEFILTER, 1, 1)
INSERT INTO uRoleComponent(uRole_ID,wWorkFlow_ID,wComponent_ID,CanRead,CanWrite) VALUES (@roleID, @editRoleWorkFlow, @ROLEUSERRIGHTS, 1, 1)
INSERT INTO uRoleComponent(uRole_ID,wWorkFlow_ID,wComponent_ID,CanRead,CanWrite) VALUES (@roleID, @editRoleWorkFlow, @ROLEEMPLOYEEUSERRIGHT, 1, 1)
INSERT INTO uRoleComponent(uRole_ID,wWorkFlow_ID,wComponent_ID,CanRead,CanWrite) VALUES (@roleID, @editRoleWorkFlow, @ROLEUSERRIGHTCONTEXT, 1, 1)

SELECT *
FROM lEmployee
ORDER BY ID desc

ROLLBACK