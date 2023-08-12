USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_ERROR_FILTER]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_ERROR_FILTER]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [dbo].[CLIENT_ERROR_FILTER]
	@DateFrom	SmallDateTime	= NULL,
	@DateTo		SmallDateTime	= NULL,
	@Note		VarChar(100)	= NULL
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
		SET @Note = '%' + NullIf(@Note, '') + '%';

		SELECT C.[ClientID], C.[ServiceStatusIndex], C.[ClientFullName], C.[ManagerName], C.[ServiceName], E.[NOTE], E.[UPD_DATE]
		FROM [dbo].[ClientError] AS E
		INNER JOIN [dbo].[ClientView] AS C WITH(NOEXPAND) ON E.[ID_CLIENT] = C.ClientID
		WHERE (E.[NOTE] LIKE @Note OR @Note IS NULL)
			AND (E.[UPD_DATE] >= @DateFrom OR @DateFrom IS NULL)
			AND (E.[UPD_DATE] <= @DateTo OR @DateTo IS NULL)
			AND E.[STATUS] = 1
		ORDER BY UPD_DATE DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_ERROR_FILTER] TO rl_client_error_r;
GO
