USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[QUARTER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[QUARTER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[QUARTER_SELECT]
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT QR_ID, QR_NAME, QR_BEGIN, QR_END
		FROM dbo.Quarter
		WHERE QR_ACTIVE = ISNULL(@active, QR_ACTIVE)
		ORDER BY QR_BEGIN DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[QUARTER_SELECT] TO rl_quarter_r;
GO
