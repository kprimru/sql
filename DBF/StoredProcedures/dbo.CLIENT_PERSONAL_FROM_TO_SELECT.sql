USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:			коллектив авторов
Дата создания:	26.02.2009
Описание:		Получить всех сотрудников
					из всех ТО клиента
*/

CREATE PROCEDURE [dbo].[CLIENT_PERSONAL_FROM_TO_SELECT] 
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT DISTINCT	TP_ID, TP_SURNAME, TP_NAME, TP_OTCH, POS_NAME, RP_NAME, TO_NAME
		FROM		dbo.TOPersonalView
		WHERE		TO_ID_CLIENT=@clientid

	SET NOCOUNT OFF
END