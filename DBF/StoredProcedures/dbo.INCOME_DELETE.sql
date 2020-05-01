USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			Денисов Алексей
Описание:		
*/

ALTER PROCEDURE [dbo].[INCOME_DELETE]
	@inid INT

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
	
		DELETE 
		FROM dbo.SaldoTable
		WHERE SL_ID_IN_DIS IN 
				(
					SELECT ID_ID 
					FROM dbo.IncomeDistrTable 
					WHERE ID_ID_INCOME = @inid
				)

		DELETE 
		FROM dbo.IncomeDistrTable
		WHERE ID_ID_INCOME = @inid

		DELETE 
		FROM dbo.IncomeTable
		WHERE IN_ID = @inid
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[INCOME_DELETE] TO rl_income_d;
GO