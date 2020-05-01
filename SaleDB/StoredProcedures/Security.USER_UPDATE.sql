USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@LOGIN	NVARCHAR(128),
	@NAME	NVARCHAR(128),
	@PASS	NVARCHAR(128),
	@AUTH	TINYINT,
	@GROUPS	NVARCHAR(MAX)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		UPDATE Security.Users
		SET NAME	=	@NAME,
			LAST	=	GETDATE()
		WHERE ID = @ID

		DECLARE @GRP NVARCHAR(256)

		DECLARE GR CURSOR LOCAL FOR
			SELECT c.name
			FROM
				sys.database_principals a
				INNER JOIN sys.database_role_members b ON a.principal_id = b.member_principal_id
				INNER JOIN sys.database_principals c ON c.principal_id = b.role_principal_id
				INNER JOIN Security.RoleGroup d ON d.NAME = c.name
			WHERE a.name = @LOGIN
				AND NOT EXISTS
					(
						SELECT *
						FROM Common.TableGUIDFromXML(@GROUPS) a
						WHERE a.ID = d.ID
					)

		OPEN GR

		FETCH NEXT FROM GR INTO @GRP

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC sp_droprolemember @GRP, @LOGIN

			FETCH NEXT FROM GR INTO @GRP
		END

		CLOSE GR
		DEALLOCATE GR

		DECLARE GR CURSOR LOCAL FOR
			SELECT NAME
			FROM
				Common.TableGUIDFromXML(@GROUPS) a
				INNER JOIN Security.RoleGroup b ON a.ID = b.ID
			WHERE NOT EXISTS
				(
					SELECT *
					FROM
						sys.database_principals z
						INNER JOIN sys.database_role_members y ON z.principal_id = y.member_principal_id
						INNER JOIN sys.database_principals x ON x.principal_id = y.role_principal_id
					WHERE z.name = @LOGIN AND b.name = x.name
				)

		OPEN GR

		FETCH NEXT FROM GR INTO @GRP

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC sp_addrolemember @GRP, @LOGIN

			FETCH NEXT FROM GR INTO @GRP
		END

		CLOSE GR
		DEALLOCATE GR
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GRANT EXECUTE ON [Security].[USER_UPDATE] TO rl_user_w;
GO