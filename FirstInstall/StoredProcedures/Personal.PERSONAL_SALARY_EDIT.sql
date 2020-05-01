USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_SALARY_EDIT]
	@PR_ID		UNIQUEIDENTIFIER,
	@PER_ID		UNIQUEIDENTIFIER,
	@PDS_VALUE	MONEY,
	@PDS_COMMENT	VARCHAR(500)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PDS_ID UNIQUEIDENTIFIER

	SELECT @PDS_ID = PDS_ID
	FROM Personal.PersonalDefaultSalary
	WHERE PDS_ID_PERIOD = @PR_ID
		AND PDS_ID_PERSONAL = @PER_ID

    DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_DEFAULT_SALARY', @PDS_ID, @OLD OUTPUT

	UPDATE	Personal.PersonalDefaultSalary
	SET		PDS_VALUE	=	@PDS_VALUE,
			PDS_COMMENT	=	@PDS_COMMENT
	WHERE	PDS_ID_PERIOD	= @PR_ID
		AND PDS_ID_PERSONAL = @PER_ID

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO Personal.PersonalDefaultSalary(PDS_ID_PERSONAL, PDS_ID_PERIOD, PDS_VALUE, PDS_COMMENT)
			VALUES(@PER_ID, @PR_ID, @PDS_VALUE, '')

		SELECT @PDS_ID = PDS_ID
		FROM Personal.PersonalDefaultSalary
		WHERE PDS_ID_PERIOD = @PR_ID
			AND PDS_ID_PERSONAL = @PER_ID
	END

	EXEC Common.PROTOCOL_VALUE_GET 'PERSONAL_DEFAULT_SALARY', @PDS_ID, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'PERSONAL_DEFAULT_SALARY', '�����', @PDS_ID, @OLD, @NEW
END
GRANT EXECUTE ON [Personal].[PERSONAL_SALARY_EDIT] TO rl_personal_default_salary_w;
GO