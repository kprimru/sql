USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USER_ROLE_PROCESS]
	@USER	NVARCHAR(128),
	@ROLE	NVARCHAR(128),
	@EXIST	BIT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF @EXIST = 1
	BEGIN
		EXEC sp_addrolemember @ROLE, @USER

		IF @ROLE = 'rl_admin'
		BEGIN
			EXEC sp_dropsrvrolemember @USER, 'securityadmin'
			EXEC sp_droprolemember 'db_securityadmin', @USER
			EXEC sp_droprolemember 'db_accessadmin', @USER
		END		
	END
	ELSE IF @EXIST = 0
	BEGIN
		EXEC sp_droprolemember @ROLE, @USER
	
		IF @ROLE = 'rl_admin'
		BEGIN
			EXEC sp_addsrvrolemember @USER, 'securityadmin'
			EXEC sp_addrolemember 'db_securityadmin', @USER
			EXEC sp_addrolemember 'db_accessadmin', @USER
		END
	END
END
