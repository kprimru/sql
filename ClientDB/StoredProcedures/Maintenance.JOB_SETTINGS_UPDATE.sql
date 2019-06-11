USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[JOB_SETTINGS_UPDATE]
	@ID		INT,
	@EXPIRE	INT
AS
BEGIN
	SET NOCOUNT ON;
	
	UPDATE Maintenance.JobType
	SET  ExpireTime =	@EXPIRE
	WHERE Id		=	@ID
END;