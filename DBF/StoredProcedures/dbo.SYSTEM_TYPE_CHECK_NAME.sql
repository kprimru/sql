USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 24.09.2008
Описание:	  Возвращает ID типа системы с 
               указанным названием. 
*/

CREATE PROCEDURE [dbo].[SYSTEM_TYPE_CHECK_NAME] 
	@systemtypename VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON

	SELECT SST_ID
	FROM dbo.SystemTypeTable
	WHERE SST_NAME = @systemtypename

	SET NOCOUNT OFF
END