USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[STT_SEND]
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
			ISNULL(ClientFullName, d.Comment) AS [Клиент], ISNULL(ManagerName, SubhostName) AS [Рук-ль], ServiceName AS [СИ], 
			ISNULL(b.DistrStr, d.DistrStr) AS [Осн.дистрибутив], dbo.DateOf(CSD_DATE) AS [Последняя отправка STT],
			Common.DateDiffString(CSD_DATE, GETDATE()) AS [Как давно]	
		FROM
			(
				SELECT HostID, CSD_DISTR, CSD_COMP, MAX(ISNULL(CSD_START, CSD_END)) AS CSD_DATE
				FROM 
					dbo.IPSttView
					INNER JOIN dbo.SystemTable ON CSD_SYS = SystemNumber
				GROUP BY HostID, CSD_DISTR, CSD_COMP
			) AS a
			LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.CSD_DISTR = b.DISTR AND a.CSD_COMP = b.COMP
			LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
			LEFT OUTER JOIN Reg.RegNodeSearchView d WITH(NOEXPAND) ON a.HostID = d.HostID AND a.CSD_DISTR = d.DistrNumber AND a.CSD_COMP = d.CompNumber
		WHERE d.DS_REG = 0
		ORDER BY ISNULL(ManagerName, ''), 2, 3, 1, 4
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
