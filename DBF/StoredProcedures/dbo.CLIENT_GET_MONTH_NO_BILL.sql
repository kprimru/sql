USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_GET_MONTH_NO_BILL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_GET_MONTH_NO_BILL]  AS SELECT 1')
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[CLIENT_GET_MONTH_NO_BILL]
	@clientid INT
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

		SELECT PR_ID, PR_DATE, PR_NAME
		FROM dbo.PeriodTable a
		WHERE PR_DATE >
				(
					SELECT MAX(b.PR_DATE)
					FROM
						dbo.PeriodTable b INNER JOIN
						dbo.BillTable c ON c.BL_ID_PERIOD = b.PR_ID
					WHERE BL_ID_CLIENT = @clientid
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_GET_MONTH_NO_BILL] TO rl_bill_r;
GO
