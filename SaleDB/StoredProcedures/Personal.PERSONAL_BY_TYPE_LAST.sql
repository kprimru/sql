USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_BY_TYPE_LAST]
	@TYPE	NVARCHAR(64),
	@LAST	DATETIME = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT @LAST = MAX(LAST)
		FROM Personal.OfficePersonal a
		WHERE END_DATE IS NULL
			AND EXISTS
				(
					SELECT *
					FROM
						Personal.OfficePersonalType b
						INNER JOIN Personal.PersonalType c ON b.ID_TYPE = c.ID
					WHERE b.ID_PERSONAL = a.ID AND b.EDATE IS NULL
						AND c.PSEDO = @TYPE
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
GO
GRANT EXECUTE ON [Personal].[PERSONAL_BY_TYPE_LAST] TO rl_personal_r;
GO