USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@POS	INT,
	@MANAGER	INT,
	@PHONE	VARCHAR(100),
	@LOGIN	VARCHAR(50),
	@FULL	VARCHAR(250),
	@CITY	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE	dbo.ServiceTable
	SET ServiceName = @NAME,
		ServicePositionID = @POS,
		ManagerID = @MANAGER,
		ServicePhone = @PHONE,
		ServiceLogin = @LOGIN,
		ServiceFullName = @FULL,
		ServiceLast = GETDATE()
	WHERE ServiceID = @ID

	UPDATE dbo.ClientTable
	SET ClientLast = GETDATE()
	WHERE STATUS = 1 AND ClientServiceID = @ID

	DELETE 
	FROM dbo.ServiceCity
	WHERE ID_SERVICE = @ID
		AND ID_CITY NOT IN
			(
				SELECT a.ID
				FROM dbo.TableGUIDFromXML(@CITY) AS a
			)

	INSERT INTO dbo.ServiceCity(ID_SERVICE, ID_CITY)
		SELECT @ID, a.ID
		FROM dbo.TableGUIDFromXML(@CITY) AS a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ServiceCity
				WHERE ID_SERVICE = @ID
					AND ID_CITY = a.ID
			)
END