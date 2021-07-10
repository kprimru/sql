USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.10.2008
��������:	  ������� ����� � ��������� �����.
*/

ALTER PROCEDURE [dbo].[REPORT_TEMPLATE_DELETE]
	@reporttemplateid INT
AS
BEGIN
	SET NOCOUNT ON;

    DELETE FROM dbo.ReportTemplateTable
    WHERE RT_ID = @reporttemplateid
END






GO
GRANT EXECUTE ON [dbo].[REPORT_TEMPLATE_DELETE] TO rl_report_w;
GO