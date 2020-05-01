USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[SUBHOST_LESSON_POSITION_ADD]	
	@LP_NAME	VARCHAR(50),
	@LP_ORDER	SMALLINT,
	@ACTIVE	BIT,
	@return	BIT = 1
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

		INSERT INTO Subhost.LessonPosition(LP_NAME, LP_ORDER, LP_ACTIVE)
			VALUES(@LP_NAME, @LP_ORDER, @ACTIVE)

		DECLARE @ID INT

		SET @ID = SCOPE_IDENTITY()


		INSERT INTO dbo.FieldTable(FL_NAME, FL_WIDTH, FL_CAPTION)
			SELECT 'LP_NAME_' + CONVERT(VARCHAR, @ID), 80, @LP_NAME
		INSERT INTO dbo.FieldTable(FL_NAME, FL_WIDTH, FL_CAPTION)
			SELECT 'SLP_PRICE_' + CONVERT(VARCHAR, @ID), 80, @LP_NAME + ' цена'
		INSERT INTO dbo.FieldTable(FL_NAME, FL_WIDTH, FL_CAPTION)
			SELECT 'SLP_SUM_' + CONVERT(VARCHAR, @ID), 80, @LP_NAME + ' сумма'
		
		IF @RETURN = 1
			SELECT @ID AS NEW_IDEN
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
