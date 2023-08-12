USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[CLIENT_COMPLECT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[CLIENT_COMPLECT_SELECT]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [USR].[CLIENT_COMPLECT_SELECT]
	@CLIENT	INT
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

		SELECT dbo.DistrString(s.SystemShortName, f.UD_DISTR, f.UD_COMP) AS UD_NAME, UD_ID
		FROM USR.USRActiveView f
		INNER JOIN dbo.SystemTable s ON s.SystemID = f.UF_ID_SYSTEM
		WHERE UD_ID_CLIENT = @CLIENT AND UD_ACTIVE = 1
		ORDER BY UD_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[CLIENT_COMPLECT_SELECT] TO rl_client_od_ud_graph;
GO
