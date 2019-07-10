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

CREATE PROCEDURE [dbo].[CLIENT_ADDRESS_CHECK_TYPE] 
  @clientid int,
  @addresstypeid int

AS

BEGIN
	SET NOCOUNT ON

	SELECT CA_ID 
	FROM dbo.ClientAddressTable 
	WHERE CA_ID_CLIENT = @clientid AND CA_ID_TYPE = @addresstypeid

	SET NOCOUNT OFF
END





