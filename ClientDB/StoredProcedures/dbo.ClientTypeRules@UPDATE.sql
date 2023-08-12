USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientTypeRules@UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ClientTypeRules@UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[ClientTypeRules@UPDATE]
	@System_Id     Int,
	@DistrType_Id  Int,
	@ClientType_Id TinyInt
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

		UPDATE [dbo].[ClientTypeRules] SET
		    [ClientType_Id]     = @ClientType_Id
		WHERE   [System_Id]     = @System_Id
		    AND [DistrType_Id]  = @DistrType_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ClientTypeRules@UPDATE] TO rl_client_type_u;
GO
