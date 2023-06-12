USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TO_MAIN_CHANGE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TO_MAIN_CHANGE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[TO_MAIN_CHANGE]
	@TO_Id		Int
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

		UPDATE dbo.TOTable SET
			TO_MAIN = CASE TO_MAIN WHEN 0 THEN 1 ELSE 0 END
		WHERE TO_ID = @TO_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TO_MAIN_CHANGE] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_MAIN_CHANGE] TO rl_to_w;
GO
