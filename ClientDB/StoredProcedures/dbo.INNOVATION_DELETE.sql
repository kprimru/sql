USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[INNOVATION_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DELETE 
	FROM dbo.ClientInnovationControl
	WHERE ID_PERSONAL IN
		(
			SELECT ID
			FROM dbo.ClientInnovationPersonal
			WHERE ID_INNOVATION IN
				(
					SELECT ID
					FROM dbo.ClientInnovation
					WHERE ID_INNOVATION = @ID
				)
		)
	
	DELETE
	FROM dbo.ClientInnovationPersonal
	WHERE ID_INNOVATION IN
		(
			SELECT ID
			FROM dbo.ClientInnovation
			WHERE ID_INNOVATION = @ID
		)
		
	DELETE
	FROM dbo.ClientInnovation
	WHERE ID_INNOVATION = @ID
	
	DELETE
	FROM dbo.Innovation
	WHERE ID = @ID
END
