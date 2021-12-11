USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[EXCESS_BASE_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[EXCESS_BASE_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[EXCESS_BASE_REPORT]
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
            [РГ]            = IsNull(ManagerName, SubhostName),
            [СИ]            = ServiceName,
            [Клиент]        = IsNull(ClientFullName, Comment),
            [Дистрибутив]   = dbo.DistrString(S.SystemShortName, U.UD_DISTR, U.UD_COMP),
            [Проблема]      = ERROR_NAME
        FROM USR.USRActiveView AS U
        CROSS JOIN
        (
            SELECT U.UF_ID, 'Одновременно установлены ИБ РЗ и РЗ(р)' AS ERROR_NAME
            FROM USR.USRActiveView AS U
            INNER JOIN USR.USRIB AS UI ON U.UF_ID = UI.UI_ID_USR
            INNER JOIN dbo.InfoBankTable AS I ON I.InfoBankID = UI.UI_ID_BASE
            WHERE InfoBankName IN ('ROS', 'RZB')
            GROUP BY U.UF_ID
            HAVING COUNT(*) > 1
        ) AS F
        INNER JOIN dbo.SystemTable AS S ON U.UF_ID_SYSTEM = S.SystemID
        INNER JOIN Reg.RegNodeSearchView AS R WITH(NOEXPAND) ON R.HostID = U.UD_ID_HOST AND R.DistrNumber = U.UD_DISTR AND R.CompNumber = U.UD_COMP
        LEFT JOIN dbo.ClientDistrView AS CD WITH(NOEXPAND) ON CD.HostID = R.HostID AND CD.DISTR = R.DistrNumber AND CD.COMP = R.CompNumber
        LEFT JOIN dbo.ClientView AS C WITH(NOEXPAND) ON C.ClientID = CD.ID_CLIENT
        WHERE F.UF_ID = U.UF_ID
            AND R.DistrType NOT IN ('HSS', 'NCT', 'DSP')
        ORDER BY CASE R.SubhostName WHEN '' THEN 1 ELSE 2 END, SubhostName, ManagerName, ServiceName, ClientFullName, Comment, R.SystemOrder, DistrNumber, CompNumber

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
