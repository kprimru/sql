USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_FINANCING_GET_STAGES]
	@ID INT
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
			V.StageGuid,
			V.StartDate,
			V.FinishDate,
			V.TotalSum
		FROM dbo.ClientFinancing AS F
		CROSS APPLY
		(
			SELECT
				[StageGuid]		= c.value('(guid)[1]', 'Varchar(50)'),
				[StartDate]		= Convert(smalldatetime, c.value('(startDate)[1]', 'Varchar(50)'), 120),
				[FinishDate]	= Convert(smalldatetime, c.value('(endDate)[1]', 'Varchar(50)'), 120),
				[TotalSum]		= c.value('(payments/paymentSum)[1]', 'Money')

				--[ProductName] = c.value('(name)[1]', 'Varchar(50)'),
				--[ProductPrice] = c.value('(price)[1]', 'Money')
			FROM F.EIS_DATA.nodes('(/export/contract/finances/budgetFunds/stages),(/export/contract/finances/extrabudgetFunds/stages),(/export/contract/finances/financingPlan/stages)') AS E(C)
		) AS V
		WHERE ID_CLIENT = @ID
		ORDER BY V.StartDate DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_FINANCING_GET_STAGES] TO rl_client_fin_r;
GO
