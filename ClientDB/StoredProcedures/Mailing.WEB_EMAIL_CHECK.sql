USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Mailing].[WEB_EMAIL_CHECK]
	@EMAIL	NVARCHAR(64),
	@MSG	NVARCHAR(256) OUTPUT,
	@STATUS	SMALLINT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SET @STATUS = 0
	SET @MSG = ''

	IF @EMAIL = ''
	BEGIN
		SET @STATUS = 1
		SET @MSG = '�� ������ e-mail'
		
		RETURN
	END
	
	IF CHARINDEX('@', @EMAIL) = 0
	BEGIN
		SET @STATUS = 1
		SET @MSG = '� ������ ����������� ������ "@"'
		
		RETURN
	END
	
	IF CHARINDEX(' ', @EMAIL) <> 0
	BEGIN
		SET @STATUS = 1
		SET @MSG = '� ������ ����������� �������'
		
		RETURN
	END
	
	IF @EMAIL LIKE '%[�-�]%' OR @EMAIL LIKE '%[�-�]%'
	BEGIN
		SET @STATUS = 1
		SET @MSG = '� ������ ����������� ������� �����'
		
		RETURN
	END
END
