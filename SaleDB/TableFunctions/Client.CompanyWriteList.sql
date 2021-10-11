USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Client].[CompanyWriteList]()
RETURNS @TBL TABLE
(
	ID	UNIQUEIDENTIFIER
)
AS
BEGIN
	DECLARE @ALL		BIT
	DECLARE @SALE_MAN	BIT
	DECLARE @SALE_ALL	BIT
	DECLARE @SALE		BIT
	DECLARE @PHONE_MAN	BIT
	DECLARE @PHONE		BIT
	DECLARE @RIVAL		BIT

	SELECT
		@ALL		=	V_ALL,
		@SALE_MAN	=	V_SALE_MAN,
		@SALE_ALL	=	V_SALE_ALL,
		@SALE		=	V_SALE,
		@PHONE_MAN	=	V_PHONE_MAN,
		@PHONE		=	V_PHONE,
		@RIVAL		=	V_RIVAL
	FROM Security.CompanyList
	WHERE TYPE = 'WRITE'
		AND USER_NAME = ORIGINAL_LOGIN()

	IF @ALL IS NULL OR @SALE_MAN IS NULL OR @SALE IS NULL OR @PHONE_MAN IS NULL OR @PHONE IS NULL OR @RIVAL IS NULL
	BEGIN
		SELECT
			@ALL		= CONVERT(BIT, MAX(CONVERT(INT, V_ALL))),
			@SALE_MAN	= CONVERT(BIT, MAX(CONVERT(INT, V_SALE_MAN))),
			@SALE_ALL	= CONVERT(BIT, MAX(CONVERT(INT, V_SALE_ALL))),
			@SALE		= CONVERT(BIT, MAX(CONVERT(INT, V_SALE))),
			@PHONE_MAN	= CONVERT(BIT, MAX(CONVERT(INT, V_PHONE_MAN))),
			@PHONE		= CONVERT(BIT, MAX(CONVERT(INT, V_PHONE))),
			@RIVAL		= CONVERT(BIT, MAX(CONVERT(INT, V_RIVAL)))
		FROM
			Security.CompanyList t
			INNER JOIN Security.RoleGroup z ON z.NAME = USER_NAME
			INNER JOIN sys.database_principals a ON a.name = z.NAME
			INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
			INNER JOIN sys.database_principals c ON b.member_principal_id = c.principal_id
		WHERE c.name = ORIGINAL_LOGIN() AND t.TYPE = 'WRITE'
	END

	DECLARE @PER_ID	UNIQUEIDENTIFIER

	SELECT @PER_ID = ID
	FROM Personal.OfficePersonal
	WHERE LOGIN = ORIGINAL_LOGIN()
		AND END_DATE IS NULL

	IF @ALL = 1
	BEGIN
		INSERT INTO @TBL
			SELECT ID
			FROM Client.Company
			WHERE STATUS = 1 AND @ALL = 1
	END
	ELSE
	BEGIN
		INSERT INTO @TBL
			SELECT a.ID
			FROM
				Client.CompanyProcessSaleView a WITH(NOEXPAND)
				INNER JOIN Personal.PersonalSlaveGet(@PER_ID) b ON a.ID_PERSONAL = b.ID
			WHERE @SALE_MAN = 1

			UNION

			SELECT a.ID
			FROM Client.CompanyProcessManagerView a WITH(NOEXPAND)
			WHERE @SALE_MAN = 1	AND ID_PERSONAL = @PER_ID

			UNION

			SELECT a.ID
			FROM Client.CompanyProcessManagerView a WITH(NOEXPAND)
			WHERE @SALE_ALL = 1

			UNION

			SELECT a.ID
			FROM Client.CompanyProcessSaleView a WITH(NOEXPAND)
			WHERE @SALE = 1 AND ID_PERSONAL = @PER_ID

			UNION

			SELECT a.ID
			FROM
				Client.CompanyProcessPhoneView a WITH(NOEXPAND)
				INNER JOIN Personal.PersonalSlaveGet(@PER_ID) b ON a.ID_PERSONAL = b.ID
			WHERE @PHONE_MAN = 1

			UNION

			SELECT a.ID
			FROM Client.CompanyProcessPhoneView a WITH(NOEXPAND)
			WHERE @PHONE = 1 AND ID_PERSONAL = @PER_ID

			UNION

			SELECT a.ID
			FROM Client.CompanyProcessRivalView a WITH(NOEXPAND)
			WHERE @RIVAL = 1 AND ID_PERSONAL = @PER_ID
	END

	RETURN
END
GO
