USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[HOTLINE_DETAIL]
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
				ManagerName AS [Рук-ль], ServiceName AS [СИ], ClientName AS [Клиент], a.DistrStr AS [Дистрибутив], a.NT_SHORT AS [Сеть], a.SST_SHORT AS [Тип],
				(
					SELECT SET_DATE
					FROM dbo.HotlineDistr b
					WHERE a.HostID = b.ID_HOST
						AND a.DistrNumber = b.DISTR
						AND a.CompNumber = b.COMP
						AND STATUS = 1
				) AS [Дата подключения к чату],

				dbo.DateOf((
							SELECT	MAX(RPR_DATE)
							FROM	dbo.RegProtocol
							WHERE	RPR_ID_HOST = a.HostId
									AND RPR_DISTR = a.DistrNumber
									AND RPR_COMP = a.CompNumber
									AND (RPR_OPER LIKE '%Перв%'
									OR RPR_OPER LIKE '%НОВАЯ%'
									OR RPR_OPER LIKE '%Включение%'
									OR RPR_OPER LIKE '%Изм%')
				)) AS [Дата регистрации],

				dbo.DateOf(
				(
					SELECT MAX(FIRST_DATE)
					FROM
						dbo.HotlineChat z
						INNER JOIN dbo.SystemTable y ON z.SYS = y.SystemNumber
					WHERE z.DISTR = a.DistrNumber AND z.COMP = a.CompNumber AND y.HostID = a.HostID
				)) AS [Последний сеанс чата]
			FROM dbo.RegNodeComplectClientView a
			LEFT JOIN dbo.ClientTable c ON c.ClientID = a.ClientID
			--LEFT OUTER JOIN  ON d.RPR_DISTR = a.DistrNumber AND a.HostID = d.RPR_ID_HOST AND a.CompNumber = d.RPR_COMP
			WHERE /*NT_TECH IN (0, 1)
				AND */a.DS_REG = 0
				AND a.SST_SHORT NOT IN ('ДИУ', 'АДМ', 'ДСП', 'ОДД')
				AND (c.INET_CHECK IS NULL OR c.INET_CHECK = 0)
				/*
				AND EXISTS
					(
						SELECT *
						FROM dbo.HotlineDistr b
						WHERE a.HostID = b.ID_HOST
							AND a.DistrNumber = b.DISTR
							AND a.CompNumber = b.COMP
							AND STATUS = 1
					)
					*/
			ORDER BY ManagerName, ServiceName, ClientName

			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[HOTLINE_DETAIL] TO rl_report;
GO