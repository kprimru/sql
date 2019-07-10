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

CREATE PROCEDURE [dbo].[AREA_SELECT]   
	@active BIT = NULL
AS

BEGIN
	SET NOCOUNT ON


	SELECT AR_ID, AR_NAME  
	FROM dbo.AreaTable 
	WHERE AR_ACTIVE = ISNULL(@active, AR_ACTIVE)
	ORDER BY AR_NAME

	SET NOCOUNT OFF
END






