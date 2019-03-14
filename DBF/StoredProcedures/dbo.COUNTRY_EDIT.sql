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

CREATE PROCEDURE [dbo].[COUNTRY_EDIT] 
	@countryid SMALLINT,
	@countryname VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.CountryTable 
	SET CNT_NAME = @countryname, 
		CNT_ACTIVE = @active
	WHERE CNT_ID = @countryid

	SET NOCOUNT OFF
END