USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Memo].[CLIENT_CALCULATION_SAVE]
	@ID			UNIQUEIDENTIFIER,
	@CLIENT		INT,
	@NOTE		NVARCHAR(MAX),
	@DATE		SMALLDATETIME,
	@SYSTEMS	NVARCHAR(MAX)
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

		IF @ID IS NULL
			INSERT INTO Memo.ClientCalculation(ID_CLIENT, DATE, NOTE, SYSTEMS)
				SELECT @CLIENT, dbo.DateOf(GETDATE()), @NOTE, @SYSTEMS
		ELSE
			UPDATE Memo.ClientCalculation
			SET NOTE = @NOTE,
				SYSTEMS = @SYSTEMS
			WHERE ID = @ID
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
