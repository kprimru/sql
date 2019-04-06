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

CREATE PROCEDURE [dbo].[GLOBAL_SETTINGS_DELETE]
	@gsid SMALLINT
AS
BEGIN	
	SET NOCOUNT ON;

	DELETE
	FROM dbo.GlobalSettingsTable
	WHERE GS_ID = @gsid
END

