USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[SYSTEM_GET]
	@id INT = NULL
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

		SELECT
				SYS_ID, SYS_PREFIX, SYS_SHORT_NAME, SYS_NAME,
				SYS_REG_NAME, SYS_REPORT, SO_ID, SO_NAME, SYS_ORDER,
				HST_NAME, HST_ID, SYS_REPORT, SYS_ACTIVE, SYS_1C_CODE, SYS_1C_CODE2, SYS_COEF, SYS_IB, SYS_CALC
		FROM
			dbo.SystemTable a LEFT OUTER JOIN
			dbo.HostTable b ON a.SYS_ID_HOST = b.HST_ID LEFT OUTER JOIN
			dbo.SaleObjectTable c ON a.SYS_ID_SO = c.SO_ID
		WHERE SYS_ID = @id

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_GET] TO rl_system_d;
GRANT EXECUTE ON [dbo].[SYSTEM_GET] TO rl_system_r;
GRANT EXECUTE ON [dbo].[SYSTEM_GET] TO rl_system_w;
GO
