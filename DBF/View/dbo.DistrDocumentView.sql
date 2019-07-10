USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DistrDocumentView]
AS
SELECT 
		DIS_ID, DIS_ACTIVE,
		DOC_ID, DOC_NAME, DOC_PSEDO, 
		DD_ID, DD_PRINT, 
		GD_ID, GD_NAME, 
		UN_ID, UN_NAME, UN_OKEI
	FROM 	
		dbo.DistrView CROSS JOIN
		dbo.DocumentTable LEFT OUTER JOIN
		dbo.DistrDocumentTable ON DD_ID_DISTR = DIS_ID AND DD_ID_DOC = DOC_ID LEFT OUTER JOIN
		dbo.GoodTable ON GD_ID = DD_ID_GOOD LEFT OUTER JOIN
		dbo.UnitTable ON UN_ID = DD_ID_UNIT
	--WHERE
		--DIS_ACTIVE = 1
