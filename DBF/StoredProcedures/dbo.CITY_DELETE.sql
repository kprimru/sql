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

CREATE PROCEDURE [dbo].[CITY_DELETE] 
	@cityid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.CityTable 
	WHERE CT_ID = @cityid

	SET NOCOUNT OFF
END
