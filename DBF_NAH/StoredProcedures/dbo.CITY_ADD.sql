USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[CITY_ADD]
	@cityname VARCHAR(100),
	@cityprefix VARCHAR(50),
	@phone VARCHAR(50),
	@regionid INT,
	@areaid INT,
	@countryid INT,
	@region TINYINT,
	@active BIT = 1,
	@base SMALLINT = NULL,
	--@oldcode INT = NULL,
	@returnvalue BIT = 1

AS

BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.CityTable
						(
							CT_PREFIX, CT_NAME, CT_PHONE, CT_ID_RG, CT_ID_AREA,
							CT_ID_COUNTRY, CT_REGION, CT_ACTIVE, /*CT_OLD_CODE, */CT_ID_BASE
						)
	VALUES (
			@cityprefix, @cityname, @phone, @regionid,
			@areaid, @countryid, @region, @active, /*@oldcode, */@base
			)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END







GO
GRANT EXECUTE ON [dbo].[CITY_ADD] TO rl_city_w;
GO