USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_CONTACT_SAVE]
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

	IF @ID IS NULL
	BEGIN
		IF @DATE < DATEADD(WEEK, -1, GETDATE())
		BEGIN
			RAISERROR ('������ ������� ������ ������ ������!!!', 16, 1)
		
			RETURN
		END
	
		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
		
		DECLARE @CAT CHAR(1)
		
		SELECT @CAT = CATEGORY 
		FROM dbo.ClientTypeAllView
		WHERE ClientID = @CLIENT
		
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
				RAISERROR ('���� ����� ������������� ������ � �������� ������!!!', 16, 1)
			
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
END
