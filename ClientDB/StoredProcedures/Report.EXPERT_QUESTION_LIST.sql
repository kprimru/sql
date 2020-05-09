USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[EXPERT_QUESTION_LIST]
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
			a.DATE AS [Дата], ISNULL(e.ClientFullName, c.Comment) AS [Клиент], c.DistrStr AS [Дистрибутив],
			ISNULL(e.ManagerName, c.SubhostName) AS [РГ], e.ServiceName AS [СИ], a.FIO AS [ФИО],
			a.QUEST AS [Вопрос], a.EMAIL, a.PHONE AS [Телефон]
		FROM
			dbo.ClientDutyQuestion a
			INNER JOIN dbo.SystemTable b ON a.SYS = b.SystemNumber
			INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND c.DistrNumber = a.DISTR AND c.CompNumber = a.COMP
			LEFT OUTER JOIN dbo.ClientDistrView d WITH(NOEXPAND) ON a.DISTR = d.DISTR AND a.COMP = d.COMP AND b.HostID = d.HostID
			LEFT OUTER JOIN dbo.ClientView e WITH(NOEXPAND) ON e.ClientID = d.ID_CLIENT
		ORDER BY a.DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[EXPERT_QUESTION_LIST] TO rl_report;
GO