USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[ACT_FACT_ALL_GET]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT AFM_DATE, COUNT(*) AS AFM_COUNT
	FROM dbo.ActFactMasterTable
	GROUP BY AFM_DATE
	ORDER BY AFM_DATE DESC
END


