USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[SCHEDULE_PERSONAL_DELETE]
	@ID			UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	EXEC Seminar.SCHEDULE_PERSONAL_ARCH @ID
		
	UPDATE Seminar.Personal
	SET STATUS = 3,
		UPD_DATE = GETDATE(),
		UPD_USER = ORIGINAL_LOGIN()
	WHERE ID = @ID	
END
