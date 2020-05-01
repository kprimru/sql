USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[INCOME_CONVEY_DISTR]
	@incomeid INT,
	@distrid INT,
	@incomedate SMALLDATETIME,
	@price MONEY,
	@periodid SMALLINT,
	@prepay BIT,
	@action BIT = 0
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

		INSERT INTO dbo.IncomeDistrTable(ID_ID_INCOME, ID_ID_DISTR, ID_PRICE, ID_DATE, ID_ID_PERIOD, ID_PREPAY, ID_ACTION)
			SELECT @incomeid, @distrid, @price, @incomedate, @periodid, @prepay, @action

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[INCOME_CONVEY_DISTR] TO rl_income_w;
GO