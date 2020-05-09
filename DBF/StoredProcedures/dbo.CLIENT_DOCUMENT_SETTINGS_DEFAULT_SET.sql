USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[CLIENT_DOCUMENT_SETTINGS_DEFAULT_SET]
	@clientid INT
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

		INSERT INTO dbo.ClientDocumentSettingsTable
			(
				CDS_ID_CLIENT, CDS_ACT_CONTRACT, CDS_ACT_POS, CDS_ACT_POS_F,
				CDS_ACT_NAME, CDS_ACT_NAME_F, CDS_BILL_REST, CDS_INS_CONTRACT,
				CDS_INS_NAME
			)
		SELECT
			@clientid,
			'по договору ' AS CDS_ACT_CONTRACT,
			(
				SELECT POS_NAME
				FROM
					dbo.ClientPersonalTable INNER JOIN
					dbo.PositionTable ON PER_ID_POS = POS_ID INNER JOIN
					dbo.ReportPositionTable ON RP_ID = PER_ID_REPORT_POS
				WHERE PER_ID_CLIENT = @clientid
			) AS CDS_ACT_POS,
			(
				SELECT POS_NAME
				FROM
					dbo.ClientPersonalTable INNER JOIN
					dbo.PositionTable ON PER_ID_POS = POS_ID INNER JOIN
					dbo.ReportPositionTable ON RP_ID = PER_ID_REPORT_POS
				WHERE PER_ID_CLIENT = @clientid
			) AS CDS_ACT_POSF,
			CL_FULL_NAME AS CDS_ACT_NAME,
			CL_FULL_NAME AS CDS_ACT_NAMEF,
			0 AS CDS_BILL_REST,
			0 AS CDS_INS_CONTRACT,
			CL_FULL_NAME AS CDS_INS_NAME
		FROM 
			dbo.ClientTable
		WHERE CL_ID = @clientid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_DOCUMENT_SETTINGS_DEFAULT_SET] TO rl_client_w;
GO