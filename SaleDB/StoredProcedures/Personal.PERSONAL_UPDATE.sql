USE [SaleDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Personal].[PERSONAL_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@MANAGER	UNIQUEIDENTIFIER,
	@SURNAME	NVARCHAR(256),
	@NAME		NVARCHAR(256),
	@PATRON		NVARCHAR(256),
	@SHORT		NVARCHAR(128),
	@PHONE		NVARCHAR(128),
	@PHONE_OF	NVARCHAR(128),
	@ID_TYPE	NVARCHAR(MAX),
	@AUTH		SMALLINT,
	@LOGIN		NVARCHAR(128),
	@PASS		NVARCHAR(128),
	@ROLE		UNIQUEIDENTIFIER,
	@START_DATE	DATETIME
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY
		UPDATE	Personal.OfficePersonal
		SET		MANAGER		=	@MANAGER,
				SURNAME		=	@SURNAME,
				NAME		=	@NAME,
				PATRON		=	@PATRON,
				SHORT		=	@SHORT,
				PHONE		=	@PHONE,
				PHONE_OFFICE	=	@PHONE_OF,
				LOGIN		=	@LOGIN,
				PASS		=	@PASS,
				START_DATE	=	@START_DATE,
				LAST	=	GETDATE()
		WHERE	ID		=	@ID

		UPDATE	Personal.OfficePersonalType
		SET		EDATE	=	GETDATE()
		WHERE	ID_PERSONAL	=	@ID
			AND	EDATE IS NULL
			AND ID_TYPE NOT IN
				(
					SELECT *
					FROM Common.TableGUIDFromXML(@ID_TYPE)
				)

		INSERT INTO Personal.OfficePersonalType(ID_PERSONAL, ID_TYPE)
			SELECT @ID, ID
			FROM Common.TableGUIDFromXML(@ID_TYPE) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM Personal.OfficePersonalType b
					WHERE ID_PERSONAL = @ID
						AND EDATE IS NULL
						AND a.ID = b.ID_TYPE
				)
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT 
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END