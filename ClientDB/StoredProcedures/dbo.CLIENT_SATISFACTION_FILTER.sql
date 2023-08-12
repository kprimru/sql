USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_SATISFACTION_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_SATISFACTION_FILTER]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_SATISFACTION_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@MANAGER	INT,
	@SERVICE	INT,
	@ST			VARCHAR(MAX)
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

		SELECT ManagerName, ServiceName, ClientID, CC_ID, ClientFullName, CC_DATE, STT_NAME, CS_NOTE, CC_NOTE, CC_USER
		FROM
			dbo.ClientSatisfaction
			INNER JOIN dbo.ClientCall ON CC_ID = CS_ID_CALL
			INNER JOIN dbo.SatisfactionType ON STT_ID = CS_ID_TYPE
			INNER JOIN dbo.TableGUIDFromXML(@ST) ON ID = STT_ID
			INNER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = CC_ID_CLIENT 
		WHERE (CC_DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (CC_DATE <= @END OR @END IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
			AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
		ORDER BY CC_DATE DESC, ManagerName, ServiceName, ClientFullName, STT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SATISFACTION_FILTER] TO rl_filter_satisfaction;
GO
