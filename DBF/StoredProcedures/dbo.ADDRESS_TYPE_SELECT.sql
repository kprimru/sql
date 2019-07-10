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

CREATE PROCEDURE [dbo].[ADDRESS_TYPE_SELECT]   
	@active BIT = NULL
AS

BEGIN
	SET NOCOUNT ON

	SELECT AT_ID, AT_NAME
	FROM dbo.AddressTypeTable
	WHERE AT_ACTIVE = ISNULL(@active, AT_ACTIVE) 
	ORDER BY AT_NAME

	SET NOCOUNT OFF
END





