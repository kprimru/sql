USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Din].[DIN_FILE_PROCESS]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Din].[DIN_FILE_PROCESS]  AS SELECT 1')
GO
ALTER PROCEDURE [Din].[DIN_FILE_PROCESS]
	@SYS	INT,
	@TYPE	INT,
	@NET	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@RIC	SMALLINT,
	@FILE	VARCHAR(150),
	@MD5	VARCHAR(100),
	@DIN	VARBINARY(MAX),
	/*
		Результат обработки:
		0. Норальное завершение - файл добавлен
		1. Дистрибутив уже есть в базе
	*/
	@RES	TINYINT = 0 OUTPUT
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

		SET @RES = 0

		IF EXISTS
			(
				SELECT *
				FROM Din.DinFiles
				WHERE DF_MD5 = @MD5
			)
		BEGIN
			IF EXISTS
				(
					SELECT *
					FROM Din.DinFiles
					WHERE DF_DIN = @DIN
						AND DF_MD5 = @MD5
				)
			BEGIN
				SET @RES = 1

				EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

				RETURN
			END
		END

		INSERT INTO Din.DinFiles(DF_ID_SYS, DF_ID_TYPE, DF_ID_NET, DF_DISTR, DF_COMP, DF_RIC, DF_FILE, DF_MD5, DF_DIN)
			VALUES(@SYS, @TYPE, @NET, @DISTR, @COMP, @RIC, @FILE, @MD5, @DIN)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Din].[DIN_FILE_PROCESS] TO rl_din_import;
GO
