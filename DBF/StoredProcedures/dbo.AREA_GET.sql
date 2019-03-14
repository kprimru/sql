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

CREATE PROCEDURE [dbo].[AREA_GET] 
  @areaid SMALLINT = NULL
AS

BEGIN
	SET NOCOUNT ON
	
	SELECT AR_ID, AR_NAME, AR_ACTIVE
	FROM dbo.AreaTable 
	WHERE AR_ID = @areaid   

	SET NOCOUNT OFF
END





