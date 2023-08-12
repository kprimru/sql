USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[GROUP_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[GROUP_SELECT]  AS SELECT 1')
GO

CREATE OR ALTER PROCEDURE [USR].[GROUP_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

		SELECT [Id], [Code], [Name]
		FROM [USR].[Groups]
		WHERE @FILTER IS NULL
			OR [Code] LIKE @FILTER
			OR [Name] LIKE @FILTER
		ORDER BY [SortIndex]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[GROUP_SELECT] TO rl_usr_group_r;
GO
