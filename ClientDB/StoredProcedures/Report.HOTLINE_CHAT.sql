USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[HOTLINE_CHAT]
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

		SET language russian

		SELECT
			ClientFullName AS [Клиент], /*ManagerName AS [Рук-ль], */ServiceName AS [СИ], DistrStr AS [Дистрибутив], 
			FIRST_DATE AS [Дата вопроса], /*FINISH AS [Окончание сессии], */
			/*EMAIL AS [Email], PHONE AS [Телефон], */CHAT AS [Чат], 
			RIC_PERSONAL AS [Сотрудник РИЦ], FIRST_ANS AS [Время первой реакции],
			DATEDIFF(SECOND, FIRST_DATE, FIRST_ANS) AS [Скорость первой реакции],
			DATEDIFF(SECOND, START, FIRST_ANS) AS [Время между принятием и ответом],
			START AS [Начало сессии], FIO AS [ФИО], PROFILE AS [Профиль]
		FROM 
			dbo.HotlineChatView a
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DISTR = b.DISTR AND a.COMP = b.COMP
			INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
		WHERE a.DISTR NOT IN (20, 509880)
			AND FIRST_DATE >= '20170206'
		ORDER BY FIRST_DATE DESC
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
