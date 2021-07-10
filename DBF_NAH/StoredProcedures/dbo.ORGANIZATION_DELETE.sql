USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ������� �� ����������� �������������
               ����������� � ��������� �����
*/

ALTER PROCEDURE [dbo].[ORGANIZATION_DELETE]
	@organizationid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.OrganizationTable
	WHERE ORG_ID = @organizationid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[ORGANIZATION_DELETE] TO rl_organization_d;
GO