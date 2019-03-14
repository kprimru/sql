USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
Автор:		  Денисов Алексей
Дата создания: 06.11.2008
Описание:	  Проверить уникальность подхоста 
               и города
*/

CREATE PROCEDURE [dbo].[SUBHOST_CITY_CHECK] 
	@subhostid SMALLINT,
	@cityid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	SELECT SC_ID
	FROM dbo.SubhostCityTable
	WHERE SC_ID_SUBHOST = @subhostid AND SC_ID_CITY = @cityid

	SET NOCOUNT OFF
END