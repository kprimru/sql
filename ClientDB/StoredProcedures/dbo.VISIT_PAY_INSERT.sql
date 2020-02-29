USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[VISIT_PAY_INSERT]	
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@VALUE	MONEY,
	@ID	INT = NULL OUTPUT
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
	
		INSERT INTO dbo.VisitPayTable(VisitPayBegin, VisitPayEnd, VisitPayValue)
			VALUES(@BEGIN, @END, @VALUE)

		SELECT @ID = SCOPE_IDENTITY()
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END