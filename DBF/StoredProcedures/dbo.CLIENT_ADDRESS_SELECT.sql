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

CREATE PROCEDURE [dbo].[CLIENT_ADDRESS_SELECT] 
	@clientid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT AT_NAME, CA_STR, CA_ID, CA_INDEX, CA_HOME, ST_NAME, CT_NAME
	FROM dbo.ClientAddressView
	WHERE CA_ID_CLIENT = @clientid
	ORDER BY AT_NAME, ST_NAME
    
	SET NOCOUNT OFF
END




