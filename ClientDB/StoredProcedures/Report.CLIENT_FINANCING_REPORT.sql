USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[CLIENT_FINANCING_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[CLIENT_FINANCING_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[CLIENT_FINANCING_REPORT]
	@PARAM	NVARCHAR(MAX) = NULL
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
			ClientFullName AS 'Клиент', b.Name AS 'Тип клиента',
			CASE
				WHEN EXISTS
					(
						SELECT *
						FROM
							dbo.ClientDistrView z
							INNER JOIN dbo.DBFDistrFinancingView y ON z.SystemBaseName = y.SYS_REG_NAME AND z.DISTR = y.DIS_NUM AND z.COMP = y.DIS_COMP_NUM
						WHERE z.ID_CLIENT = ClientID AND z.DS_REG = 0 AND DF_FIXED_PRICE <> 0
					) THEN 'Фикс.сумма'
				WHEN EXISTS
					(
						SELECT *
						FROM
							dbo.ClientDistrView z
							INNER JOIN dbo.DBFDistrFinancingView y ON z.SystemBaseName = y.SYS_REG_NAME AND z.DISTR = y.DIS_NUM AND z.COMP = y.DIS_COMP_NUM
						WHERE z.ID_CLIENT = ClientID AND z.DS_REG = 0 AND DF_DISCOUNT <> 0
					) THEN 'Скидка'
				ELSE 'Прейскурант'
			END AS 'Условия'
		FROM
			dbo.ClientTable a
			INNER JOIN [dbo].[ServiceStatusConnected]() s ON a.StatusId = s.ServiceStatusId
			INNER JOIN dbo.ClientKind b ON a.ClientKind_Id = b.Id
		WHERE a.STATUS = 1
		ORDER BY ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[CLIENT_FINANCING_REPORT] TO rl_report;
GO
