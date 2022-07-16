USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[CLIENT_PACE_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[CLIENT_PACE_CHECK]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[CLIENT_PACE_CHECK]
	@PARAM	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
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
			[Клиент]	= C.[ClientFullName],
			[РГ]		= C.[ManagerName],
			[СИ]		= C.[ServiceName],
			[Место К+]	= CC.[ClientPlace],
			[Дистр]		= D.[DistrStr],
			[Сеть]		= D.[DistrTypeName],
			[Дата изм]	= L.[ClientLast],
			[Изменил]	= L.[UPD_USER]
		FROM dbo.ClientView AS C WITH(NOEXPAND)
		INNER JOIN dbo.[ClientTable] AS CC ON CC.[ClientID] = C.[ClientID]
		OUTER APPLY
		(
			SELECT TOP (1) D.[DistrStr], D.[DistrTypeName]
			FROM dbo.ClientDistrView AS D WITH(NOEXPAND)
			WHERE D.[ID_CLIENT] = C.[ClientID]
				AND D.[DS_REG] = 0
			ORDER BY
				CASE
					WHEN D.[DistrTypeName] = 'сеть' THEN 1
					WHEN D.[DistrTypeName] = '1/c' THEN 2
					WHEN D.[DistrTypeName] = 'лок' THEN 3
					ELSE 4
				END,
				SystemOrder, DISTR, COMP
		) AS D
		OUTER APPLY
		(
			SELECT TOP (1) L.[ClientLast]
			FROM dbo.ClientTable AS L
			WHERE L.[ID_MASTER] = C.[ClientID]
				AND L.[ClientPlace] != CC.[ClientPlace]
			ORDER BY L.[ClientLast] DESC
		) AS LD
		OUTER APPLY
		(
			SELECT TOP (1) L.[UPD_USER], L.[ClientLast]
			FROM dbo.ClientTable AS L
			WHERE L.[ID_MASTER] = C.[ClientID]
				AND L.[ClientLast] > LD.[ClientLast]
			ORDER BY L.[ClientLast]
		) AS L
		WHERE C.[ServiceStatusID] IN (SELECT ServiceStatusId FROM dbo.ServiceStatusConnected())
		ORDER BY C.[ManagerName], C.[ServiceName], C.[ClientFullName]

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[CLIENT_PACE_CHECK] TO rl_report;
GO
