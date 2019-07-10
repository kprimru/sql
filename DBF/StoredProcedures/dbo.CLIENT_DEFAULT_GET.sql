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

CREATE PROCEDURE [dbo].[CLIENT_DEFAULT_GET]	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT (SELECT MAX(CL_NUM) + 1 FROM ClientTable) AS CL_NUM, ORG_ID, ORG_PSEDO, SH_ID, SH_SHORT_NAME, '������' AS CL_FOUND
	FROM dbo.OrganizationTable, dbo.SubhostTable
	WHERE ORG_ID = 1 AND SH_ID = 1
END
