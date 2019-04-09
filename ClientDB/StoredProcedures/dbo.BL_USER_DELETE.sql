USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BL_USER_DELETE]
	@USER varchar(128)
WITH EXECUTE AS OWNER  
AS
BEGIN	
	SET NOCOUNT ON;

    DECLARE @ERROR VARCHAR(MAX)	
	IF (CHARINDEX('''', @USER) <> 0) 
	BEGIN
		SET @ERROR = '��� ������������ ��� ���� �������� ������������� ������� (�������)'

		RAISERROR (@ERROR, 16, 1)

		RETURN
	END
    EXEC('DROP USER [' + @USER +']')

    SET NOCOUNT OFF
END