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

ALTER PROCEDURE [dbo].[SYSTEM_SELECT]
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

		SELECT
				SYS_ID, SYS_SHORT_NAME, SYS_NAME, SYS_REG_NAME,
				SYS_REPORT, SYS_1C_CODE, SYS_1C_CODE2, HST_ID, HST_NAME, SYS_ORDER
		FROM
			dbo.SystemTable a LEFT OUTER JOIN
			dbo.HostTable b ON a.SYS_ID_HOST = b.HST_ID
		WHERE SYS_ACTIVE = ISNULL(@active, SYS_ACTIVE)
		ORDER BY ISNULL(SYS_ORDER, 10000), SYS_SHORT_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_SELECT] TO rl_system_d;
GRANT EXECUTE ON [dbo].[SYSTEM_SELECT] TO rl_system_r;
GO
