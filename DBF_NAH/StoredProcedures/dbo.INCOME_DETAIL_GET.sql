USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[INCOME_DETAIL_GET]
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

		SELECT ID_ID, PR_DATE, DIS_ID, DIS_STR, ID_PRICE, ID_PREPAY, ACT_DATE, ACT_ID, ID_ACTION
		FROM
			dbo.IncomeDistrTable a INNER JOIN
			dbo.IncomeTable ON IN_ID = ID_ID_INCOME INNER JOIN
			dbo.DistrView b WITH(NOEXPAND) ON a.ID_ID_DISTR = b.DIS_ID INNER JOIN
			dbo.PeriodTable ON PR_ID = ID_ID_PERIOD LEFT OUTER JOIN
			dbo.ActDistrTable ON AD_ID_DISTR = ID_ID_DISTR AND AD_ID_PERIOD = ID_ID_PERIOD LEFT OUTER JOIN
			dbo.ActTable ON ACT_ID = AD_ID_ACT AND ACT_ID_CLIENT = IN_ID_CLIENT
		WHERE ID_ID_INCOME = @incomeid
		ORDER BY DIS_STR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[INCOME_DETAIL_GET] TO rl_income_r;
GO