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

CREATE PROCEDURE [dbo].[REPORT_FIELD_GET]  
AS
BEGIN
	SET NOCOUNT ON;
    
	SELECT RF_ID, RF_NAME, RF_CAPTION, RF_ORDER 
	FROM dbo.ReportFieldTable
	ORDER BY RF_ORDER
	
	SET NOCOUNT OFF    
END




