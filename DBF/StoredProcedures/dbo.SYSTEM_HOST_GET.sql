USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[SYSTEM_HOST_GET]
	@distrid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sysid INT

	SELECT @sysid = SYS_ID
	FROM dbo.DistrView
	WHERE DIS_ID = @distrid

	SELECT SYS_ID, SYS_SHORT_NAME
	FROM dbo.SystemTable
	WHERE SYS_ID <> @sysid 
		AND SYS_ID_HOST = 
				(
					SELECT SYS_ID_HOST 
					FROM dbo.SystemTable 
					WHERE SYS_ID = @sysid
				)
	
END


