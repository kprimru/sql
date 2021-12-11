USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_LEFT_BANKS_GET(OLD)]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_LEFT_BANKS_GET(OLD)]  AS SELECT 1')
GO
ALTER PROCEDURE	[dbo].[SYSTEM_LEFT_BANKS_GET(OLD)]
	@SYS_LIST			NVARCHAR(128),
	@DISTR_TYPE_LIST	NVARCHAR(128)
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

		DECLARE @t	TABLE (InfoBank_ID	SMALLINT, InfoBankName	VARCHAR(20), InfoBankShortName	VARCHAR(20), Required	BIT, InfoBankOrder	INT)

		DECLARE @SYS_END				BIT
		SET @SYS_END = 0

		DECLARE @DISTR_TYPE_END			BIT
		DECLARE @DISTR_TYPE_TEMP_LIST	NVARCHAR(128)

		DECLARE @TEMP_S					NVARCHAR(15)
		DECLARE @TEMP_D					NVARCHAR(15)

		WHILE @SYS_END = 0
		BEGIN
			IF (CHARINDEX(',', @SYS_LIST)<>0)
			BEGIN
				SET @TEMP_S = SUBSTRING(@SYS_LIST, 1, CHARINDEX(',', @SYS_LIST)-1)						--«ƒ≈—‹ ¬€“¿— »¬¿≈Ã œŒ ŒƒÕŒÃ” ID —»—“≈Ã€ »« —œ»— ¿
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

				INSERT INTO @t(InfoBank_ID, InfoBankName, InfoBankShortName, Required, InfoBankOrder)
				EXEC [dbo].[SYSTEM_BANKS_SELECT] @TEMP_S, @TEMP_D
			END
		END

		DECLARE @res_t	TABLE (InfoBank_ID	SMALLINT, InfoBankName	VARCHAR(20), InfoBankShortName	VARCHAR(20), InfoBankOrder	INT)

		INSERT INTO @res_t(InfoBank_ID, InfoBankName, InfoBankShortName, InfoBankOrder)
		SELECT InfoBankID, InfoBankName, InfoBankShortName, InfoBankOrder
		FROM InfoBankTable
		WHERE InfoBankID NOT IN (SELECT InfoBank_ID FROM @t)

		SELECT *
		FROM @res_t
		ORDER BY InfoBankOrder

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_LEFT_BANKS_GET(OLD)] TO rl_info_bank_r;
GRANT EXECUTE ON [dbo].[SYSTEM_LEFT_BANKS_GET(OLD)] TO rl_system_bank_r;
GO
