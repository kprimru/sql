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
		SET @MSG = 'Не введен e-mail'
		
		RETURN
	END
	
	IF CHARINDEX('@', @EMAIL) = 0
	BEGIN
		SET @STATUS = 1
		SET @MSG = 'В адресе отсутствует символ "@"'
		
		RETURN
	END
	
	IF CHARINDEX(' ', @EMAIL) <> 0
	BEGIN
		SET @STATUS = 1
		SET @MSG = 'В адресе присутстуют пробелы'
		
		RETURN
	END
	
	IF @EMAIL LIKE '%[а-я]%' OR @EMAIL LIKE '%[А-Я]%'
	BEGIN
		SET @STATUS = 1
		SET @MSG = 'В адресе присутстуют русские буквы'
		
		RETURN
	END
END
