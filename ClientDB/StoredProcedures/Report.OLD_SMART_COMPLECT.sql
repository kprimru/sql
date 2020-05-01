USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[OLD_SMART_COMPLECT]
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

		SELECT DISTINCT
			Comment AS [Название],
			Complect AS [Комплект],
			DistrNumber AS [Дистрибутив],
			rns.DistrTypeName AS [Сеть],
			cv.ManagerName AS [Руководитель],
			cv.ServiceName AS [СИ],
			rns.SST_SHORT AS [Тип дистрибутива],
			rns.SystemBaseName AS [Система],
			CASE
				WHEN SST_SHORT IN ('ДД2', 'С.И') AND rns.SystemBaseName IN ('BBKZ', 'UBKZ')
				THEN -0.25
				WHEN SST_SHORT = 'ДЗ2' AND rns.SystemBaseName IN ('BBKZ', 'UBKZ')
				THEN -0.45
				WHEN SST_SHORT IN ('ДД2', 'С.И') AND rns.SystemBaseName IN ('UMKZ')
				THEN -0.3
				WHEN SST_SHORT IN ('ДЗ2') AND rns.SystemBaseName IN ('UMKZ')
				THEN -0.6
			END AS [Изменение веса]

		FROM
			Reg.RegNodeSearchView rns WITH(NOEXPAND)
			INNER JOIN dbo.ClientDistrView cdv WITH(NOEXPAND) ON rns.DistrNumber = cdv.DISTR
			INNER JOIN dbo.ClientView cv WITH(NOEXPAND) ON cdv.ID_CLIENT = cv.ClientID
		WHERE
			rns.DS_INDEX = 0 AND
			rns.SystemBaseName IN ('BBKZ', 'UBKZ', 'UMKZ')

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[OLD_SMART_COMPLECT] TO rl_report;
GO