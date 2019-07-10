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

CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_EDIT] 
	@contractid INT,
	@contractnumber VARCHAR(500),
	@contracttypeid SMALLINT,
	@contractdate SMALLDATETIME,
	@contractbegin SMALLDATETIME,
	@contractend SMALLDATETIME,
	@pay SMALLINT,
	@kind SMALLINT,	
	@active BIT,
	@ident	nvarchar(128)
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.ContractTable 
	SET CO_NUM = @contractnumber, 
		CO_ID_TYPE = @contracttypeid, 
		CO_DATE = @contractdate, 
		CO_BEG_DATE = @contractbegin, 
		CO_END_DATE = @contractend,
		CO_ID_PAY = @pay,
		CO_ID_KIND = @kind,
		CO_ACTIVE	= @active,
		CO_IDENT = @ident
	WHERE CO_ID = @contractid

	SET NOCOUNT OFF
END


