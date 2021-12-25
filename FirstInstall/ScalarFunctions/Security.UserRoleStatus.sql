USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Security].[UserRoleStatus]
(
	@US_LOGIN VARCHAR(MAX),
	@RL_ID UNIQUEIDENTIFIER
)
RETURNS TINYINT
AS
BEGIN
	DECLARE @RESULT TINYINT

	SET @RESULT = 0

	DECLARE @RL TABLE (RL_ROLE VARCHAR(100) PRIMARY KEY)

	DECLARE @SYSROLE TABLE (ROLE_NAME VARCHAR(100) PRIMARY KEY)

	INSERT INTO @RL
		SELECT DISTINCT RL_ROLE
		FROM Security.RoleTreeSelect(@RL_ID)
		WHERE RL_ROLE <> ''

	INSERT INTO @SYSROLE
		SELECT DISTINCT c.name AS ROLE_NAME
		FROM
				sys.database_role_members a INNER JOIN
				sys.database_principals b ON a.member_principal_id = b.principal_id INNER JOIN
				Security.UserLast ON US_LOGIN = b.[name] INNER JOIN
				sys.database_principals c ON c.principal_id = role_principal_id
			WHERE b.[type] IN ('S', 'U') AND US_LOGIN = @US_LOGIN
				AND c.[type] = 'R'


	IF NOT EXISTS
		(
			SELECT *
			FROM
				(
					SELECT RL_ROLE
					FROM @RL
				) AS ROLES INNER JOIN
				(
					SELECT ROLE_NAME
					FROM @SYSROLE
				) AS USERROLES ON ROLE_NAME = RL_ROLE
		)
	BEGIN
		--пользователь не включен ни в какую из ролей
		SET @RESULT = 1
	END
	ELSE IF NOT EXISTS
		(
			SELECT RL_ROLE
			FROM @RL

			EXCEPT

			SELECT ROLE_NAME
			FROM @SYSROLE
		)
	BEGIN
		--включен во все подроли
		SET @RESULT = 2
	END
	ELSE IF EXISTS
		(
			SELECT ROLE_NAME
			FROM @SYSROLE
		)
	BEGIN
		--включен в часть ролей
		SET @RESULT = 3
	END

	RETURN @RESULT
END
GO
