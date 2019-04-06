USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			
Описание:		Скопировать сотрудника ТО в таблицу
					сотрудников клиента
Дата:			10-July-2009
*/

CREATE PROCEDURE [dbo].[TO_PERSONAL_COPY_FROM_TO] 
	@toperid INT,
	@toid INT,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO	dbo.TOPersonalTable(
		TP_ID_TO, TP_SURNAME, TP_NAME, TP_OTCH, TP_ID_POS, TP_ID_RP, TP_PHONE)
		SELECT
			@toid, TP_SURNAME, TP_NAME, TP_OTCH, TP_ID_POS, TP_ID_RP, TP_PHONE
		FROM	dbo.TOPersonalTable
		WHERE	TP_ID=@toperid

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN


	SET NOCOUNT OFF
END

