USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_ACT_DELIVERY]
	@IND_ID		VARCHAR(MAX),
	@PER_ID		UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@CurClient	VarChar(256),
		@Subject	VarChar(255),
		@Body		VarChar(Max),
		@Email VarChar(Max);

	DECLARE @Clients Table(CL_NAME VarChar(256));

	SELECT @Email = PER_EMAIL
	FROM Personal.PersonalActive
	WHERE PER_ID_MASTER = @PER_ID;

	IF @Email IS NULL BEGIN
		RaisError('Не указан e-mail пользователя!', 16, 1);
		RETURN;
	END;

	SET @Email = @Email + ';gvv@bazis;blohin@bazis;samusenko@bazis'

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	DECLARE @ID		UNIQUEIDENTIFIER

	DECLARE ID CURSOR LOCAL FOR
		SELECT ID
		FROM Common.TableFromList(@IND_ID, ',')

	OPEN ID

	FETCH NEXT FROM ID INTO @ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', @ID, @OLD OUTPUT

		UPDATE	Install.InstallDetail
		SET		IND_ID_ACT_PERSONAL		=	@PER_ID
		WHERE	IND_ID	 = @ID

		EXEC Common.PROTOCOL_VALUE_GET 'INSTALL_DETAIL', @ID, @NEW OUTPUT

		EXEC Common.PROTOCOL_INSERT 'INSTALL_DETAIL', 'Указание переданного акта', @ID, @OLD, @NEW

		FETCH NEXT FROM ID INTO @ID
	END

	CLOSE ID
	DEALLOCATE ID

	INSERT INTO @Clients
	SELECT DISTINCT CL_NAME
	FROM Install.InstallFullView AS C
	WHERE IND_ID IN (SELECT ID FROM Common.TableFromList(@IND_ID, ','))

	SET @CurClient = '';

	WHILE (1 = 1) BEGIN
		SELECT TOP (1)
			@CurClient = CL_NAME
		FROM @Clients
		WHERE CL_NAME > @CurClient
		ORDER BY CL_NAME;

		IF @@RowCount < 1
			BREAK;

		SET @Subject = 'Передан акт, клиент: ' + @CurClient;

		SET @Body =
			'
			<h2>Переданы акты: (' + @CurClient + '):</h2>
			<table width=800 border="1">
				<tr>
					<td width=200>Поставщик</td>
					<td width=600>Дистрибутивы</td>
				</tr>';

		SELECT
			@Body = @Body + '
			<tr>
				<td>' + VD_NAME + '</td>
				<td>' + [DistrData] + '</td>
			</tr>'
	 	FROM
		(
			SELECT
				VD_NAME,
			[DistrData] = String_Agg('<div>' + C.SYS_SHORT + ' ' + C.DT_SHORT + ' ' + C.NT_NEW_NAME + ' ' + IND_DISTR + '</div>', Char(10))
			FROM Install.InstallFullView AS C
			WHERE IND_ID IN (SELECT ID FROM Common.TableFromList(@IND_ID, ','))
				AND C.CL_NAME = @CurClient
			GROUP BY VD_NAME
		) AS C
		ORDER BY VD_NAME

		SET @Body = @Body + '</table>'

		EXEC [Common].[MAIL_SEND]
			@Recipients             = @Email,
			@blind_copy_recipients  = NULL,
			@Subject                = @Subject,
			@Body                   = @Body,
			@Body_Format            = 'html'
	END;
END
GO
GRANT EXECUTE ON [Install].[INSTALL_ACT_DELIVERY] TO rl_install_act_sign;
GO
