USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Mailing].[WEB_DISTR_CHECK]
	@STR	NVARCHAR(64),
	@MSG	NVARCHAR(256) OUTPUT,
	@STATUS	SMALLINT OUTPUT,
	@HOST	INT = NULL OUTPUT,
	@DISTR	INT = NULL OUTPUT,
	@COMP	TINYINT = NULL OUTPUT
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

		DECLARE @DISTR_S	NVARCHAR(64)
		DECLARE @COMP_S		NVARCHAR(64)

		SET @STR = LTRIM(RTRIM(@STR))

		IF CHARINDEX('/', @STR) <> 0
		BEGIN
			SET @DISTR_S = LEFT(@STR, CHARINDEX('/', @STR) - 1)
			SET @COMP_S = RIGHT(@STR, LEN(@STR) - CHARINDEX('/', @STR))
		END
		ELSE
		BEGIN
			SET @DISTR_S = @STR
			SET @COMP_S = '1'
		END

		DECLARE @ERROR	BIT


		SET @ERROR = 0

		BEGIN TRY
			SET @DISTR = CONVERT(INT, @DISTR_S)
			SET @COMP = CONVERT(INT, @COMP_S)
		END TRY
		BEGIN CATCH
			SET @ERROR = 1
		END CATCH

		IF @ERROR = 1
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'Неверно указан номер дистрибутива. Он должен быть указан либо в виде числа, либо в виде пары чисел, разделенных символом "/"'

			RETURN
		END

		-- ToDO два обращения!
		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
				WHERE MainDistrNumber = @DISTR AND MainCompNumber = @COMP
			)
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'Вы не зарегистрированы в РИЦ как клиент'

			RETURN
		END

		SELECT @HOST = MainHostID
		FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
		WHERE MainDistrNumber = @DISTR AND MainCompNumber = @COMP

		IF (SELECT DS_REG FROM Reg.RegNodeSearchView WITH(NOEXPAND) WHERE HostID = @HOST AND DistrNumber = @DISTR AND CompNumber = @COMP) <> 0
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'Дистрибутив отключен от сопровождения. Для того, чтобы подключиться к сопровождению, обратитесь к нам.'

			RETURN
		END


		SET @STATUS = 0

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Mailing].[WEB_DISTR_CHECK] TO rl_mailing_web;
GO