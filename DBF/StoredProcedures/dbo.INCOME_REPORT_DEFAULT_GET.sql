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
CREATE PROCEDURE [dbo].[INCOME_REPORT_DEFAULT_GET]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ORG_ID, ORG_PSEDO
	FROM dbo.OrganizationTable
	WHERE ORG_PSEDO = '�����'
END