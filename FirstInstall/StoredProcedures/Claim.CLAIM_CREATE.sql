USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[CLAIM_CREATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[CLAIM_CREATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[CLAIM_CREATE]
	@IND_ID	VARCHAR(MAX),
	@CLM_ID	UNIQUEIDENTIFIER = NULL OUTPUT,
	@EMAIL	Bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@CurClient	VarChar(256),
		@Subject	VarChar(255),
		@Body		VarChar(Max),
		@NUM		INT,
		@USER		UniqueIdentifier

	DECLARE @TBL TABLE(ID UniqueIdentifier);
	DECLARE @Clients Table(CL_NAME VarChar(256));

	SELECT @USER = US_ID_MASTER
	FROM Security.UserActive
	WHERE US_LOGIN = ORIGINAL_LOGIN()

	SELECT @NUM = MAX(CLM_NUM) + 1
	FROM Claim.Claims
	WHERE CONVERT(VARCHAR(8), CLM_DATE, 112) = CONVERT(VARCHAR(8), GETDATE(), 112)

	IF @NUM IS NULL
		SET @NUM = 1



	INSERT INTO Claim.Claims(CLM_ID_USER, CLM_NUM)
	OUTPUT INSERTED.CLM_ID INTO @TBL
	VALUES(@USER, @NUM)

	SELECT @CLM_ID = ID
	FROM @TBL

	INSERT INTO Claim.ClaimDetail(
		CLD_ID_CLAIM, CLD_ID_CLIENT, CLD_ID_VENDOR,
		CLD_ID_SYSTEM, CLD_ID_TYPE,
		CLD_ID_NET, CLD_ID_TECH,
		CLD_COUNT, CLD_COMMENT)
		SELECT
			@CLM_ID, CL_ID_MASTER, VD_ID_MASTER, SYS_ID_MASTER,
			DT_ID_MASTER, NT_ID_MASTER, TT_ID_MASTER, COUNT(IND_ID), ID_COMMENT
		FROM
			Install.InstallFullView INNER JOIN
			Common.TableFromList(@IND_ID, ',') ON ID = IND_ID
		GROUP BY CL_ID_MASTER, VD_ID_MASTER, SYS_ID_MASTER, DT_ID_MASTER, NT_ID_MASTER, TT_ID_MASTER, ID_COMMENT

	UPDATE Install.InstallDetail
	SET IND_ID_CLAIM = @CLM_ID
	WHERE IND_ID IN
		(
			SELECT ID
			FROM Common.TableFromList(@IND_ID, ',')
		);

	IF @EMAIL = 1 BEGIN
		INSERT INTO @Clients
		SELECT DISTINCT CL_NAME
		FROM Claim.ClaimFullView AS C
		WHERE CLM_ID = @CLM_ID;

		SET @CurClient = '';

		WHILE (1 = 1) BEGIN
			SELECT TOP (1)
				@CurClient = CL_NAME
			FROM @Clients
			WHERE CL_NAME > @CurClient
			ORDER BY CL_NAME;

			IF @@RowCount < 1
				BREAK;

			SET @Subject = 'Наряд на выдачу дистрибутивов, клиент: ' + @CurClient;

			SET @Body =
				'
				<h2>Наряд на выдачу дистрибутивов (' + @CurClient + '):</h2>
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
					[DistrData] = String_Agg('<div>' + C.SYS_SHORT + ' ' + C.DT_SHORT + ' ' + C.NT_SHORT + ' ' + C.TT_SHORT + CASE WHEN CLD_COUNT != 1 THEN CAST(CLD_COUNT AS VarChar(10)) + ' шт.' ELSE '' END + '</div>', Char(10))
				FROM Claim.ClaimFullView AS C
				WHERE CLM_ID = @CLM_ID
					AND CL_NAME = @CurClient
				GROUP BY VD_NAME
			) AS C
			ORDER BY VD_NAME

			SET @Body = @Body + '</table>'

			EXEC [Common].[MAIL_SEND]
				--@Recipients             = 'gvv@bazis;blohin@bazis;samusenko@bazis;sklad@bazis',
				@Recipients             = 'gvv@bazis;blohin@bazis;samusenko@bazis;sklad@bazis',
				@blind_copy_recipients  = NULL,
				@Subject                = @Subject,
				@Body                   = @Body,
				@Body_Format            = 'html'
		END;
	END;
END
GO
GRANT EXECUTE ON [Claim].[CLAIM_CREATE] TO rl_claim_w;
GO
