USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[HOTLINE_CONNECT]
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

		SELECT ISNULL(ManagerName, SubhostName) AS [Руководитель], ServiceName AS [СИ], ISNULL(ClientFullName, Comment) AS [Клиент], z.DistrStr AS [Осн. система], b.DistrTypeName AS [Сеть], SET_DATE AS [Подключен]
		FROM
			dbo.HotlineDistr a
			INNER JOIN Reg.RegNodeSearchView z WITH(NOEXPAND) ON z.HostID = ID_HOST AND DISTR = DistrNumber AND COMP = CompNumber
			LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON b.HostID = ID_HOST AND a.DISTR = b.DISTR AND a.COMP = b.COMP
			LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.ClientID
		WHERE STATUS = 1 AND z.DS_REG = 0
		ORDER BY CASE WHEN ManagerName IS NULL THEN 0 ELSE 1 END, ISNULL(ManagerName, SubhostName), ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Report].[HOTLINE_CONNECT] TO rl_report;
GO