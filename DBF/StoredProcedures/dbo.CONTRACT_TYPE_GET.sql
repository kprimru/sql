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

CREATE PROCEDURE [dbo].[CONTRACT_TYPE_GET] 
	@contracttypeid SMALLINT = NULL  
AS

BEGIN
	SET NOCOUNT ON

	SELECT CTT_ID, CTT_NAME, CTT_ACTIVE
	FROM dbo.ContractTypeTable 
	WHERE CTT_ID = @contracttypeid 	

	SET NOCOUNT OFF
END



