USE [DBF]
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

CREATE PROCEDURE [dbo].[REPORT_TEMPLATE_DELETE]
	@reporttemplateid INT
AS
BEGIN
	SET NOCOUNT ON;
    
    DELETE FROM dbo.ReportTemplateTable 
    WHERE RT_ID = @reporttemplateid
END





