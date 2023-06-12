USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DBF_MERGE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DBF_MERGE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DBF_MERGE]
	@DataBase	VarCHar(100)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Error			VarChar(Max);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Error = ''

		IF @DataBase NOT IN ('USS', 'NAH')
			SET @Error = 'Неизвестная система "' + @DataBase + '"';

		IF @ERROR <> ''
		BEGIN
			RAISERROR (@ERROR, 16, 1)

			RETURN
		END

		IF @DataBase = 'NAH'
			EXEC [dbo].[DBF_MERGE_NAH];
		ELSE IF @DataBase = 'USS'
			EXEC [dbo].[DBF_MERGE_USS];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DBF_MERGE] TO rl_dbf_merge;
GO
