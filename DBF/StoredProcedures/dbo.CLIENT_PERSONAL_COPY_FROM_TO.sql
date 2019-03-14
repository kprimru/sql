USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:			коллектив авторов
Описание:		Скопировать сотрудника ТО в таблицу
					сотрудников клиента
*/

CREATE PROCEDURE [dbo].[CLIENT_PERSONAL_COPY_FROM_TO] 
	@toperid INT,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO	dbo.ClientPersonalTable(
		PER_ID_CLIENT,	PER_FAM,	PER_NAME,	PER_OTCH,	PER_ID_POS,	PER_ID_REPORT_POS)
		SELECT
			TO_ID_CLIENT, TP_SURNAME,	TP_NAME,	TP_OTCH,	TP_ID_POS,	TP_ID_RP
		FROM	dbo.TOPersonalTable	A	INNER JOIN
				dbo.TOTable			B	ON	A.TP_ID_TO=B.TO_ID
		WHERE	A.TP_ID=@toperid

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN


	SET NOCOUNT OFF
END