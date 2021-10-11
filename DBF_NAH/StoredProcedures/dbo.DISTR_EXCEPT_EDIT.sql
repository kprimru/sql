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

ALTER PROCEDURE [dbo].[DISTR_EXCEPT_EDIT]
	@distrid INT,
	@systemid INT,
	@distrnum INT,
	@compnum TINYINT,
	@comment VARCHAR(250),
	@active BIT = 1
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

		UPDATE dbo.DistrExceptTable
		SET DE_ID_SYSTEM = @systemid,
			DE_DIS_NUM = @distrnum,
			DE_COMP_NUM = @compnum,
			DE_COMMENT = @comment,
			DE_ACTIVE = @active
		WHERE DE_ID = @distrid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_EDIT] TO rl_distr_except_w;
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_EDIT] TO rl_reg_node_report_r;
GO
