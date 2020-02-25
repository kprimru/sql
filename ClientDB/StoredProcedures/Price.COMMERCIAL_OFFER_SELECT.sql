USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[COMMERCIAL_OFFER_SELECT]
	@CLIENT	INT,
	@RC		INT = NULL OUTPUT
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
			ID, DATE, NUM, NOTE,
			CONVERT(VARCHAR(20), CREATE_DATE, 104) + ' ' + CREATE_USER AS CREATE_DATA
		FROM Price.CommercialOffer
		WHERE ID_CLIENT = @CLIENT
			AND STATUS = 1

		UNION ALL

		SELECT ID, DATE, NUM, NOTE,
			CONVERT(VARCHAR(20), CREATE_DATE, 104) + ' ' + CREATE_USER AS CREATE_DATA
		FROM Price.CommercialOffer
		WHERE ID_CLIENT IS NULL AND @CLIENT IS NULL
			AND (CREATE_USER = ORIGINAL_LOGIN() OR IS_MEMBER('rl_commercial_offer_all') = 1)
			AND STATUS = 1
		ORDER BY DATE, NUM DESC

		SELECT @RC = @@ROWCOUNT
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END