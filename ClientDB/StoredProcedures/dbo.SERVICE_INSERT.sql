USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_INSERT]
	@NAME	VARCHAR(100),
	@POS	INT,
	@MANAGER	INT,
	@PHONE	VARCHAR(100),
	@LOGIN	VARCHAR(50),
	@FULL	VARCHAR(250),
	@CITY	NVARCHAR(MAX),
	@ID	INT = NULL OUTPUT
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

		INSERT INTO	dbo.ServiceTable(ServiceName, ServicePositionID, ManagerID, ServicePhone,
					ServiceLogin, ServiceFullName, ServiceFirst)
			VALUES(@NAME, @POS, @MANAGER, @PHONE, @LOGIN, @FULL, GETDATE())

		SELECT @ID = SCOPE_IDENTITY()

		INSERT INTO dbo.ServiceCity(ID_SERVICE, ID_CITY)
			SELECT @ID, ID
			FROM dbo.TableGUIDFromXML(@CITY)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_INSERT] TO rl_personal_service_i;
GO
