USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[DISTR_DOC_SELECT]
	@distrid INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		DOC_ID, DOC_NAME, 
		DD_ID, ISNULL(DD_PRINT, 1) AS DD_PRINT, 
		GD_ID, GD_NAME, 
		UN_ID, UN_NAME
	FROM 	
		dbo.DistrDocumentView
	WHERE DIS_ID = @distrid	--AND ISNULL(DD_ID_DOC, DOC_ID) = DOC_ID
END	









