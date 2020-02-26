USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STUDY_SALE_SAVE]
	@ID					UNIQUEIDENTIFIER,
	@CLIENT				INT,
	@DATE				SMALLDATETIME,
	@FIO				NVARCHAR(256),
	@RIVAL_CLIENT_ID	NVARCHAR(30),
	@LPR				NVARCHAR(256),
	@USER_POST			NVARCHAR(100),
	@NOTE				NVARCHAR(MAX)
	
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
		DECLARE @RIVAL_CLIENT NVARCHAR(20)
		SELECT @RIVAL_CLIENT = RivalTypeName FROM dbo.RivalTypeTable WHERE RivalTypeID = @RIVAL_CLIENT_ID
	
		IF @ID IS NULL
			INSERT INTO dbo.StudySale(ID_CLIENT, DATE, FIO, RIVAL_CLIENT_ID, RIVAL_CLIENT, LPR, USER_POST, NOTE)
				VALUES(@CLIENT, @DATE, @FIO, @RIVAL_CLIENT_ID, @RIVAL_CLIENT, @LPR, @USER_POST, @NOTE)
		ELSE
			UPDATE dbo.StudySale
			SET DATE = @DATE,
				FIO = @FIO,
				RIVAL_CLIENT_ID = @RIVAL_CLIENT_ID,
				RIVAL_CLIENT = @RIVAL_CLIENT,
				LPR = @LPR,
				USER_POST = @USER_POST,
				NOTE = @NOTE
			WHERE ID = @ID
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
