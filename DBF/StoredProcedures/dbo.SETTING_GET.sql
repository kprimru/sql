USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[SETTING_GET]
	@sname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT GS_VALUE 
	FROM dbo.GlobalSettingsTable 
	WHERE GS_NAME = @sname
END
