USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[ARB_REPORT]
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

		SELECT ISNULL(ManagerName, SubhostName) AS 'Руководитель', ServiceName AS 'СИ', a.DistrStr AS 'Дистрибутив', ISNULL(ClientFullName, Comment) AS 'Клиент', SST_SHORT AS 'Тип'
		FROM
			Reg.RegNodeSearchView a WITH(NOEXPAND)
			LEFT OUTER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.SystemID = a.SystemID AND DISTR = DistrNumber AND COMP = CompNumber
			LEFT OUTER JOIN dbo.ClientView d WITH(NOEXPAND) ON ClientID = ID_CLIENT
		WHERE a.SystemShortName IN ('МБП', 'КЮ', 'БО')
			AND a.DS_REG = 0
			AND SST_SHORT NOT IN ('ДИУ')
			AND EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
					WHERE z.Complect = a.Complect
						AND z.DS_REG = 0
						AND z.SystemBaseName = 'ARB'
				)
		ORDER BY ISNULL(ManagerName, ''), 1, 2, 4

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[ARB_REPORT] TO rl_report;
GO
