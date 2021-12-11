USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_TECH_PREPARE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_TECH_PREPARE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_TECH_PREPARE]
	@CLIENT	INT,
	@TEXT	VARCHAR(100) = NULL OUTPUT,
	@COLOR	INT = NULL OUTPUT
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

		SET @TEXT = NULL

		SET @COLOR = 0

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_TECH_PREPARE] TO rl_client_tech_r;
GO
