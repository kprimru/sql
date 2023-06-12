USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[USER_ACTION_FILTER_EVENT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[USER_ACTION_FILTER_EVENT]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[USER_ACTION_FILTER_EVENT]
	@User		VarChar(128),
	@Date		SmallDateTime
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

		SELECT DISTINCT E.[MasterID] AS [EventID], E.[EventDate], C.[ClientID], C.[ClientShortName], C.[ClientFullName], E.[EventLastUpdate]
		FROM [dbo].[EventTable] AS E
		INNER JOIN [dbo].[ClientTable] AS C ON C.[ClientID] = E.[ClientID]
		WHERE	Cast(E.[EventLastUpdate] AS Date) = @Date
			AND E.[EventLastUpdateUser] = @User
		ORDER BY E.[EventLastUpdate];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[USER_ACTION_FILTER_EVENT] TO rl_user_action_filter;
GO
