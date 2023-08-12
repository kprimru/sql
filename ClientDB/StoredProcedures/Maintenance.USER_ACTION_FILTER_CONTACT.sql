USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[USER_ACTION_FILTER_CONTACT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[USER_ACTION_FILTER_CONTACT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Maintenance].[USER_ACTION_FILTER_CONTACT]
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

		SELECT DISTINCT IsNull(E.[ID_MASTER], E.[ID]) AS [ContactID], E.[DATE], C.[ClientID], C.[ClientShortName], C.[ClientFullName], E.[UPD_DATE]
		FROM [dbo].[ClientContact] AS E
		INNER JOIN [dbo].[ClientTable] AS C ON C.[ClientID] = E.[ID_CLIENT]
		WHERE	Cast(E.[UPD_DATE] AS Date) = @Date
			AND E.[UPD_USER] = @User
		ORDER BY E.[UPD_DATE];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Maintenance].[USER_ACTION_FILTER_CONTACT] TO rl_user_action_filter;
GO
