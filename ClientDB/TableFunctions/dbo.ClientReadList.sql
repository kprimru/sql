USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientReadList]', 'TF') IS NULL EXEC('CREATE FUNCTION [dbo].[ClientReadList] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE FUNCTION [dbo].[ClientReadList]()
RETURNS @TBL TABLE
	(
		RCL_ID INT
	)
AS
BEGIN
	DECLARE @ALL	BIT
	DECLARE @MAN	BIT
	DECLARE @SER	BIT
	DECLARE @ORI	BIT

	DECLARE @INCLUDE TABLE
		(
			ID INTEGER PRIMARY KEY
		)
	DECLARE @EXCLUDE TABLE
		(
			ID INTEGER PRIMARY KEY
		)

	SELECT
		@ALL = LST_ALL,
		@MAN = LST_MANAGER,
		@SER = LST_SERVICE,
		@ORI = LST_ORI
	FROM Security.ClientList
	WHERE LST_TYPE = 'READ'
		AND LST_USER = ORIGINAL_LOGIN()

	INSERT INTO @INCLUDE(ID)
		SELECT DISTINCT ID
		FROM
			Security.ClientList
			CROSS APPLY
				(
					SELECT z.value('.', 'INT') AS ID
					FROM LST_INCLUDE.nodes('/LIST/ITEM') x(z)
				) AS o_O
		WHERE LST_TYPE = 'READ'
			AND LST_USER = ORIGINAL_LOGIN()

	INSERT INTO @EXCLUDE(ID)
		SELECT DISTINCT ID
		FROM
			Security.ClientList
			CROSS APPLY
				(
					SELECT z.value('.', 'INT') AS ID
					FROM LST_EXCLUDE.nodes('/LIST/ITEM') x(z)
				) AS o_O
		WHERE LST_TYPE = 'READ'
			AND LST_USER = ORIGINAL_LOGIN()

	IF @ALL IS NULL OR @MAN IS NULL OR @SER IS NULL OR @ORI IS NULL
	BEGIN
		SELECT
			@ALL = CONVERT(BIT, MAX(CONVERT(INT, LST_ALL))),
			@MAN = CONVERT(BIT, MAX(CONVERT(INT, LST_MANAGER))),
			@SER = CONVERT(BIT, MAX(CONVERT(INT, LST_SERVICE))),
			@ORI = CONVERT(BIT, MAX(CONVERT(INT, LST_ORI)))
		FROM
			Security.ClientList
			INNER JOIN dbo.RoleTable ON RoleName = LST_USER
			INNER JOIN sys.database_principals a ON a.name = RoleName
			INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
			INNER JOIN sys.database_principals c ON b.member_principal_id = c.principal_id
		WHERE c.name = ORIGINAL_LOGIN() AND LST_TYPE = 'READ'

		DELETE FROM @INCLUDE
		DELETE FROM @EXCLUDE

		INSERT INTO @INCLUDE(ID)
			SELECT DISTINCT ID
			FROM
				Security.ClientList
				INNER JOIN dbo.RoleTable ON RoleName = LST_USER
				INNER JOIN sys.database_principals a ON a.name = RoleName
				INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
				INNER JOIN sys.database_principals c ON b.member_principal_id = c.principal_id
				CROSS APPLY
					(
						SELECT z.value('.', 'INT') AS ID
						FROM LST_INCLUDE.nodes('/LIST/ITEM') x(z)
					) AS o_O
			WHERE LST_TYPE = 'READ'
				AND LST_USER = ORIGINAL_LOGIN()

		INSERT INTO @EXCLUDE(ID)
			SELECT DISTINCT ID
			FROM
				Security.ClientList
				INNER JOIN dbo.RoleTable ON RoleName = LST_USER
				INNER JOIN sys.database_principals a ON a.name = RoleName
				INNER JOIN sys.database_role_members b ON a.principal_id = b.role_principal_id
				INNER JOIN sys.database_principals c ON b.member_principal_id = c.principal_id
				CROSS APPLY
					(
						SELECT z.value('.', 'INT') AS ID
						FROM LST_EXCLUDE.nodes('/LIST/ITEM') x(z)
					) AS o_O
			WHERE LST_TYPE = 'READ'
				AND LST_USER = ORIGINAL_LOGIN()
	END

	IF IS_SRVROLEMEMBER('sysadmin') = 1
		SET @ALL = 1

	IF @ALL = 1
		INSERT INTO @TBL
			SELECT ClientID
			FROM dbo.ClientTable
			WHERE STATUS = 1
	ELSE IF @MAN = 1
		INSERT INTO @TBL
			SELECT ClientID
			FROM dbo.ClientView WITH(NOEXPAND)
			WHERE ManagerLogin = ORIGINAL_LOGIN()
	ELSE IF @SER = 1
		INSERT INTO @TBL
			SELECT ClientID
			FROM dbo.ClientView WITH(NOEXPAND)
			WHERE ServiceLogin = ORIGINAL_LOGIN()
	ELSE IF @ORI = 1
		INSERT INTO @TBL
			SELECT ClientID
			FROM dbo.ClientTable
			WHERE OriClient = 1 AND STATUS = 1

	INSERT INTO @TBL
		SELECT ID
		FROM @INCLUDE
		WHERE NOT EXISTS
			(
				SELECT *
				FROM @TBL
				WHERE RCL_ID = ID
			)

	DELETE FROM @TBL
	WHERE RCL_ID IN
		(
			SELECT ID
			FROM @EXCLUDE
		)


	RETURN
END
GO
GRANT SELECT ON [dbo].[ClientReadList] TO public;
GO
