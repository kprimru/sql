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

CREATE PROCEDURE [dbo].[ADDRESS_TYPE_EDIT] 
	@addresstypeid TINYINT,
	@addresstypename VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.AddressTypeTable 
	SET AT_NAME = @addresstypename, 
		AT_ACTIVE = @active 
	WHERE AT_ID = @addresstypeid

	SET NOCOUNT OFF
END