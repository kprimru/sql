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

CREATE PROCEDURE [dbo].[ADDRESS_TYPE_CHECK_NAME] 
	@addresstypename VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT AT_ID 
	FROM dbo.AddressTypeTable 
	WHERE AT_NAME = @addresstypename

	SET NOCOUNT OFF
END






