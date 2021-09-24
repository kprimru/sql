USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Common].[ARM_MESSAGE]
	@LOGIN	VARCHAR(128),
	@ROLE	VARCHAR(128),
	@MSG	VARCHAR(2048)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF DB_ID('ARM') IS NULL
		RETURN


	IF @LOGIN IS NOT NULL
	BEGIN
		DECLARE @LG	VARCHAR(128)

		DECLARE RL CURSOR LOCAL FOR
			SELECT lg.NAME
			FROM
				sys.database_principals AS us INNER JOIN
				sys.database_role_members AS rm ON rm.member_principal_id = us.principal_id INNER JOIN
				sys.database_principals AS rl ON rm.role_principal_id = rl.principal_id INNER JOIN
				sys.server_principals AS lg ON lg.sid = us.sid
			WHERE rl.name = @ROLE

		OPEN RL

		FETCH NEXT FROM RL INTO  @LG

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC ARM.dbo.ARM_MESSAGE_ADD 3, @LG, @MSG

			FETCH NEXT FROM RL INTO  @LG
		END

		CLOSE RL
		DEALLOCATE RL
	END
	ELSE
		EXEC ARM.dbo.ARM_MESSAGE_ADD 3, @LOGIN, @MSG
END
GO
GRANT EXECUTE ON [Common].[ARM_MESSAGE] TO public;
GO
