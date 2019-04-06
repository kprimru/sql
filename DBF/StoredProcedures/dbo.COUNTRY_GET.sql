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

CREATE PROCEDURE [dbo].[COUNTRY_GET] 
	@countryid SMALLINT = NULL,
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT CNT_NAME, CNT_ID, CNT_ACTIVE
	FROM dbo.CountryTable 
	WHERE CNT_ID =  @countryid 

	SET NOCOUNT OFF
END



