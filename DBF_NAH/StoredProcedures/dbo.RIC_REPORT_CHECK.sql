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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		-- ���� ����, �� 1, ����� 0
		IF EXISTS (SELECT VRH_ID FROM dbo.VMIReportHistoryTable WHERE VRH_ID_PERIOD=@periodid)
			SELECT 1 AS RES
		ELSE
			SELECT 0 AS RES

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[RIC_REPORT_CHECK] TO rl_vmi_report_w;
GO
