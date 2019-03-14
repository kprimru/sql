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

CREATE PROCEDURE [dbo].[COUNTRY_CHECK_NAME] 
	@countryname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT CNT_ID
	FROM dbo.CountryTable
	WHERE CNT_NAME = @countryname

	SET NOCOUNT OFF
END