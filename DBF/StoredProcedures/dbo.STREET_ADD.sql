USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Добавить улицу в справочник
*/

CREATE PROCEDURE [dbo].[STREET_ADD] 
	@streetname VARCHAR(150),
	@streetprefix VARCHAR(10),
	@streetsuffix VARCHAR(10),
	@cityid SMALLINT,
	@active BIT = 1,
	@oldcode INT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.StreetTable (ST_NAME, ST_PREFIX, ST_SUFFIX, ST_ID_CITY, ST_ACTIVE, ST_OLD_CODE) 
	VALUES (@streetname, @streetprefix, @streetsuffix, @cityid, @active, @oldcode)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END