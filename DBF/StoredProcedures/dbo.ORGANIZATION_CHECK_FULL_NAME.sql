USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� ID �������������
              ����������� � ��������� 
               ������ ���������. 
*/

CREATE PROCEDURE [dbo].[ORGANIZATION_CHECK_FULL_NAME] 
	@organizationname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT ORG_ID
	FROM dbo.OrganizationTable
	WHERE ORG_FULL_NAME = @organizationname

	SET NOCOUNT OFF
END