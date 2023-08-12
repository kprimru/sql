USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_BANKS_CREATE(OLD)]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_BANKS_CREATE(OLD)]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SYSTEM_BANKS_CREATE(OLD)]
	@SYS_LIST				NVARCHAR(MAX),
	@DISTR_TYPE_LIST		NVARCHAR(MAX),
	@BANK_REQ_LIST			NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @TEMP_S					NVARCHAR(15)			--ПЕРЕМЕННЫЕ ДЛЯ ХРАНЕНИЯ КАЖДОГО ПАРАМЕТРА ПО ОДНОМУ В ЦИКЛЕ
		DECLARE @TEMP_D					NVARCHAR(15)
		DECLARE @TEMP_B					NVARCHAR(15)
		DECLARE @TEMP_R					BIT

		DECLARE @DISTR_TYPE_TEMP_LIST	NVARCHAR(MAX)			--ПЕРЕМЕННЫЕ ДЛЯ ХРАНЕНИЯ КОПИИ СПИСКА ЧТОБЫ ЕГО МОЖНО БЫЛО ВОССТАНОВИТЬ ДЛЯ СЛЕДУЮЩЕЙ ИТЕРАЦИИ ЦИКЛА
		DECLARE @BANK_REQ_TEMP_LIST		NVARCHAR(MAX)

		DECLARE @SYS_END				BIT						--ПЕРЕМЕННЫЕ ДЛЯ ОПРЕДЕЛЕНИЯ КОНЦА СПИСКА
		DECLARE @DISTR_TYPE_END			BIT
		DECLARE @BANK_REQ_END			BIT





		SET @SYS_END = 0

		WHILE @SYS_END = 0
		BEGIN
			IF (CHARINDEX(',', @SYS_LIST)<>0)
			BEGIN
				SET @TEMP_S = SUBSTRING(@SYS_LIST, 1, CHARINDEX(',', @SYS_LIST)-1)						--ЗДЕСЬ ВЫТАСКИВАЕМ ПО ОДНОМУ ID СИСТЕМЫ ИЗ СПИСКА
				SET @SYS_LIST = SUBSTRING(@SYS_LIST, CHARINDEX(',', @SYS_LIST)+1, LEN(@SYS_LIST))
			END
			ELSE
			BEGIN
				SET @TEMP_S = @SYS_LIST
				SET @SYS_END = 1
			END

			SET @DISTR_TYPE_END = 0
			SET @DISTR_TYPE_TEMP_LIST = @DISTR_TYPE_LIST

			WHILE @DISTR_TYPE_END = 0
			BEGIN
				IF (CHARINDEX(',', @DISTR_TYPE_TEMP_LIST)<>0)
				BEGIN
					SET @TEMP_D = SUBSTRING(@DISTR_TYPE_TEMP_LIST, 1, CHARINDEX(',', @DISTR_TYPE_TEMP_LIST)-1)
					SET @DISTR_TYPE_TEMP_LIST = SUBSTRING(@DISTR_TYPE_TEMP_LIST, CHARINDEX(',', @DISTR_TYPE_TEMP_LIST)+1, LEN(@DISTR_TYPE_TEMP_LIST))
				END
				ELSE
				BEGIN
					SET @TEMP_D = @DISTR_TYPE_TEMP_LIST
					SET @DISTR_TYPE_END = 1
				END

				SET @BANK_REQ_END = 0
				SET @BANK_REQ_TEMP_LIST = @BANK_REQ_LIST

				DELETE
				FROM dbo.SystemsBanks
				WHERE	System_Id = @TEMP_S AND			--ПОЛНОСТЬЮ ВСЕ УДАЛЯЕМ ДЛЯ ЭТОЙ СИСТЕМЫ И СЕТИ И ЗАПОЛНЯЕМ ЗАНОВО
						DistrType_Id = @TEMP_D

				WHILE @BANK_REQ_END = 0
				BEGIN
					IF (CHARINDEX(',', @BANK_REQ_TEMP_LIST)<>0)
					BEGIN
						SET @TEMP_B = SUBSTRING(@BANK_REQ_TEMP_LIST, 1, CHARINDEX('-', @BANK_REQ_TEMP_LIST)-1)
						SET @TEMP_R = SUBSTRING(@BANK_REQ_TEMP_LIST, CHARINDEX('-', @BANK_REQ_TEMP_LIST)+1, 1) --ВАЖНО ПОМНИТЬ, 3 АРГУМЕНТ - ДЛИНА А НЕ КОНЕЧНАЯ ПОЗИЦИЯ

						SET @BANK_REQ_TEMP_LIST = SUBSTRING(@BANK_REQ_TEMP_LIST, CHARINDEX(',', @BANK_REQ_TEMP_LIST)+1, LEN(@BANK_REQ_TEMP_LIST))
					END
					ELSE
					BEGIN
						SET @TEMP_B = SUBSTRING(@BANK_REQ_TEMP_LIST, 1, CHARINDEX('-', @BANK_REQ_TEMP_LIST)-1)
						SET @TEMP_R = SUBSTRING(@BANK_REQ_TEMP_LIST, CHARINDEX('-', @BANK_REQ_TEMP_LIST)+1, LEN(@BANK_REQ_TEMP_LIST))

						SET @BANK_REQ_END = 1
					END

						INSERT INTO dbo.SystemsBanks(System_Id, DistrType_Id, InfoBank_Id, [Required], [Start])
						VALUES(@TEMP_S, @TEMP_D, @TEMP_B, @TEMP_R, GETDATE())



					--PRINT(@TEMP_S+' '+@TEMP_D+' '+@TEMP_B+' '+CONVERT(VARCHAR, @TEMP_R))

				END
			END
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_BANKS_CREATE(OLD)] TO rl_system_bank_i;
GO
