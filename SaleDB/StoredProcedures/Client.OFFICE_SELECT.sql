USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[OFFICE_SELECT]
	@ID		UNIQUEIDENTIFIER,
	@DEL	BIT,
	@RC		INT	=	NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			a.ID, a.SHORT, a.NAME, b.AR_NAME, b.AD_STR, b.NOTE, b.ST_ID, b.AR_ID, b.ROOM, b.HOME,
			a.STATUS,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM
					(
						SELECT BDATE, UPD_USER
						FROM Client.Office z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.Office z
						WHERE z.ID = a.ID
							AND z.STATUS = 1
					) AS o_O
				ORDER BY BDATE
			) AS CREATE_DATA,
			(
				SELECT TOP 1 CONVERT(VARCHAR(20), BDATE, 104) + ' ' + CONVERT(VARCHAR(20), BDATE, 108) + '/' + UPD_USER
				FROM
					(
						SELECT BDATE, UPD_USER
						FROM Client.Office z
						WHERE z.ID_MASTER = a.ID
							AND z.STATUS = 2

						UNION ALL

						SELECT BDATE, UPD_USER
						FROM Client.Office z
						WHERE z.ID = a.ID
							AND z.STATUS = 1
					) AS o_O
				ORDER BY BDATE DESC
			) AS UPDATE_DATA,
			CASE a.STATUS
				WHEN 3 THEN CONVERT(VARCHAR(20), a.BDATE, 104) + ' ' + CONVERT(VARCHAR(20), a.BDATE, 108) + '/' + a.UPD_USER
				ELSE ''
			END AS DELETE_DATA,
			a.MAIN
		FROM
			Client.Office a
			LEFT OUTER JOIN Client.OfficeAddressView b ON a.ID = b.ID_OFFICE
		WHERE a.ID_COMPANY = @ID
			AND (STATUS = 1 OR STATUS = 3 AND @DEL = 1)
		ORDER BY a.SHORT, a.NAME

		SELECT @RC = @@ROWCOUNT
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
GRANT EXECUTE ON [Client].[OFFICE_SELECT] TO rl_office_r;
GO