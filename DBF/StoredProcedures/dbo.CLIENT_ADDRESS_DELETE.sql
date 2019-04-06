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

CREATE PROCEDURE [dbo].[CLIENT_ADDRESS_DELETE] 
  @addressid int

AS

BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.ClientAddressTable WHERE CA_ID = @addressid

	SET NOCOUNT OFF
END


