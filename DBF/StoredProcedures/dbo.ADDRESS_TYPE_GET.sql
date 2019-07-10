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

CREATE PROCEDURE [dbo].[ADDRESS_TYPE_GET] 
  @addresstypeid TINYINT 
AS

BEGIN
	SET NOCOUNT ON

	SELECT AT_ID, AT_NAME, AT_ACTIVE
	FROM dbo.AddressTypeTable 
	WHERE AT_ID = @addresstypeid   

	SET NOCOUNT OFF
END




