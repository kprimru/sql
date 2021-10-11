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

ALTER PROCEDURE [dbo].[DISTR_EXCEPT_ADD]
	@systemid INT,
	@distrnum INT,
	@compnum TINYINT,
	@comment VARCHAR(250),
	@active BIT = 1,
	@returnvalue BIT = 1
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

		DECLARE @distrid INT

		INSERT INTO dbo.DistrExceptTable (DE_ID_SYSTEM, DE_DIS_NUM, DE_COMP_NUM, DE_COMMENT, DE_ACTIVE)
		VALUES (@systemid, @distrnum, @compnum, @comment, @active)

		SELECT @distrid = SCOPE_IDENTITY()

		IF @returnvalue = 1
			SELECT @distrid AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_ADD] TO rl_distr_except_w;
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_ADD] TO rl_reg_node_report_r;
GO
