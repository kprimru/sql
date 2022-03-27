USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Claim].[CLAIM_CREATE]
	@IND_ID	VARCHAR(MAX),
	@CLM_ID	UNIQUEIDENTIFIER = NULL OUTPUT,
	@EMAIL	Bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Body	VarChar(Max),
		@NUM	INT,
		@USER	UNIQUEIDENTIFIER

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER);

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
		SET @Body =
			'
			<h2>Наряд на выдачу дистрибутивов:</h2>
			<table width=800 border="1">
				<tr>
					<td width=50>№</td>
					<td width=100>Поставщик</td>
					<td width=250>Клиент</td>
					<td width=400>Дистрибутивы</td>
				</tr>';

		SELECT
			@Body = @Body + '
			<tr>
				<td>' + Cast(Row_Number() OVER(ORDER BY CL_NAME) AS VarChar(100)) + '</td>
				<td>' + VD_NAME + '</td>
				<td>' + CL_NAME + '</td>
				<td>' + [DistrData] + '</td>
			</tr>'
	 	FROM
		(
			SELECT
				CL_NAME, VD_NAME,
				[DistrData] = String_Agg('<div>' + C.SYS_SHORT + ' ' + C.DT_SHORT + ' ' + C.NT_SHORT + ' ' + C.TT_SHORT + CASE WHEN CLD_COUNT != 1 THEN CAST(CLD_COUNT AS VarChar(10)) + ' шт.' ELSE '' END + '</div>', Char(10))
			FROM Claim.ClaimFullView AS C
			WHERE CLM_ID = @CLM_ID
			GROUP BY CL_NAME, VD_NAME
		) AS C
		ORDER BY CL_NAME

		SET @Body = @Body + '</table>'

		EXEC [Common].[MAIL_SEND]
			@Recipients             = 'gvv@bazis;blohin@bazis;samusenko@bazis;sklad@bazis',
			@blind_copy_recipients  = NULL,
			@Subject                = 'Наряд на выдачу дистрибутивов',
			@Body                   = @Body,
			@Body_Format            = 'html'
	END;
END
GO
GRANT EXECUTE ON [Claim].[CLAIM_CREATE] TO rl_claim_w;
GO
