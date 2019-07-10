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

CREATE PROCEDURE [dbo].[AREA_CHECK_NAME] 
	@areaname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT AR_ID 
	FROM dbo.AreaTable 
	WHERE AR_NAME = @areaname

	SET NOCOUNT OFF
END