USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[CLIENT_DOCUMENT_SETTINGS_DEFAULT_GET]
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

		SELECT
			'по договору ' AS CDS_ACT_CONTRACT,
			(
				SELECT POS_NAME
				FROM
					dbo.ClientPersonalTable INNER JOIN
					dbo.PositionTable ON PER_ID_POS = POS_ID INNER JOIN
					dbo.ReportPositionTable ON RP_ID = PER_ID_REPORT_POS
				WHERE PER_ID_CLIENT = @clientid
			) AS CDS_ACT_POS,
			CL_FULL_NAME AS CDS_ACT_NAME,
			0 AS CDS_BILL_REST,
			0 AS CDS_INS_CONTRACT,
			CL_FULL_NAME AS CDS_INS_NAME
		FROM
			dbo.ClientDocumentSettingsTable INNER JOIN
			dbo.ClientTable ON CL_ID = CDS_ID_CLIENT
		WHERE CDS_ID_CLIENT = @clientid


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
