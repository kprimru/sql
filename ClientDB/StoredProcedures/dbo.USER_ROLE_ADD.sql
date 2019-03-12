USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[USER_ROLE_ADD]
	@USER   VARCHAR(128),
	@ROLE	VARCHAR(128),
	@MODE	INT = 0,
	@ADM    INT = 0
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ERROR VARCHAR(MAX)	
	IF (CHARINDEX('''', @USER) <> 0) OR 
       (CHARINDEX('''', @ROLE) <> 0)
	BEGIN
		SET @ERROR = '��� ������������ ��� ���� �������� ������������� ������� (�������)'

		RAISERROR (@ERROR, 16, 1)

		RETURN
	END
	IF @MODE = 0 
	BEGIN
		EXEC sp_addrolemember @ROLE, @USER 
		if @ADM =1 EXEC ('master..sp_addsrvrolemember ['+@USER+'], [securityadmin]');  
	END
	ELSE BEGIN
		EXEC sp_droprolemember  @ROLE, @USER 
		if @ADM =1 EXEC ('master..sp_dropsrvrolemember ['+@USER+'], [securityadmin]');  
	END	
END