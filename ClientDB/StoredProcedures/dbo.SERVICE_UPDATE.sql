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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE	dbo.ServiceTable
		SET ServiceName = @NAME,
			ServicePositionID = @POS,
			ManagerID = @MANAGER,
			ServicePhone = @PHONE,
			ServiceLogin = @LOGIN,
			ServiceFullName = @FULL
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
				
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END