USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[OFFER_GET]
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
			DATE, ID_VENDOR, ID_TAX, 
			ACTUAL, ACTUAL_START, ACTUAL_FINISH, ACTUAL_DATE, ACTUAL_TYPES, ACTUAL_COEF,
			EXCHANGE, EXCHANGE_TYPES, EXCHANGE_COEF,
			DELIVERY, DELIVERY_TYPES, DELIVERY_COEF,
			SUPPORT, SUPPORT_START, SUPPORT_FINISH, SUPPORT_TYPES, SUPPORT_COEF,
			QUERY_DATE
		FROM Tender.Offer
		WHERE ID = @ID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
