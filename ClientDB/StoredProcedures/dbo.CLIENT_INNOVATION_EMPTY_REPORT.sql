USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_INNOVATION_EMPTY_REPORT]
	@INNOVATION	NVARCHAR(MAX) = NULL,
	@MANAGER	NVARCHAR(MAX) = NULL,
	@SERVICE	INT = NULL
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		SELECT
			ClientID, ManagerName, ServiceName, ClientFullName, c.NAME, c.START, c.FINISH,
			(
				SELECT TOP 1 UIU_DATE_S
				FROM USR.USRIBDateView WITH(NOEXPAND)
				WHERE UD_ID_CLIENT = ClientID
				ORDER BY UIU_DATE_S DESC
			) AS LAST_UPDATE
		FROM
			dbo.ClientInnovation a
			INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ID_CLIENT = ClientID
			INNER JOIN dbo.Innovation c ON c.ID = a.ID_INNOVATION
		WHERE --ID_INNOVATION = @INNOVATION
			(ID_INNOVATION IN (SELECT ID FROM dbo.TableGUIDFromXML(@INNOVATION)) OR @INNOVATION IS NULL)
			AND (ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientInnovationPersonal b
					WHERE b.ID_INNOVATION = a.ID
				)
		ORDER BY ManagerName, ServiceName, NAME, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GRANT EXECUTE ON [dbo].[CLIENT_INNOVATION_EMPTY_REPORT] TO rl_innovation_report;
GO