USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CALENDAR_WORK_SAVE]
	@ID		UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME,
	@TP		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(256),
	@NOTE	NVARCHAR(MAX)
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
			INSERT INTO dbo.CalendarDate(DATE, ID_TYPE, NAME, NOTE)
				SELECT @DATE, @TP, @NAME, @NOTE
		END
		ELSE
		BEGIN
			EXEC dbo.CALENDAR_WORK_ARCH @ID

			UPDATE dbo.CalendarDate
			SET DATE		=	@DATE,
				ID_TYPE		=	@TP,
				NAME		=	@NAME,
				NOTE		=	@NOTE,
				UPD_DATE	=	GETDATE(),
				UPD_USER	=	ORIGINAL_LOGIN()
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
GO
GRANT EXECUTE ON [dbo].[CALENDAR_WORK_SAVE] TO rl_work_calendar_u;
GO