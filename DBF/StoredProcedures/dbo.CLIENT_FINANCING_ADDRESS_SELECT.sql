USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
Автор:			Денисов Алексей
Описание:		Список адресов и их шаблонов в финансовых документах клиента
Дата:			17.07.2009
*/
CREATE PROCEDURE [dbo].[CLIENT_FINANCING_ADDRESS_SELECT] 
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT CFA_ID, FAT_ID, FAT_NOTE, ATL_ID, ATL_CAPTION, ADDR_STRING
	FROM dbo.ClientFinancingAddressView
	WHERE CL_ID = @clientid
	ORDER BY FAT_NOTE
END