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

CREATE PROCEDURE [dbo].[COUNTRY_DELETE] 
	@countryid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.CountryTable WHERE CNT_ID = @countryid

	SET NOCOUNT OFF
END