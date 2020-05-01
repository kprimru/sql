USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_SERVICE_DELIVERY]
	@CLIENT		NVARCHAR(MAX),
	@SERVICE	INT,
	@DATE		SMALLDATETIME
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

		DECLARE @CLIENT_W	NVARCHAR(MAX)

		SET @CLIENT_W = dbo.ClientFilterWrite(@CLIENT)

		UPDATE dbo.ClientService
		SET STATUS = 2
		WHERE STATUS = 1
			AND ID_CLIENT IN
				(
					SELECT ID
					FROM dbo.TableIDFromXML(@CLIENT_W)
				)
			AND ID_SERVICE <> @SERVICE

		DECLARE @MANAGER VARCHAR(100)

		SELECT @MANAGER = ManagerName
		FROM
			dbo.ServiceTable a
			INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
		WHERE ServiceID = @SERVICE

		INSERT INTO dbo.ClientService(ID_CLIENT, ID_SERVICE, DATE, MANAGER)
			SELECT ID, @SERVICE, @DATE, @MANAGER
			FROM dbo.TableIDFromXML(@CLIENT_W) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientService
					WHERE STATUS = 1
						AND a.ID = ID_CLIENT
				)

		UPDATE dbo.ClientTable
		SET ClientServiceID = @SERVICE
		WHERE ClientID IN
			(
				SELECT ID
				FROM dbo.TableIDFromXML(@CLIENT_W)
			) AND ClientServiceID <> @SERVICE

		EXEC dbo.CLIENT_REINDEX NULL, @CLIENT_W

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_SERVICE_DELIVERY] TO rl_client_service_delivery;
GO