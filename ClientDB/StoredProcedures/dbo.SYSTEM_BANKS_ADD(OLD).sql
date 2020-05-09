USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_BANKS_ADD(OLD)]
	@SYS_LIST				NVARCHAR(MAX),
	@DISTR_TYPE_LIST		NVARCHAR(MAX),
	@BANK_LIST				NVARCHAR(MAX),
	@REQUIRE				BIT
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

		DECLARE @TEMP_S					NVARCHAR(15)			--оепелеммше дкъ упюмемхъ йюфднцн оюпюлерпю он ндмнлс б жхйке
		DECLARE @TEMP_D					NVARCHAR(15)
		DECLARE @TEMP_B					NVARCHAR(15)

		DECLARE @DISTR_TYPE_TEMP_LIST	NVARCHAR(MAX)			--оепелеммше дкъ упюмемхъ йнохх яохяйю врнаш ецн лнфмн ашкн бняярюмнбхрэ дкъ якедсчыеи хрепюжхх жхйкю
		DECLARE @BANK_TEMP_LIST			NVARCHAR(MAX)

		DECLARE @SYS_END				BIT						--оепелеммше дкъ нопедекемхъ йнмжю яохяйю
		DECLARE @DISTR_TYPE_END			BIT
		DECLARE @BANK_END				BIT


		SET @SYS_END = 0

		WHILE @SYS_END = 0
		BEGIN
			IF (CHARINDEX(',', @SYS_LIST)<>0)
			BEGIN
				SET @TEMP_S = SUBSTRING(@SYS_LIST, 1, CHARINDEX(',', @SYS_LIST)-1)						--гдеяэ бшрюяйхбюел он ндмнлс ID яхярелш хг яохяйю
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

				SET @BANK_END = 0
				SET @BANK_TEMP_LIST = @BANK_LIST

				WHILE @BANK_END = 0
				BEGIN
					IF (CHARINDEX(',', @BANK_TEMP_LIST)<>0)
				BEGIN
					SET @TEMP_B = SUBSTRING(@BANK_TEMP_LIST, 1, CHARINDEX(',', @BANK_TEMP_LIST)-1)
					SET @BANK_TEMP_LIST = SUBSTRING(@BANK_TEMP_LIST, CHARINDEX(',', @BANK_TEMP_LIST)+1, LEN(@BANK_TEMP_LIST))
				END
				ELSE
				BEGIN
					SET @TEMP_B = @BANK_TEMP_LIST
					SET @BANK_END = 1
				END

					INSERT INTO dbo.SystemsBanks(System_Id, DistrType_Id, InfoBank_Id, [Required], [Start])
					VALUES(@TEMP_S, @TEMP_D, @TEMP_B, @REQUIRE, GETDATE())

					--PRINT(@TEMP_S+' '+@TEMP_D+' '+@TEMP_B+' '+CONVERT(VARCHAR, @REQUIRE))

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
GRANT EXECUTE ON [dbo].[SYSTEM_BANKS_ADD(OLD)] TO rl_system_bank_i;
GO