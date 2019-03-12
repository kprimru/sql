USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [USR].[USR_LIST_DELETE]
	@ID NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @USR TABLE(ID UNIQUEIDENTIFIER)
	
	INSERT INTO @USR(ID)
		SELECT ID
		FROM dbo.TableGUIDFromXML(@ID)

	DELETE 
	FROM USR.USRUpdates
	WHERE UIU_ID_IB IN
		(
			SELECT UI_ID
			FROM USR.USRIB
			WHERE UI_ID_USR IN 
					(
						SELECT ID
						FROM @USR
					)
		)
	
	DELETE 
	FROM USR.USRIB
	WHERE UI_ID_USR IN 
		(
			SELECT ID
			FROM @USR
		)
	
	DELETE 
	FROM USR.USRPackage
	WHERE UP_ID_USR IN 
		(
			SELECT ID
			FROM @USR
		)

	DELETE 
	FROM USR.USRFile
	WHERE UF_ID IN 
		(
			SELECT ID
			FROM @USR
		)
END