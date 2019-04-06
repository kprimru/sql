USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 06.11.2008
Описание:	  Удалить подхосту город 
                сбытовой территории
*/

CREATE PROCEDURE [dbo].[SUBHOST_CITY_DELETE] 
	@subhostcityid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.SubhostCityTable
	WHERE SC_ID = @subhostcityid

	SET NOCOUNT OFF
END