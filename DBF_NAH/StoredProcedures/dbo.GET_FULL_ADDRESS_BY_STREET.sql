USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  По коду улицы получить полную строку адреса
*/

ALTER PROCEDURE [dbo].[GET_FULL_ADDRESS_BY_STREET]
	@streetid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @StPrefix VARCHAR(150)
	DECLARE @StName VARCHAR(150)
	DECLARE @CtName VARCHAR(150)
	DECLARE @CtPrefix VARCHAR(150)
	DECLARE @RgName VARCHAR(150)
	DECLARE @ArName VARCHAR(150)
	DECLARE @CntName VARCHAR(150)

	SELECT @StPrefix = ST_PREFIX,
		   @StName = ST_NAME,
		   @CtName= CT_NAME,
		   @CtPrefix = CT_PREFIX,
		   @RgName = RG_NAME,
		   @ArName = AR_NAME,
		   @CntName = CNT_NAME
	FROM dbo.StreetTable a INNER JOIN
		 dbo.CityTable b ON a.ST_ID_CITY = b.CT_ID LEFT OUTER JOIN
		 dbo.RegionTable c ON c.RG_ID = b.CT_ID_RG LEFT OUTER JOIN
		 dbo.AreaTable d ON d.AR_ID = b.CT_ID_AREA LEFT OUTER JOIN
		 dbo.CountryTable e ON e.CNT_ID = b.CT_ID_COUNTRY
	WHERE ST_ID = @streetid

	DECLARE @ResultStr VARCHAR(1000)

	SET @ResultStr = ''


	IF @RgName IS NOT NULL AND @RgName <> '(нет)'
	  SET @ResultStr = @ResultStr + @RgName + ', '

	IF @ArName IS NOT NULL AND @ArName <> '(нет)'
	  SET @ResultStr = @ResultStr + @ArName + ', '

	IF @CtPrefix IS NOT NULL
	  SET @ResultStr = @ResultStr + @CtPrefix

	IF @CtName IS NOT NULL AND @CtName <> '(нет)'
	  SET @ResultStr = @ResultStr + @CtName + ', '

	IF @StPrefix IS NOT NULL
	  SET @ResultStr = @ResultStr + @StPrefix

	IF @StName IS NOT NULL AND @StName <> '(нет)'
	SET @ResultStr = @ResultStr + @StName


	SELECT @CntName AS CNT_NAME, @ResultStr AS AD_STR
END


GO
