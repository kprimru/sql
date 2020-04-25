USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seminar].[SCHEDULE_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@SUBJECT	UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@TIME		SMALLDATETIME,
	@LIMIT		SMALLINT,
	@WEB		BIT,
	@PERSONAL	BIT,
	@QUESTIONS	BIT,
	@INVITE		SMALLDATETIME,
	@RESERVE	SMALLDATETIME
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
		BEGIN
			DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
			
			INSERT INTO Seminar.Schedule(ID_SUBJECT, DATE, TIME, LIMIT, WEB, PERSONAL, QUESTIONS, INVITE_DATE, RESERVE_DATE)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@SUBJECT, @DATE, @TIME, @LIMIT, @WEB, @PERSONAL, @QUESTIONS, @INVITE, @RESERVE)
				
			SELECT @ID = ID
			FROM @TBL
		END
		ELSE
		BEGIN
			UPDATE Seminar.Schedule
			SET ID_SUBJECT	=	@SUBJECT,
				DATE		=	@DATE,
				TIME		=	@TIME,
				LIMIT		=	@LIMIT,
				WEB			=	@WEB,
				PERSONAL	=	@PERSONAL,
				QUESTIONS	=	@QUESTIONS,
				INVITE_DATE	=	@INVITE,
				RESERVE_DATE	=	@RESERVE,
				LAST		=	GETDATE()
			WHERE ID = @ID
		END
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
