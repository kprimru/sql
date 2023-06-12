USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DISTR_CHECK_DISTR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[DISTR_CHECK_DISTR]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[DISTR_CHECK_DISTR]
	@SYS_ID	SMALLINT,
	@DISTR	INT,
	@COMP	TINYINT
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

		SELECT DIS_ID
		FROM dbo.DistrTable
		WHERE DIS_ID_SYSTEM = @SYS_ID
			AND DIS_NUM = @DISTR
			AND DIS_COMP_NUM = @COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_CHECK_DISTR] TO rl_distr_w;
GO
