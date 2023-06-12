USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[NDS_1C_DEFAULT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[NDS_1C_DEFAULT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[NDS_1C_DEFAULT]
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

		SELECT ORG_ID, ORG_PSEDO, TX_ID, TX_CAPTION, PR_ID, PR_NAME
		FROM
			(
				SELECT TOP 1 ORG_ID, ORG_PSEDO
				FROM dbo.OrganizationTable
				ORDER BY ORG_ID
			) AS a
			CROSS JOIN
			(
				SELECT TOP 1 TX_ID, TX_CAPTION
				FROM dbo.TaxTable
				WHERE TX_PERCENT = 18
			) AS b
			CROSS JOIN
			(
				SELECT TOP 1 PR_ID, PR_NAME
				FROM
					(
						SELECT TOP 1 1 AS TP, PR_ID, PR_NAME, PR_DATE
						FROM dbo.PeriodTable
						WHERE DATEADD(MONTH, -1, GETDATE()) BETWEEN PR_DATE AND PR_END_DATE

						UNION ALL

						SELECT TOP 1 0 AS TP, PR_ID, PR_NAME, PR_DATE
						FROM
							dbo.PeriodTable a
							INNER JOIN dbo.NDS1C b ON a.PR_ID = b.ID_PERIOD
						ORDER BY PR_DATE DESC
					) AS o_O
			) AS c

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[NDS_1C_DEFAULT] TO rl_book_sale_p;
GO
