USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Tender].[CALL_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Tender].[CALL_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Tender].[CALL_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@TENDER		UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@SUBJECT	NVARCHAR(128),
	@SURNAME	NVARCHAR(128),
	@NAME		NVARCHAR(128),
	@PATRON		NVARCHAR(128),
	@PHONE		NVARCHAR(128),
	@NOTE		NVARCHAR(MAX),
	@CALL_DATE	SMALLDATETIME
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
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

			INSERT INTO Tender.Call(ID_TENDER, DATE, SUBJECT, SURNAME, NAME, PATRON, PHONE, NOTE)
				OUTPUT inserted.ID INTO @TBL
				VALUES(@TENDER, @DATE, @SUBJECT, @SURNAME, @NAME, @PATRON, @PHONE, @NOTE)

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			UPDATE Tender.Call
			SET DATE		=	@DATE,
				SUBJECT		=	@SUBJECT,
				SURNAME		=	@SURNAME,
				NAME		=	@NAME,
				PATRON		=	@PATRON,
				PHONE		=	@PHONE,
				NOTE		=	@NOTE,
				UPD_DATE	=	GETDATE(),
				UPD_USER	=	ORIGINAL_LOGIN()
			WHERE ID = @ID
		END

		UPDATE Tender.Tender
		SET CALL_DATE = @CALL_DATE
		WHERE ID = @TENDER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[CALL_SAVE] TO rl_tender_r;
GRANT EXECUTE ON [Tender].[CALL_SAVE] TO rl_tender_u;
GO
