USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 23.09.2008
Описание:	  Возвращает ID типа сети с указанным 
				  кол-вом станций. 
*/

CREATE PROCEDURE [dbo].[SYSTEM_NET_COUNT_CHECK_COUNT] 
	@netcount INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT SNC_ID
	FROM dbo.SystemNetCountTable
	WHERE SNC_NET_COUNT = @netcount

	SET NOCOUNT OFF
END