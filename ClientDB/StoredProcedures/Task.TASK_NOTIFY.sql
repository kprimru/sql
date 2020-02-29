USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Task].[TASK_NOTIFY]
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

		DECLARE @USER	NVARCHAR(128)
		
		SET @USER = ORIGINAL_LOGIN()	
			
		SELECT 
			a.ID, a.DATE, a.SHORT, a.NOTE		
		FROM 
			Task.Tasks a 
			INNER JOIN Task.TaskStatus b ON a.ID_STATUS = b.ID
			LEFT OUTER JOIN dbo.ClientTable c ON c.ClientID = ID_CLIENT
		WHERE a.STATUS = 1
			AND b.PSEDO IN ('ACTIVE', 'WORK')
			AND NOTIFY = 1
			AND dbo.DateOf(a.DATE) <= dbo.DateOf(DATEADD(DAY, NOTIFY_DAY, GETDATE()))
			AND 
				(
					-- личные
					(
						RECEIVER = @USER
						OR
						RECEIVER IN 
							(
								SELECT ServiceLogin 
								FROM 
									dbo.ServiceTable z
									INNER JOIN dbo.ManagerTable y ON z.ManagerID = y.ManagerID 
								WHERE ManagerLogin = @USER
							)
					)
						
					OR 	
										
					ID_CLIENT IN 
						(
							SELECT ClientID
							FROM dbo.ClientView WITH(NOEXPAND)
							WHERE ServiceLogin = @USER
								OR ManagerLogin = @USER
						)
				)
				
			EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
