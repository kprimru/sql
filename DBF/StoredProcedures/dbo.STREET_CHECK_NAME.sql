USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает ID улицы с указанным 
               названием в указанном населенном 
               пункте. 
*/

CREATE PROCEDURE [dbo].[STREET_CHECK_NAME] 
	@streetname VARCHAR(100),
	@cityid SMALLINT,
	@prefix VARCHAR(10) = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT ST_ID
	FROM dbo.StreetTable
	WHERE ST_NAME = @streetname AND ST_ID_CITY = @cityid
		AND ST_PREFIX = @prefix

	SET NOCOUNT OFF
END