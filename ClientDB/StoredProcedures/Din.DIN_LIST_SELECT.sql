USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Din].[DIN_LIST_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Din].[DIN_LIST_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Din].[DIN_LIST_SELECT]
	@ID	NVARCHAR(MAX)
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

		SELECT DF_DIN, DF_FILE
		FROM
			Din.DinFiles
			INNER JOIN dbo.TableIDFromXML(@ID) ON ID = DF_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[DIN_LIST_SELECT] TO rl_din_r;
GO
