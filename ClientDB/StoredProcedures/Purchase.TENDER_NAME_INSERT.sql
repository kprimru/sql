USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Purchase].[TENDER_NAME_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Purchase].[TENDER_NAME_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Purchase].[TENDER_NAME_INSERT]
	@NAME	VARCHAR(500),
	@SHORT	VARCHAR(100),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO Purchase.TenderName(TN_NAME, TN_SHORT)
			OUTPUT inserted.TN_ID INTO @TBL
			VALUES(@NAME, @SHORT)

		SELECT @ID = ID
		FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Purchase].[TENDER_NAME_INSERT] TO rl_tender_name_i;
GO
