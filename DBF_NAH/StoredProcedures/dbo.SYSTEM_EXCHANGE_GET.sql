USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_EXCHANGE_GET]
	@SYS_ID	SMALLINT
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

		SELECT SYS_ID, SYS_SHORT_NAME, SYS_ORDER
		FROM dbo.SystemTable
		WHERE SYS_ID_HOST IN
			(
				SELECT SYS_ID_HOST
				FROM dbo.SystemTable
				WHERE SYS_ID = @SYS_ID
			)
		ORDER BY SYS_ORDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_EXCHANGE_GET] TO rl_subhost_calc;
GO
