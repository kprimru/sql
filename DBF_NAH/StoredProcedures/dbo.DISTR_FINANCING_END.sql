USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_FINANCING_END]
	@CLIENT	INT,
	@END	SMALLDATETIME
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

		UPDATE dbo.DistrFinancingTable
		SET DF_END = @END
		WHERE DF_ID_DISTR IN
			(
				SELECT DIS_ID
				FROM dbo.DistrFinancingView
				WHERE DSS_REPORT = 1
					--AND (ISNULL(DF_FIXED_PRICE, 0) <> 0 OR ISNULL(DF_DISCOUNT, 0) <> 0)
					AND CD_ID_CLIENT = @CLIENT
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[DISTR_FINANCING_END] TO rl_distr_financing_w;
GO