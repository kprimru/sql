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

ALTER PROCEDURE [dbo].[CLIENT_BILL_GET_UNPAY_MONTH]
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @prid INT
	DECLARE @prname VARCHAR(50)

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		IF @prid IS NULL
			SELECT @prid = PR_ID, @prname = PR_NAME
			FROM dbo.PeriodTable a
			WHERE PR_DATE =
				(
					SELECT MIN(PR_DATE)
					FROM
						dbo.PeriodTable b INNER JOIN
						dbo.DistrFinancingTable c ON c.DF_ID_PERIOD = b.PR_ID INNER JOIN
						dbo.ClientDistrTable d ON d.CD_ID_DISTR = c.DF_ID_DISTR
					WHERE CD_ID_CLIENT = @clientid
				)

		SELECT @prid AS PR_ID, @prname AS PR_NAME

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_BILL_GET_UNPAY_MONTH] TO rl_bill_r;
GO
