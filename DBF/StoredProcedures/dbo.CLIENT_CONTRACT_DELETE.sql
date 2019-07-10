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

CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_DELETE] 
	@contractid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.ContractTable 
	WHERE CO_ID = @contractid

	SET NOCOUNT OFF
END

