USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INCOME_UNCONVEY_FULL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INCOME_UNCONVEY_FULL]  AS SELECT 1')
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[INCOME_UNCONVEY_FULL]
	@incomeid INT
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

		DELETE FROM dbo.SaldoTable
		WHERE SL_ID_IN_DIS IN (SELECT ID_ID FROM dbo.IncomeDistrTable WHERE ID_ID_INCOME = @incomeid)

		DELETE FROM dbo.IncomeDistrTable
		WHERE ID_ID_INCOME = @incomeid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INCOME_UNCONVEY_FULL] TO rl_income_w;
GO
