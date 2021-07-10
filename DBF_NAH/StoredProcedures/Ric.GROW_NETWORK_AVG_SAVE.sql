USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Ric].[GROW_NETWORK_AVG_SAVE]
	@PR_ID	SMALLINT,
	@VALUE	DECIMAL(10, 4)
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

		DECLARE @QR_ID	SMALLINT

		SET @QR_ID = dbo.PeriodQuarter(@PR_ID)

		UPDATE Ric.GrowNetworkAvg
		SET GNA_VALUE = @VALUE
		WHERE GNA_ID_QUARTER = @QR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Ric.GrowNetworkAvg(GNA_ID_QUARTER, GNA_VALUE)
				SELECT @QR_ID, @VALUE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Ric].[GROW_NETWORK_AVG_SAVE] TO rl_ric_kbu;
GO