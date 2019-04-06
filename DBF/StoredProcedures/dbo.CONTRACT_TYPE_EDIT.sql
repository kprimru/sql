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

CREATE PROCEDURE [dbo].[CONTRACT_TYPE_EDIT] 
	@contracttypeid SMALLINT,
	@contracttypename VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.ContractTypeTable 
	SET CTT_NAME = @contracttypename, 
		CTT_ACTIVE = @active
	WHERE CTT_ID = @contracttypeid

	SET NOCOUNT OFF
END