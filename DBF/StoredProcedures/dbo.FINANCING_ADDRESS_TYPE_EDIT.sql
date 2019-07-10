USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:			������� �������
���� ��������:	3 July 2009
��������:	  

*/

CREATE PROCEDURE [dbo].[FINANCING_ADDRESS_TYPE_EDIT] 
	@fatid SMALLINT,
	@addrtypeid TINYINT,
	@text VARCHAR(50),
	@active BIT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.FinancingAddressTypeTable 
	SET	FAT_ID_ADDR_TYPE = @addrtypeid,
		FAT_TEXT = @text,
		FAT_ACTIVE = @active

	WHERE FAT_ID = @fatid

	SET NOCOUNT OFF
END



