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

ALTER PROCEDURE [dbo].[REPORT_TEMPLATE_GET]
	@reporttemplateid INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT	RT_NAME,		--RT_TEXT,
				RT_ID_REPORT_TYPE, RTY_NAME,
				RT_LIST_STATUS, dbo.REF_GET_NAME_BY_ID_LIST('DISTR_STATUS', RT_LIST_STATUS) AS RT_STATUS_NAME,
				RT_LIST_SUBHOST, dbo.REF_GET_NAME_BY_ID_LIST('SUBHOST', RT_LIST_SUBHOST) AS RT_SUBHOST_NAME,
				RT_LIST_SYSTEM, dbo.REF_GET_NAME_BY_ID_LIST('SYSTEM', RT_LIST_SYSTEM) AS RT_SYSTEM_NAME,
				RT_LIST_SYSTYPE, dbo.REF_GET_NAME_BY_ID_LIST('SYSTEM_TYPE', RT_LIST_SYSTYPE) AS RT_SYSTEM_TYPE_NAME,
				RT_LIST_NETTYPE, dbo.REF_GET_NAME_BY_ID_LIST('SYSTEM_NET', RT_LIST_NETTYPE) AS RT_SYSTEM_NET_NAME,
				RT_LIST_PERIOD, dbo.REF_GET_NAME_BY_ID_LIST('PERIOD', RT_LIST_PERIOD) AS RT_PERIOD_NAME,
				RT_LIST_TECHTYPE, dbo.REF_GET_NAME_BY_ID_LIST('TECHNOL_TYPE', RT_LIST_TECHTYPE) AS RT_TECH_TYPE_NAME,
				RT_TOTALRIC,
				RT_TOTALCOUNT

		FROM	dbo.ReportTemplateTable	A	LEFT JOIN
				dbo.ReportTypeTable		B	ON A.RT_ID_REPORT_TYPE=B.RTY_ID

		WHERE RT_ID = @reporttemplateid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[REPORT_TEMPLATE_GET] TO rl_report_r;
GO
