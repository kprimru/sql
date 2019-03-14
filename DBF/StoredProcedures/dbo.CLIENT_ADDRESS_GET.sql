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

CREATE PROCEDURE [dbo].[CLIENT_ADDRESS_GET] 
	@clientaddressid INT
AS

BEGIN
	SET NOCOUNT ON

	SELECT 
			CA_ID, CA_INDEX, CA_HOME, CA_STR, CA_FREE, ST_NAME, 
			ST_ID, CT_NAME, CT_ID, AT_ID, AT_NAME, ATL_ID, ATL_CAPTION
	FROM dbo.ClientAddressView
	WHERE CA_ID = @clientaddressid

	SET NOCOUNT OFF
END




