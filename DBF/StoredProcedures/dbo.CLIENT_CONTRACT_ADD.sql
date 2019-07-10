USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_ADD] 
	@clientid INT,
	@contractnumber VARCHAR(500),
	@contracttypeid SMALLINT,
	@contractdate DATETIME,
	@contractbegin DATETIME,
	@contractend DATETIME,
	@pay SMALLINT,
	@kind SMALLINT,
	@active BIT,
	@ident NVARCHAR(128),
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ContractTable(CO_ID_CLIENT, CO_NUM, CO_ID_TYPE, CO_DATE, CO_BEG_DATE, CO_END_DATE, CO_ID_PAY, CO_ID_KIND,
							  CO_ACTIVE, CO_IDENT) 
	VALUES (@clientid, @contractnumber, @contracttypeid, @contractdate, @contractbegin, @contractend, @pay, @kind,
			@active, @ident)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END


