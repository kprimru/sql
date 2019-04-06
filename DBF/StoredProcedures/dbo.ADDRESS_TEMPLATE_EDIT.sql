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

CREATE PROCEDURE [dbo].[ADDRESS_TEMPLATE_EDIT] 
	@atlid			SMALLINT,
	@name			VARCHAR(50),
	@index			BIT,
	@country		BIT,
	@region			BIT,
	@area			BIT,
	@city_prefix	BIT,
	@city			BIT,
	@str_prefix		BIT,
	@street			BIT,
	@home			BIT,
	@active			BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.AddressTemplateTable
	SET
		ATL_CAPTION = @name,
		ATL_INDEX = @index,
		ATL_COUNTRY = @country,
		ATL_REGION = @region,
		ATL_AREA = @area,
		ATL_CITY_PREFIX = @city_prefix,
		ATL_CITY = @city,
		ATL_STR_PREFIX = @str_prefix,
		ATL_STREET = @street,
		ATL_HOME = @home,
		ATL_ACTIVE = @active
	WHERE ATL_ID = @atlid

	SET NOCOUNT OFF
END

