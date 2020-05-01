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

ALTER PROCEDURE [dbo].[SUBHOST_GET]
	@subhostid SMALLINT = NULL
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
				SH_ID, SH_FULL_NAME, SH_SHORT_NAME, SH_SUBHOST, SH_LST_NAME,
				SH_REG, SH_CALC_STUDY, SH_CALC_SYSTEM, SH_ORDER, SH_CALC, SH_PENALTY, SH_PERIODICITY, SH_ACTIVE
		FROM
			dbo.SubhostTable a
		WHERE SH_ID = @subhostid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[SUBHOST_GET] TO rl_subhost_r;
GO