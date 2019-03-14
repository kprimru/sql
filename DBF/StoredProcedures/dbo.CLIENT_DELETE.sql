USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	/*
Автор:		  Денисов Алексей
Описание:	  
*/
CREATE PROCEDURE [dbo].[CLIENT_DELETE] 
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.ClientFinancing
	WHERE ID_CLIENT = @clientid

	DELETE 
	FROM dbo.DistrDeliveryHistoryTable
	WHERE DDH_ID_OLD_CLIENT = @clientid OR DDH_ID_NEW_CLIENT = @clientid

	DELETE
	FROM dbo.ClientDocumentSettingsTable
	WHERE CDS_ID_CLIENT = @clientid

	DELETE 
	FROM dbo.ClientFinancingAddressTable
	WHERE CFA_ID_CLIENT = @clientid

	DELETE 
	FROM dbo.ClientTable 
	WHERE CL_ID = @clientid

	SET NOCOUNT OFF
END