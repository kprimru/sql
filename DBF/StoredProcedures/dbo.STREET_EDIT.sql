USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Изменить данные об улице 
               с указанным кодом
*/

CREATE PROCEDURE [dbo].[STREET_EDIT] 
	@streetid INT,
	@streetname VARCHAR(150),
	@streetprefix VARCHAR(10),
	@streetsuffix VARCHAR(10),
	@cityid SMALLINT,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.StreetTable 
	SET ST_NAME = @streetname, 
		ST_ID_CITY = @cityid, 
		ST_PREFIX = @streetprefix,
		ST_SUFFIX = @streetsuffix,
		ST_ACTIVE = @active
	WHERE ST_ID = @streetid

	SET NOCOUNT OFF
END