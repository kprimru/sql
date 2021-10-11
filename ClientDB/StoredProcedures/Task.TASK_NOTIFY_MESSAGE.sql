USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Task].[TASK_NOTIFY_MESSAGE]
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

		INSERT INTO dbo.ClientMessage(ID_CLIENT, TP, SENDER, DATE, NOTE, RECEIVE_USER, HARD_READ)
			SELECT ID_CLIENT, TP, SENDER, DATE, NOTE, RECEIVE_USER, HARD_READ
			FROM
				(
					SELECT NULL AS ID_CLIENT, 1 As TP, 'Автомат' AS SENDER, GETDATE() AS DATE, a.NOTE, RECEIVER AS RECEIVE_USER, 1 AS HARD_READ
					FROM
						Task.Tasks a
						INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
						--LEFT OUTER JOIN dbo.ClientTable c ON c.ClientID = ID_CLIENT
						--LEFT OUTER JOIN dbo.ClientView d ON d.CLientID = c.CLientID
					WHERE a.STATUS = 1
						AND b.PSEDO IN ('ACTIVE', 'WORK')
						AND NOTIFY = 1
						AND dbo.DateOf(a.DATE) <= dbo.DateOf(DATEADD(DAY, NOTIFY_DAY, GETDATE()))
						AND RECEIVER IS NOT NULL

					UNION ALL

					SELECT ClientID, 1, 'Автомат', GETDATE(), a.NOTE, ManagerLogin, 1
					FROM
						Task.Tasks a
						INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
						INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = ID_CLIENT
					WHERE a.STATUS = 1
						AND b.PSEDO IN ('ACTIVE', 'WORK')
						AND NOTIFY = 1
						AND dbo.DateOf(a.DATE) <= dbo.DateOf(DATEADD(DAY, NOTIFY_DAY, GETDATE()))

					UNION ALL

					SELECT ClientID, 1, 'Автомат', GETDATE(), a.NOTE, ServiceLogin, 1
					FROM
						Task.Tasks a
						INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
						INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = ID_CLIENT
					WHERE a.STATUS = 1
						AND b.PSEDO IN ('ACTIVE', 'WORK')
						AND NOTIFY = 1
						AND dbo.DateOf(a.DATE) <= dbo.DateOf(DATEADD(DAY, NOTIFY_DAY, GETDATE()))
				) AS a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientMessage b
					WHERE (a.ID_CLIENT = b.ID_CLIENT OR (a.ID_CLIENT IS NULL AND b.ID_CLIENT IS NULL))
						AND a.TP = b.TP
						AND a.SENDER = b.SENDER
						AND a.NOTE = b.NOTE
						AND a.RECEIVE_USER = b.RECEIVE_USER
						AND b.RECEIVE_DATE IS NULL
						AND b.STATUS = 1
				)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END
GO
