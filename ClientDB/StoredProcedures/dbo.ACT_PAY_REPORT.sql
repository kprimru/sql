USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_PAY_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_PAY_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_PAY_REPORT]
	@PERIOD		UNIQUEIDENTIFIER,
	@MANAGER	INT,
	@SERVICE	INT
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

		IF @SERVICE IS NOT NULl
			SET @MANAGER = NULL

		DECLARE @PR_DATE SMALLDATETIME

		SELECT @PR_DATE = START
		FROM Common.Period
		WHERE ID = @PERIOD

		SELECT ClientID, ClientFulLName, ServiceName, ManagerName, DistrStr, d.NAME
		FROM
			(
				SELECT a.SYS_REG_NAME, a.DIS_NUM, a.DIS_COMP_NUM, a.PR_DATE
				FROM
					dbo.DBFIncomeView a
					INNER JOIN dbo.DBFBillView b ON a.SYS_REG_NAME = b.SYS_REG_NAME
												AND a.DIS_NUM = b.DIS_NUM
												AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
												AND a.PR_DATE = b.PR_DATE
				WHERE a.PR_DATE <= @PR_DATE
					AND a.PR_DATE >= DATEADD(YEAR, -1, @PR_DATE)
					AND a.ID_PRICE = b.BD_TOTAL_PRICE
					AND a.SYS_REG_NAME <> '-'
					AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DBFActView z
						WHERE a.SYS_REG_NAME = z.SYS_REG_NAME
							AND a.DIS_NUM = z.DIS_NUM
							AND a.DIS_COMP_NUM = z.DIS_COMP_NUM
							AND a.PR_DATE = z.PR_DATE
					)
			) AS a
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.SYS_REG_NAME = b.SystemBaseName
															AND a.DIS_NUM = b.DISTR
															AND a.DIS_COMP_NUM = b.COMP
			INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.ClientID
			INNER JOIN Common.Period d ON d.START = a.PR_DATE AND d.TYPE = 2
		WHERE (ServiceID = @SERVICE OR @SERVICE IS NULL)
			AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		ORDER BY ManagerName, ServiceName, ClientFullName, d.START, SystemOrder, DISTR, COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_PAY_REPORT] TO public;
GO
