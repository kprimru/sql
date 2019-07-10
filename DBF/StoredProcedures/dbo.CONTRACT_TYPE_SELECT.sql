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

CREATE PROCEDURE [dbo].[CONTRACT_TYPE_SELECT]   
	@active BIT = NULL
AS

BEGIN
	SET NOCOUNT ON

	SELECT CTT_ID, CTT_NAME 
	FROM dbo.ContractTypeTable 
	WHERE CTT_ACTIVE = ISNULL(@active, CTT_ACTIVE)
	ORDER BY CTT_NAME

	SET NOCOUNT OFF
END



