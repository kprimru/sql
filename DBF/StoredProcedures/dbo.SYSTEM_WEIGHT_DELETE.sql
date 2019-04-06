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

CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_DELETE] 
	@swid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.SystemWeightTable
	WHERE SW_ID = @swid

	SET NOCOUNT OFF
END