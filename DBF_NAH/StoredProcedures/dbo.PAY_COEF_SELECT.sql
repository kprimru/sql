USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PAY_COEF_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PAY_COEF_SELECT]  AS SELECT 1')
GO


/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[PAY_COEF_SELECT]
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

		SELECT PC_START, PC_END, PC_VALUE, PC_ID
		FROM dbo.PayCoefTable
		WHERE PC_ACTIVE = ISNULL(@active, PC_ACTIVE)
		ORDER BY PC_START

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PAY_COEF_SELECT] TO rl_pay_coef_r;
GO
