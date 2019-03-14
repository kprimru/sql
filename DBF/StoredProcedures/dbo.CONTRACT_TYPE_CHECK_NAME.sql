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

CREATE PROCEDURE [dbo].[CONTRACT_TYPE_CHECK_NAME] 
	@contracttypename VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT CTT_ID
	FROM dbo.ContractTypeTable
	WHERE CTT_NAME = @contracttypename

	SET NOCOUNT OFF
END