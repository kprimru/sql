USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[REPORT_TEMPLATE_SELECT]  
AS
BEGIN
	SET NOCOUNT ON;
    
	SELECT RT_ID, RT_NAME		--, RT_TEXT
	FROM dbo.ReportTemplateTable
	ORDER BY RT_NAME
    
	SET NOCOUNT OFF 
END





