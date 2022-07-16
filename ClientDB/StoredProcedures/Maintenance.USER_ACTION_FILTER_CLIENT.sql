USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[USER_ACTION_FILTER_CLIENT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[USER_ACTION_FILTER_CLIENT]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[USER_ACTION_FILTER_CLIENT]
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

		SELECT DISTINCT [ID_MASTER] AS [ClientID], [ClientShortName], [ClientFullName], [ClientLast]
		FROM [dbo].[ClientTable]
		WHERE Cast([ClientLast] AS Date) = @Date
			AND [UPD_USER] = @User
		ORDER BY [ClientLast];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[USER_ACTION_FILTER_CLIENT] TO rl_user_action_filter;
GO
