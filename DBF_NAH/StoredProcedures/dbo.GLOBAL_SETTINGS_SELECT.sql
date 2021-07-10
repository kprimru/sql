USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[GLOBAL_SETTINGS_SELECT]
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT GS_ID, GS_NAME, GS_VALUE
	FROM dbo.GlobalSettingsTable
	WHERE GS_ACTIVE = ISNULL(@active, GS_ACTIVE)
END




GO
GRANT EXECUTE ON [dbo].[GLOBAL_SETTINGS_SELECT] TO rl_global_settings_r;
GO