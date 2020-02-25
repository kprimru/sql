USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[CALC_SELECT]
	@TENDER UNIQUEIDENTIFIER
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

		SELECT a.ID, a.NAME, b.NAME AS DIR_NAME, a.PRICE, a.NOTE
		FROM 
			Tender.Calc a
			INNER JOIN Tender.CalcDirection b ON a.ID_DIRECTION = b.ID
		WHERE a.ID_TENDER = @TENDER AND a.STATUS = 1
		ORDER BY a.DATE DESC
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
