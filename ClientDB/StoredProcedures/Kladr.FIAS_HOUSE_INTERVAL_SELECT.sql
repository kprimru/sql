USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Kladr].[FIAS_HOUSE_INTERVAL_SELECT]
	@ID	UNIQUEIDENTIFIER,
	@RC	INT = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX)

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @SQL = N'EXEC [PC275-SQL\SIGMA].Ric.Fias.HOUSE_INTERVAL_SELECT @ID, @RC OUTPUT'

		EXEC sp_executesql @SQL, N'@ID UNIQUEIDENTIFIER, @RC INT OUTPUT', @ID, @RC OUTPUT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Kladr].[FIAS_HOUSE_INTERVAL_SELECT] TO rl_fias_r;
GO