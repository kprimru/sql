USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Описание:		
*/

CREATE PROCEDURE [dbo].[GLOBAL_SETTINGS_EDIT]
	@gsid SMALLINT,
	@gsname VARCHAR(50),
	@gsvalue VARCHAR(50),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.GlobalSettingsTable 
	SET	
		GS_NAME = @gsname, 
		GS_VALUE = @gsvalue,
		GS_ACTIVE = @active
	WHERE GS_ID = @gsid							
END


