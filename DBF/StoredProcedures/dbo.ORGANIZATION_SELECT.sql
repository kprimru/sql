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

CREATE PROCEDURE [dbo].[ORGANIZATION_SELECT] 
    @active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT ORG_FULL_NAME, ORG_SHORT_NAME, ORG_ID , ORG_PSEDO
	FROM dbo.OrganizationTable 
	WHERE ORG_ACTIVE = ISNULL(@active, ORG_ACTIVE)
	ORDER BY ORG_FULL_NAME, ORG_SHORT_NAME

	SET NOCOUNT OFF
END




