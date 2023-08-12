USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_CONTACT_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_CONTACT_SAVE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_CONTACT_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@CLIENT		INT,
	@DATE		SMALLDATETIME,
	@PERSONAL	NVARCHAR(128),
	@SURNAME	NVARCHAR(128),
	@NAME		NVARCHAR(128),
	@PATRON		NVARCHAR(128),
	@POSITION	NVARCHAR(256),
	@TYPE		UNIQUEIDENTIFIER,
	@NOTE		NVARCHAR(MAX),
	@PROBLEM	NVARCHAR(MAX)
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

        IF @Date > GetDate()
        BEGIN
			RAISERROR ('Нельзя вносить записи в будущем!!!', 16, 1)

			RETURN
		END

		IF @ID IS NULL
		BEGIN
			IF @DATE < DATEADD(WEEK, -1, GETDATE())
			BEGIN
				RAISERROR ('Нельзя вносить записи задним числом!!!', 16, 1)

				RETURN
			END

			DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

			DECLARE @CAT CHAR(1)

			SELECT @CAT = T.ClientTypeName
			FROM dbo.ClientTable C
			INNER JOIN dbo.ClientTypeTable T ON C.ClientTypeId = T.ClientTypeId
			WHERE C.ClientID = @CLIENT

			INSERT INTO dbo.ClientContact(ID_CLIENT, DATE, PERSONAL, SURNAME, NAME, PATRON, POSITION, ID_TYPE, CATEGORY, NOTE, PROBLEM)
				OUTPUT inserted.ID INTO @TBL
				SELECT @CLIENT, @DATE, @PERSONAL, @SURNAME, @NAME, @PATRON, @POSITION, @TYPE, ISNULL(@CAT, ''), @NOTE, @PROBLEM

			SELECT @ID = ID FROM @TBL
		END
		ELSE
		BEGIN
			DECLARE @OLD_DATE SMALLDATETIME

			SELECT @OLD_DATE = DATE FROM dbo.ClientContact WHERE ID = @ID

			IF (@DATE <> @OLD_DATE)
			BEGIN
				IF (DATEPART(YEAR, @DATE) <> DATEPART(YEAR, @OLD_DATE)) OR (DATEPART(WEEK, @DATE) <> DATEPART(WEEK, @OLD_DATE))
				BEGIN
					RAISERROR ('Дату можно редактировать только в пределах недели!!!', 16, 1)

					RETURN
				END
			END

			EXEC [dbo].[CLIENT_CONTACT_ARCH] @ID

			UPDATE dbo.ClientContact
			SET DATE		=	@DATE,
				PERSONAL	=	@PERSONAL,
				SURNAME		=	@SURNAME,
				NAME		=	@NAME,
				PATRON		=	@PATRON,
				POSITION	=	@POSITION,
				ID_TYPE		=	@TYPE,
				NOTE		=	@NOTE,
				PROBLEM		=	@PROBLEM,

				UPD_DATE = GETDATE(),
				UPD_USER = ORIGINAL_LOGIN()
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
GRANT EXECUTE ON [dbo].[CLIENT_CONTACT_SAVE] TO rl_client_contact_u;
GO
