USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ONLINE_ACTIVITY_PERCENT]
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
			[Рук-ль/Подхост]		= IsNull(C.ManagerName, R.SubhostName),
			[СИ]					= C.ServiceName,
			[Клиент]				= IsNull(C.ClientFullName, R.Comment),
			[Дистрибутив]			= R.DistrStr,
			[Сетевитость]			= R.NT_SHORT,
			[Тип системы]			= R.SST_SHORT,
			[Начало ОВ]				= OA.FIRST_WEEK,
			[Всего недель ОВ]		= OA.TOTAL_WEEK,
			[Активных недель ОВ]	= OA.ACTIVITY_WEEK,
			[% активности]			= Round(Convert(Float, OA.ACTIVITY_WEEK)/OA.TOTAL_WEEK * 100, 2)
		FROM
		(
			SELECT ID_HOST, DISTR, COMP, FIRST_WEEK, W.WEEK_CNT AS TOTAL_WEEK, A.WEEK_CNT AS ACTIVITY_WEEK
			FROM
			(
				SELECT ID_HOST, DISTR, COMP, MIN(P.START) AS FIRST_WEEK
				FROM dbo.OnlineActivity OA
				INNER JOIN Common.Period P ON OA.ID_WEEK = P.ID
				GROUP BY ID_HOST, DISTR, COMP
			) OA
			OUTER APPLY
			(
				SELECT COUNT(DISTINCT ID_WEEK) AS WEEK_CNT
				FROM dbo.OnlineActivity W
				WHERE W.ID_HOST = OA.ID_HOST
					AND W.DISTR = OA.DISTR
					AND W.COMP = OA.COMP
			) AS W
			OUTER APPLY
			(
				SELECT COUNT(DISTINCT ID_WEEK) AS WEEK_CNT
				FROM dbo.OnlineActivity W
				WHERE W.ID_HOST = OA.ID_HOST
					AND W.DISTR = OA.DISTR
					AND W.COMP = OA.COMP
					AND W.ACTIVITY = 1
			) AS A
		) AS OA
		INNER JOIN Reg.RegNodeSearchView R WITH(NOEXPAND) ON OA.ID_HOST = R.HostID AND OA.DISTr = R.DIstrNumber AND OA.COMP = R.CompNumber
		LEFT JOIN dbo.ClientDistrView D WITH(NOEXPAND) ON OA.ID_HOST = D.HostId AND OA.DISTr = D.DISTR AND OA.COMP = D.COMP
		LEFT JOIN dbo.ClientView C WITH(NOEXPAND) ON D.ID_CLIENT = C.ClientID
		WHERE R.SST_SHORT NOT IN ('ОДД', 'ДСП')
			AND NT_TECH NOT IN (0, 1)
			AND r.DS_REG = 0
		ORDER BY R.SubhostName, C.ManagerName, C.ServiceName, C.ClientFullName, R.Comment, R.SystemOrder, R.DistrNumber, R.CompNumber
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
