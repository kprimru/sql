USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[DISTR_EXCEPT_SELECT]
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

		SELECT DE_ID, SYS_SHORT_NAME, DE_DIS_NUM, DE_COMP_NUM, DE_COMMENT
		FROM
			dbo.DistrExceptTable INNER JOIN
			dbo.SystemTable ON SYS_ID = DE_ID_SYSTEM
		WHERE DE_ACTIVE = ISNULL(@active, DE_ACTIVE)
		ORDER BY SYS_ORDER, DE_DIS_NUM, DE_COMP_NUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_SELECT] TO rl_distr_except_r;
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_SELECT] TO rl_reg_node_report_r;
GO
