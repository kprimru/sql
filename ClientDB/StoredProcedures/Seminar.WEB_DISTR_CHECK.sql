USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[WEB_DISTR_CHECK]
	@ID		UNIQUEIDENTIFIER,
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

		-- ToDo два обращения
		IF NOT EXISTS
			(
				SELECT *
				FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
				WHERE MainDistrNumber = @DISTR AND MainCompNumber = @COMP
			)
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'Вы не являетесь клиентом компании "Базис". Запись на семинар недоступна'
			
			RETURN
		END
		
		SELECT @HOST = MainHostID
		FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
		WHERE MainDistrNumber = @DISTR AND MainCompNumber = @COMP
		
		IF (SELECT DS_REG FROM Reg.RegNodeSearchView WITH(NOEXPAND) WHERE HostID = @HOST AND DistrNumber = @DISTR AND CompNumber = @COMP) <> 0
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'Вы не являетесь сопровождаемым клиентом компании "Базис". Для того, чтобы подключиться к сопровождению, обратитесь к нам.'
			
			RETURN
		END

		DECLARE @CLIENT INT
		
		SELECT @CLIENT = ID_CLIENT
		FROM dbo.ClientDistrView WITH(NOEXPAND)
		WHERE HostID = @HOST AND DISTR = @DISTR AND COMP = @COMP

		IF @CLIENT IS NULL
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'Вы не являетесь клиентом компании "Базис". Запись на семинар недоступна'
			
			RETURN
		END

		IF (SELECT IsNull(IsDebtor, 0) FROM dbo.ClientTable WHERE ClientId = @CLIENT) = 1
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'На текущий момент Ваша компания имеет задолженность за сопровождение системы КонсультантПлюс. В связи с этим запись на семинар не предоставляется.'
			
			RETURN
		END

		IF 
			(
				SELECT COUNT(*)
				FROM Seminar.Personal
				WHERE ID_SCHEDULE = @ID
					AND ID_CLIENT = @CLIENT
					AND STATUS = 1
			) >=
			(
				SELECT COUNT(*)
				FROM dbo.ClientDistrView WITH(NOEXPAND)
				WHERE ID_CLIENT = @CLIENT
					AND HostID = 1
					AND DS_REG = 0
			)
		BEGIN
			SET @STATUS = 1
			SET @MSG = 'Ваш сотрудник уже записан на семинар. Запись невозможна'
			
			RETURN
		END
		ELSE
		BEGIN
			SET @STATUS = 0
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
