USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[INCOME_DATA_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[INCOME_DATA_GET]  AS SELECT 1')
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[INCOME_DATA_GET]
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

		SELECT
			IN_ID, CL_ID, CL_FULL_NAME, IN_DATE, IN_PAY_DATE, IN_SUM, IN_PAY_NUM,
			IN_SUM -
				ISNULL
					(
						(
							SELECT SUM(ID_PRICE)
							FROM dbo.IncomeDistrTable
							WHERE ID_ID_INCOME = IN_ID
						), 0
					) AS IN_REST
		FROM
			dbo.IncomeTable a INNER JOIN
			dbo.ClientTable b ON a.IN_ID_CLIENT = b.CL_ID
		WHERE IN_ID = @incomeid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[INCOME_DATA_GET] TO rl_income_r;
GO
