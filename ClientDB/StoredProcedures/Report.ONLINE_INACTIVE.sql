USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[ONLINE_INACTIVE]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @LastWeek UniqueIdentifier;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        SET @LastWeek = (SELECT TOP (1) P.ID FROM Common.Period AS P INNER JOIN dbo.OnlineActivity AS OA ON OA.ID_WEEK = P.ID ORDER BY P.START DESC);

        SELECT
            [РГ]                                    = IsNull(C.ManagerName, R.SubhostName),
            [СИ]                                    = IsNull(C.ServiceName, R.SubhostName),
            [Клиент]                                = IsNull(C.ClientFullName, R.Comment),
            [Дистрибутив]                           = R.DistrStr,
            [Сеть]                                  = R.NT_SHORT,
            [Тип]                                   = R.SST_SHORT,
            [Последняя неделя активности]           = LOA.NAME,
            [Недель с момента первой регистрации]   = DateDiff(Week, R.FirstReg, OA.Start),
            [Недель без активности]                 = DateDiff(Week, LOA.Start, OA.Start)
        FROM
        (
            SELECT DISTINCT OA.ID_HOST, OA.DISTR, OA.COMP, P.NAME, P.START
            FROM dbo.OnlineActivity AS OA
            INNER JOIN Common.Period AS P ON P.ID = OA.ID_WEEK
            WHERE   OA.ID_WEEK = @LastWeek
                AND OA.ACTIVITY = 0
        ) AS OA
        INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON R.HostID = OA.ID_HOST AND R.DistrNumber = OA.DISTR AND R.CompNumber = OA.COMP
        LEFT JOIN dbo.ClientDistrView AS D WITH(NOEXPAND) ON D.HostID = OA.ID_HOST AND D.DISTR = OA.DISTR AND D.COMP = OA.COMP
        LEFT JOIN dbo.ClientView AS C WITH(NOEXPAND) ON D.ID_CLIENT = C.ClientID
        OUTER APPLY
        (
            SELECT TOP (1) LP.START, LP.NAME
            FROM dbo.OnlineActivity AS LOA
            INNER JOIN Common.Period AS LP ON LP.ID = LOA.ID_WEEK
            WHERE LOA.ID_HOST = OA.ID_HOST
                AND LOA.DISTR = OA.DISTR
                AND LOA.COMP = OA.COMP
                --AND LOA.LGN = OA.LGN
                AND LOA.ACTIVITY = 1
            ORDER BY LP.START DESC
        ) AS LOA
        WHERE   R.SST_SHORT NOT IN ('ДСП')
            AND R.NT_SHORT NOT IN ('сеть 100', 'сеть 50', 'сеть 5', 'сеть 255')
            AND
            (
                    LOA.START IS NULL
                OR  DateDiff(Week, LOA.Start, OA.Start) >= 4
            )
        ORDER BY
            CASE WHEN R.SubhostName = '' THEN 1 ELSE 2 END,
            C.ManagerName, C.ServiceName, C.ClientFullName, R.Comment, R.SystemOrder, OA.DISTR, OA.COMP;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
