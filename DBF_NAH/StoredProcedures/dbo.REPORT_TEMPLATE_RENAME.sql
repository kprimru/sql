USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.10.2008
��������:	  ������������� �����. �������
               ����� �������� ������ �
               ��������� �����
*/

ALTER PROCEDURE [dbo].[REPORT_TEMPLATE_RENAME]
	@reporttemplateid INT,
	@reporttemplatename VARCHAR(150)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE dbo.ReportTemplateTable
    SET RT_NAME = @reporttemplatename
    WHERE RT_ID = @reporttemplateid
END






GO
GRANT EXECUTE ON [dbo].[REPORT_TEMPLATE_RENAME] TO rl_report_w;
GO