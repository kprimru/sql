USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[FINANCING_TO_CLIENT_SELECT]
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

		DECLARE @XML VARCHAR(MAX)

		--SET @XML = CONVERT(VARCHAR(MAX), '<?xml version="1.0" encoding="windows-1251"?><dbf_data>') +
		SET @XML = CONVERT(VARCHAR(MAX), '<dbf_data>') +
			+
			CONVERT(VARCHAR(MAX),
				(
					SELECT SYS_REG_NAME AS s, DIS_NUM AS d, DIS_COMP_NUM AS c, CONVERT(NVARCHAR(32), PR_DATE, 112) AS m, BD_TOTAL_PRICE AS p
					FROM dbo.BillAllIXView WITH(NOEXPAND)
					WHERE SYS_REG_NAME <> '-'
					ORDER BY SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE FOR XML PATH ('i'), ROOT('bill')
				))
			+
			CONVERT(VARCHAR(MAX),
				(
					SELECT SYS_REG_NAME AS s, DIS_NUM AS d, DIS_COMP_NUM AS c, CONVERT(NVARCHAR(32), PR_DATE, 112) AS m, AD_TOTAL_PRICE AS p
					FROM dbo.ActAllIXView WITH(NOEXPAND)
					WHERE SYS_REG_NAME <> '-'
					ORDER BY SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE FOR XML PATH ('i'), ROOT('act')
				))
			+
			CONVERT(VARCHAR(MAX),
				(
					SELECT SYS_REG_NAME AS s, DIS_NUM AS d, DIS_COMP_NUM AS c, CONVERT(NVARCHAR(32), PR_DATE, 112) AS m, ID_PRICE AS p
					FROM dbo.IncomeAllIXView WITH(NOEXPAND)
					WHERE SYS_REG_NAME <> '-'
					ORDER BY SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE FOR XML PATH ('i'), ROOT('income')
				)) + CONVERT(VARCHAR(MAX), '</dbf_data>')

		--SET @XML = REPLACE(@XML, '<i>', CHAR(13) + '	<i>')
		--SET @XML = REPLACE(@XML, '</i>', '</i>')

		SELECT @XML AS DATA

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[FINANCING_TO_CLIENT_SELECT] TO rl_report_act_r;
GO
