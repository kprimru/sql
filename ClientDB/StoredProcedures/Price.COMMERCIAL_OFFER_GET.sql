USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[COMMERCIAL_OFFER_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OFFER_GET]
	@ID	UNIQUEIDENTIFIER
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
			ID, ID_VENDOR, FULL_NAME, ADDRESS, DIRECTOR, PER_SURNAME, PER_NAME, PER_PATRON, DIRECTOR_POS,
			DATE, NUM, NOTE,
			DISCOUNT, INFLATION, ID_TEMPLATE, OTHER
		FROM Price.CommercialOffer
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[COMMERCIAL_OFFER_GET] TO rl_commercial_offer_r;
GO
