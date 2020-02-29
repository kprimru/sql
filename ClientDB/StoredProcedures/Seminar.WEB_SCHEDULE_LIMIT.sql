USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[WEB_SCHEDULE_LIMIT]
	@ID		UNIQUEIDENTIFIER,
	@LIMIT	SMALLINT = NULL OUTPUT
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
			@LIMIT = 
				LIMIT - 
				ISNULL((
					SELECT COUNT(*) 
					FROM 
						Seminar.Personal a
						INNER JOIN Seminar.Status b ON a.ID_STATUS = b.ID
					WHERE ID_SCHEDULE = @ID AND b.INDX = 1 AND a.STATUS = 1
				), 0)
		FROM 
			Seminar.Schedule
		WHERE ID = @ID	
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
