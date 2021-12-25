﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLE_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT * FROM Security.Roles WHERE RL_ID_MASTER = @ID)
	BEGIN
		--Есть подчиненные роли
		DECLARE LIST CURSOR LOCAL FOR
			SELECT RL_ID
			FROM Security.Roles
			WHERE RL_ID_MASTER = @ID

		OPEN LIST

		DECLARE @RL_ID UNIQUEIDENTIFIER

		FETCH NEXT FROM LIST INTO @RL_ID

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC Security.ROLE_DELETE @RL_ID

			FETCH NEXT FROM LIST INTO @RL_ID
		END

		CLOSE LIST
		DEALLOCATE LIST
	END
	ELSE
	BEGIN
		-- нет подчиненных ролей
		DECLARE @ROLE VARCHAR(100)

		SELECT @ROLE = RL_ROLE
		FROM Security.Roles
		WHERE RL_ID = @ID

		DELETE FROM Security.Roles WHERE RL_ID = @ID

		IF @ROLE <> ''
			EXEC ('DROP ROLE [' + @ROLE + ']')
	END
END
GO
