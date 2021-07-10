USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GLOBAL_SETTINGS_SET]
	@NAME	VARCHAR(50),
	@VALUE	VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT * FROM dbo.GlobalSettingsTable WHERE GS_NAME = @NAME)
		UPDATE dbo.GlobalSettingsTable
		SET GS_VALUE = @VALUE
		WHERE GS_NAME = @NAME
	ELSE
		INSERT INTO dbo.GlobalSettingsTable(GS_NAME, GS_VALUE, GS_ACTIVE)
			VALUES(@NAME, @VALUE, 1)
END

GO
GRANT EXECUTE ON [dbo].[GLOBAL_SETTINGS_SET] TO rl_global_settings_w;
GO