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

ALTER PROCEDURE [dbo].[CONSIGNMENT_DETAIL_SELECT]
	@csgid INT
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
			CSD_ID, DIS_ID, DIS_STR, CSD_NUM, CSD_COST, CSD_PRICE, CSD_TAX_PRICE, CSD_TOTAL_PRICE,
			CSD_PAYED_PRICE, CSD_CODE, CSD_COUNT, CSD_NAME, CSD_UNIT, CSD_OKEI, CSD_PACKING,
			CSD_COUNT_IN_PLACE, CSD_PLACE, CSD_MASS, TX_ID, TX_CAPTION
		FROM
			dbo.ConsignmentDetailTable LEFT OUTER JOIN
			dbo.DistrView WITH(NOEXPAND) ON DIS_ID = CSD_ID_DISTR LEFT OUTER JOIN
			dbo.TaxTable ON TX_ID = CSD_ID_TAX
		WHERE CSD_ID_CONS = @csgid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[CONSIGNMENT_DETAIL_SELECT] TO rl_consignment_r;
GO