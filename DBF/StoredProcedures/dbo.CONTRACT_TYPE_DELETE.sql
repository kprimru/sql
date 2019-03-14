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

CREATE PROCEDURE [dbo].[CONTRACT_TYPE_DELETE] 
	@contracttypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.ContractTypeTable WHERE CTT_ID = @contracttypeid

	SET NOCOUNT OFF
END