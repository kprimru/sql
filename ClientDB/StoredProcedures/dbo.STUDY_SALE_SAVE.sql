USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[STUDY_SALE_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[STUDY_SALE_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[STUDY_SALE_SAVE]
	@ID					UNIQUEIDENTIFIER,
	@CLIENT				INT,
	@DATE				SMALLDATETIME,
	@FIO				VarChar(256),
	@RivalType_IDs      VarChar(Max),
	@LPR				VarChar(256),
	@USER_POST			VarChar(Max),
	@NOTE				VarChar(MAX),
	@Workers			VarChar(Max),
	@Lprs				VarChar(Max)
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
		IF @ID IS NULL BEGIN
		    SET @ID = NewId();

			INSERT INTO dbo.StudySale(ID, ID_CLIENT, DATE, FIO, LPR, USER_POST, NOTE, Lprs, Workers)
			VALUES(@ID, @CLIENT, @DATE, @FIO, @LPR, @USER_POST, @NOTE, @Lprs, @Workers)
		END ELSE BEGIN
			UPDATE dbo.StudySale
			SET DATE = @DATE,
				FIO = @FIO,
				LPR = @LPR,
				USER_POST = @USER_POST,
				NOTE = @NOTE,
				Lprs = @Lprs,
				Workers = @Workers
			WHERE ID = @ID;

			DELETE
			FROM dbo.StudySaleRivals
			WHERE StudySale_Id = @ID;
		END;

		INSERT INTO dbo.StudySaleRivals(StudySale_Id, RivalType_Id)
		SELECT @ID, ID
		FROM dbo.TableIDFromXML(@RivalType_IDs);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[STUDY_SALE_SAVE] TO rl_client_study_u;
GO
