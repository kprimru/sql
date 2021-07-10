USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[REPORT_HEADER_GET]
	@prid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT	'����� ��� ' + (SELECT dbo.GET_SETTING('REPORT_RIC_NUM')) +
			' �� �������� ��������������� �� ' + CONVERT(VARCHAR, DATENAME(mm, PR_DATE)) + ' ' + CONVERT(VARCHAR, DATENAME(yyyy, PR_DATE)) +
           ' ����, ������������� ' + (SELECT dbo.GET_SETTING('REPORT_NAME')) AS RPT_HEADER
	FROM dbo.PeriodTable
	WHERE PR_ID = @prid
END













GO
GRANT EXECUTE ON [dbo].[REPORT_HEADER_GET] TO rl_all_r;
GRANT EXECUTE ON [dbo].[REPORT_HEADER_GET] TO rl_vmi_report_r;
GO