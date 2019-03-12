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
END
