USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		  Денисов Алексей
Дата создания: 10.05.2012
Описание:	  Добавить квартал в справочник
*/
CREATE PROCEDURE [dbo].[QUARTER_ADD] 
	@name	VARCHAR(50),
	@begin	SMALLDATETIME,
	@end	SMALLDATETIME,
	@active BIT = 1,
	@returnvalue BIT = 1  
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.Quarter(
			QR_NAME, QR_BEGIN, QR_END, QR_ACTIVE) 
	VALUES (@NAME, @begin, @end, @active)

	IF @returnvalue = 1
	  SELECT SCOPE_IDENTITY() AS NEW_IDEN
END
