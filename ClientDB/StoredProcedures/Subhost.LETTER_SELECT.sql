USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[LETTER_SELECT]
	@SH		NVARCHAR(64),
	@START	SMALLDATETIME,
	@FINISH	SMALLDATETIME,
	@NUM	NVARCHAR(256),
	@TEXT	NVARCHAR(256)
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

		DECLARE @RC INT
		DECLARE @RECEIVER NVARCHAR(64)
		
		SET @RECEIVER = 
				CASE @SH 
					WHEN 'Í1' THEN 'f0ec56ff-5ae4-e211-bb69-000c2933b2fd'
					WHEN 'Ó1' THEN 'f1ec56ff-5ae4-e211-bb69-000c2933b2fd'
					WHEN 'Ë1' THEN 'a92b3b06-5be4-e211-bb69-000c2933b2fd'
					WHEN 'Ì' THEN 'f2ec56ff-5ae4-e211-bb69-000c2933b2fd'
				END

		EXEC [PC275-SQL\GAMMA].Letters.dbo.LETTER_SEARCH '8ebc1b48-59e4-e211-bb69-000c2933b2fd', @START, @FINISH, @NUM, @TEXT, @RC OUTPUT, @RECEIVER
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
