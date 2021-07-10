USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������
��������:		��������: ���������� �� ��� � ������� ���-������� ������
				�� ��������� ������.
����:			10-06-2009
*/

ALTER PROCEDURE [dbo].[RIC_REPORT_CHECK]
	@periodid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	-- ���� ����, �� 1, ����� 0
	IF EXISTS (SELECT VRH_ID FROM dbo.VMIReportHistoryTable WHERE VRH_ID_PERIOD=@periodid)
		SELECT 1 AS RES
	ELSE
		SELECT 0 AS RES

	SET NOCOUNT OFF
END





GO
GRANT EXECUTE ON [dbo].[RIC_REPORT_CHECK] TO rl_vmi_report_w;
GO