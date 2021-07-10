USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[GLOBAL_SETTINGS_ADD]
	-- Список параметров процедуры
	@gsname VARCHAR(50),
	@gsvalue VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON обязателен для использования в хранимых процедурах.
	-- Позволяет избежать лишней информации и сетевого траффика.

	SET NOCOUNT ON;

	-- Текст процедуры ниже
	INSERT INTO dbo.GlobalSettingsTable
							(
								GS_NAME, GS_VALUE, GS_ACTIVE
							)
	VALUES
							(
								@gsname, @gsvalue, @active
							)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END



GO
GRANT EXECUTE ON [dbo].[GLOBAL_SETTINGS_ADD] TO rl_global_settings_w;
GO