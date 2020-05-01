USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_ROLES_SET]
	@US_ID	UNIQUEIDENTIFIER,
	@RL_ID	VARCHAR(MAX),
	@MODE	VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE ROLES CURSOR LOCAL FOR
		SELECT ID
		FROM Common.TableFromList(@RL_ID, ',')

	OPEN ROLES

	DECLARE @ROLE_ID UNIQUEIDENTIFIER

	FETCH NEXT FROM ROLES INTO @ROLE_ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC Security.USER_ROLE_SET @US_ID, @ROLE_ID, @MODE

		FETCH NEXT FROM ROLES INTO @ROLE_ID
	END

	CLOSE ROLES
	DEALLOCATE ROLES
END
