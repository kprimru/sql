USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[CLIENT_ACT_SELECT]
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
			ACT_ID, ACT_DATE, ACT_PRICE,
			(CONVERT(VARCHAR, INS_NUM) + '/' + INS_NUM_YEAR) AS INS_NUM,
			ACT_PRINT, ACT_SIGN, ORG_PSEDO,
			COUR_ID, COUR_NAME, ISNULL(CL_PSEDO, '') AS PAYER,
			SO_CODE = (
				-- ToDo это нужно, чтобы понимать по какой форме печатать акт.
				-- В принципе, акты, которые печатаются по разным формам должно быть нельзя пихать в один

				-- ToDo очень медленно работает
				SELECT TOP (1) SO_CODE
				FROM dbo.ActDistrTable
				INNER JOIN dbo.DistrView WITH(NOEXPAND) ON DIS_ID = AD_ID_DISTR
				INNER JOIN dbo.SaleObjectTable ON SO_ID = SYS_ID_SO
				WHERE AD_ID_ACT = ACT_ID
				ORDER BY SO_ID
			)
		FROM dbo.ActView
		LEFT JOIN dbo.InvoiceSaleTable	ON INS_ID = ACT_ID_INVOICE
		LEFT JOIN dbo.ClientTable		ON ACT_ID_PAYER = CL_ID
		WHERE ACT_ID_CLIENT = @clientid
		ORDER BY ACT_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_ACT_SELECT] TO rl_act_r;
GO