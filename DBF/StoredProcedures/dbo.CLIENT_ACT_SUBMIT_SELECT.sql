USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[CLIENT_ACT_SUBMIT_SELECT]
	-- Список параметров процедуры	
AS
BEGIN
	-- SET NOCOUNT ON обязателен для использования в хранимых процедурах.
	-- Позволяет избежать лишней информации и сетевого траффика.

	SET NOCOUNT ON;

	-- Текст процедуры ниже
	SELECT CL_ID, CL_PSEDO, CL_FULL_NAME
	FROM dbo.ClientTable
	WHERE EXISTS
		(
			SELECT * 
			FROM dbo.ActDistrView
			WHERE ACT_ID_CLIENT = CL_ID
		)
	ORDER BY CL_PSEDO, CL_ID
END


