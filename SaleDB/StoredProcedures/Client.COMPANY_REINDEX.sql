USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_REINDEX]
	@ID		UNIQUEIDENTIFIER	=	NULL,
	@LIST	NVARCHAR(MAX)		=	NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @ID IS NOT NULL OR @LIST IS NOT NULL
		BEGIN
			DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER PRIMARY KEY)

			IF @ID IS NOT NULL
				INSERT INTO @TBL(ID)
					SELECT @ID

			IF @LIST IS NOT NULL
				INSERT INTO @TBL(ID)
					SELECT ID
					FROM Common.TableGUIDFromXML(@LIST)

				UPDATE z
				SET DATA =
					(
						SELECT
							ISNULL(a.SHORT, '') + ' ' +
							ISNULL(a.NAME, '') + ' ' +
							ISNULL(a.EMAIL, '') + ' ' +
							ISNULL(CONVERT(VARCHAR(20), a.NUMBER), '') + ' ' +
							ISNULL(
								(
									SELECT
										ISNULL(b.NAME, '') + ' ' +
										ISNULL(b.SHORT, '') + ' ' +
										ISNULL(d.NAME, '') + ' ' +
										ISNULL(e.NAME, '') + ' ' +
										ISNULL(f.NAME, '') + ' ' +
										ISNULL(c.HOME, '') + ' ' +
										ISNULL(c.ROOM, '') + ' ' +
										ISNULL(c.NOTE, '')
									FROM
										Client.Office b
										LEFT OUTER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
										LEFT OUTER JOIN Address.Street d ON d.ID = c.ID_STREET
										LEFT OUTER JOIN Address.City e ON e.ID = d.ID_CITY
										LEFT OUTER JOIN Address.Area f ON f.ID = c.ID_AREA
									WHERE b.ID_COMPANY = a.ID AND b.STATUS = 1
									FOR XML PATH('')
								), '') + ' ' +
							ISNULL(
								(
									SELECT
										ISNULL(PHONE, '') + ' ' +
										ISNULL(PHONE_S, '') + ' '
									FROM Client.CompanyPhone b
									WHERE b.ID_COMPANY = a.ID
									FOR XML PATH('')
								)
								, '') + ' ' +
							ISNULL(
								(
									SELECT
										ISNULL(FIO, '') + ' ' +
										ISNULL(EMAIL, '') + ' ' +
										ISNULL(
											(
												SELECT
													ISNULL(PHONE, '') + ' ' +
													ISNULL(PHONE_S, '') + ' '
												FROM Client.CompanyPersonalPhone c
												WHERE b.ID = c.ID_PERSONAL
												FOR XML PATH('')
											)
											, '') + ' '
									FROM Client.CompanyPersonal b
									WHERE b.ID_COMPANY = a.ID
									FOR XML PATH('')
								)
								, '')  +
							ISNULL(
								(
									SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
									FROM
										Personal.OfficePersonal b
										INNER JOIN Client.CompanyProcessPhoneView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
									WHERE c.ID = a.ID
								)
							, '') +
							ISNULL(
								(
									SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
									FROM
										Personal.OfficePersonal b
										INNER JOIN Client.CompanyProcessManagerView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
									WHERE c.ID = a.ID
								)
							, '') +
							ISNULL(
								(
									SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
									FROM
										Personal.OfficePersonal b
										INNER JOIN Client.CompanyProcessSaleView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
									WHERE c.ID = a.ID
								)
							, '')
						FROM Client.Company a
						WHERE a.STATUS = 1 AND a.ID = z.ID_COMPANY
					),
					ADDRESS =
						(
							SELECT TOP 1 AD_STR
							FROM Client.OfficeAddressMainView WITH(NOEXPAND)
							WHERE CO_ID = z.ID_COMPANY
							ORDER BY MAIN DESC, ID
						)
				FROM Client.CompanyIndex z
				WHERE ID_COMPANY IN (SELECT ID FROM @TBL)

				INSERT INTO Client.CompanyIndex(ID_COMPANY, DATA, ADDRESS)
					SELECT
						a.ID,
						ISNULL(a.SHORT, '') + ' ' +
						ISNULL(a.NAME, '') + ' ' +
						ISNULL(CONVERT(VARCHAR(20), a.NUMBER), '') + ' ' +
						ISNULL(
							(
								SELECT
									ISNULL(b.NAME, '') + ' ' +
									ISNULL(b.SHORT, '') + ' ' +
									ISNULL(d.NAME, '') + ' ' +
									ISNULL(e.NAME, '') + ' ' +
									ISNULL(f.NAME, '') + ' ' +
									ISNULL(c.HOME, '') + ' ' +
									ISNULL(c.ROOM, '') + ' ' +
									ISNULL(c.NOTE, '')
								FROM
									Client.Office b
									LEFT OUTER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
									LEFT OUTER JOIN Address.Street d ON d.ID = c.ID_STREET
									LEFT OUTER JOIN Address.City e ON e.ID = d.ID_CITY
									LEFT OUTER JOIN Address.Area f ON f.ID = c.ID_AREA
								WHERE b.ID_COMPANY = a.ID AND b.STATUS = 1
								FOR XML PATH('')
							), '') + ' ' +
						ISNULL(
							(
								SELECT
									ISNULL(PHONE, '') + ' ' +
									ISNULL(PHONE_S, '') + ' '
								FROM Client.CompanyPhone b
								WHERE b.ID_COMPANY = a.ID
								FOR XML PATH('')
							)
							, '') + ' ' +
						ISNULL(
							(
								SELECT
									ISNULL(FIO, '') + ' ' +
									ISNULL(
										(
											SELECT
												ISNULL(PHONE, '') + ' ' +
												ISNULL(PHONE_S, '') + ' '
											FROM Client.CompanyPersonalPhone c
											WHERE b.ID = c.ID_PERSONAL
											FOR XML PATH('')
										)
										, '') + ' '
								FROM Client.CompanyPersonal b
								WHERE b.ID_COMPANY = a.ID
								FOR XML PATH('')
							)
							, '') +
						ISNULL(
							(
								SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
								FROM
									Personal.OfficePersonal b
									INNER JOIN Client.CompanyProcessPhoneView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
								WHERE c.ID = a.ID
							)
						, '') +
						ISNULL(
							(
								SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
								FROM
									Personal.OfficePersonal b
									INNER JOIN Client.CompanyProcessManagerView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
								WHERE c.ID = a.ID
							)
						, '') +
						ISNULL(
							(
								SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
								FROM
									Personal.OfficePersonal b
									INNER JOIN Client.CompanyProcessSaleView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
								WHERE c.ID = a.ID
							)
						, '')
						AS DATA,
						(
							SELECT TOP 1 AD_STR
							FROM Client.OfficeAddressMainView WITH(NOEXPAND)
							WHERE CO_ID = a.ID
							ORDER BY MAIN DESC, ID
						)
					FROM
						Client.Company a
						INNER JOIN @TBL z ON z.ID = a.ID
					WHERE a.STATUS = 1 AND NOT EXISTS
						(
							SELECT *
							FROM Client.CompanyIndex t
							WHERE t.ID_COMPANY = a.ID
						)

		END
		ELSE
		BEGIN
			UPDATE t
			SET DATA =
					(
							ISNULL(a.SHORT, '') + ' ' +
							ISNULL(a.NAME, '') + ' ' +
							ISNULL(a.EMAIL, '') + ' ' +
							ISNULL(CONVERT(VARCHAR(20), a.NUMBER), '') + ' ' +
							ISNULL(
								(
									SELECT
										ISNULL(b.NAME, '') + ' ' +
										ISNULL(b.SHORT, '') + ' ' +
										ISNULL(d.NAME, '') + ' ' +
										ISNULL(e.NAME, '') + ' ' +
										ISNULL(f.NAME, '') + ' ' +
										ISNULL(c.HOME, '') + ' ' +
										ISNULL(c.ROOM, '') + ' ' +
										ISNULL(c.NOTE, '')
									FROM
										Client.Office b
										LEFT OUTER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
										LEFT OUTER JOIN Address.Street d ON d.ID = c.ID_STREET
										LEFT OUTER JOIN Address.City e ON e.ID = d.ID_CITY
										LEFT OUTER JOIN Address.Area f ON f.ID = c.ID_AREA
									WHERE b.ID_COMPANY = a.ID AND b.STATUS = 1
									FOR XML PATH('')
								), '') + ' ' +
							ISNULL(
								(
									SELECT
										ISNULL(PHONE, '') + ' ' +
										ISNULL(PHONE_S, '') + ' '
									FROM Client.CompanyPhone b
									WHERE b.ID_COMPANY = a.ID
									FOR XML PATH('')
								)
								, '') + ' ' +
							ISNULL(
								(
									SELECT
										ISNULL(FIO, '') + ' ' +
										ISNULL(EMAIL, '') + ' ' +
										ISNULL(
											(
												SELECT
													ISNULL(PHONE, '') + ' ' +
													ISNULL(PHONE_S, '') + ' '
												FROM Client.CompanyPersonalPhone c
												WHERE b.ID = c.ID_PERSONAL
												FOR XML PATH('')
											)
											, '') + ' '
									FROM Client.CompanyPersonal b
									WHERE b.ID_COMPANY = a.ID
									FOR XML PATH('')
								)
								, '')  +
							ISNULL(
								(
									SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
									FROM
										Personal.OfficePersonal b
										INNER JOIN Client.CompanyProcessPhoneView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
									WHERE c.ID = a.ID
								)
							, '') +
							ISNULL(
								(
									SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
									FROM
										Personal.OfficePersonal b
										INNER JOIN Client.CompanyProcessManagerView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
									WHERE c.ID = a.ID
								)
							, '') +
							ISNULL(
								(
									SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
									FROM
										Personal.OfficePersonal b
										INNER JOIN Client.CompanyProcessSaleView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
									WHERE c.ID = a.ID
								)
							, '')
					),
					ADDRESS =
						(
							SELECT TOP 1 AD_STR
							FROM Client.OfficeAddressMainView WITH(NOEXPAND)
							WHERE CO_ID = a.ID
							ORDER BY MAIN DESC, ID
						)
				FROM
					Client.CompanyIndex t
					INNER JOIN Client.Company a ON t.ID_COMPANY = a.ID
				WHERE a.STATUS = 1

			INSERT INTO Client.CompanyIndex(ID_COMPANY, DATA, ADDRESS)
				SELECT
						a.ID,
						ISNULL(a.SHORT, '') + ' ' +
						ISNULL(a.NAME, '') + ' ' +
						ISNULL(CONVERT(VARCHAR(20), a.NUMBER), '') + ' ' +
						ISNULL(
							(
								SELECT
									ISNULL(b.NAME, '') + ' ' +
									ISNULL(b.SHORT, '') + ' ' +
									ISNULL(d.NAME, '') + ' ' +
									ISNULL(e.NAME, '') + ' ' +
									ISNULL(f.NAME, '') + ' ' +
									ISNULL(c.HOME, '') + ' ' +
									ISNULL(c.ROOM, '') + ' ' +
									ISNULL(c.NOTE, '')
								FROM
									Client.Office b
									LEFT OUTER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
									LEFT OUTER JOIN Address.Street d ON d.ID = c.ID_STREET
									LEFT OUTER JOIN Address.City e ON e.ID = d.ID_CITY
									LEFT OUTER JOIN Address.Area f ON f.ID = c.ID_AREA
								WHERE b.ID_COMPANY = a.ID AND b.STATUS = 1
								FOR XML PATH('')
							), '') + ' ' +
						ISNULL(
							(
								SELECT
									ISNULL(PHONE, '') + ' ' +
									ISNULL(PHONE_S, '') + ' '
								FROM Client.CompanyPhone b
								WHERE b.ID_COMPANY = a.ID
								FOR XML PATH('')
							)
							, '') + ' ' +
						ISNULL(
							(
								SELECT
									ISNULL(FIO, '') + ' ' +
									ISNULL(
										(
											SELECT
												ISNULL(PHONE, '') + ' ' +
												ISNULL(PHONE_S, '') + ' '
											FROM Client.CompanyPersonalPhone c
											WHERE b.ID = c.ID_PERSONAL
											FOR XML PATH('')
										)
										, '') + ' '
								FROM Client.CompanyPersonal b
								WHERE b.ID_COMPANY = a.ID
								FOR XML PATH('')
							)
							, '')  +
						ISNULL(
							(
								SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
								FROM
									Personal.OfficePersonal b
									INNER JOIN Client.CompanyProcessPhoneView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
								WHERE c.ID = a.ID
							)
						, '') +
						ISNULL(
							(
								SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
								FROM
									Personal.OfficePersonal b
									INNER JOIN Client.CompanyProcessManagerView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
								WHERE c.ID = a.ID
							)
						, '') +
						ISNULL(
							(
								SELECT ISNULL(b.SHORT, '') + ' ' + ISNULL(b.SURNAME, '')
								FROM
									Personal.OfficePersonal b
									INNER JOIN Client.CompanyProcessSaleView c WITH(NOEXPAND) ON b.ID = c.ID_PERSONAL
								WHERE c.ID = a.ID
							)
						, '') AS DATA,
					(
						SELECT TOP 1 AD_STR
						FROM Client.OfficeAddressMainView WITH(NOEXPAND)
						WHERE CO_ID = a.ID
						ORDER BY MAIN DESC, ID
					)
				FROM Client.Company a
				WHERE a.STATUS = 1 AND NOT EXISTS(SELECT * FROM Client.CompanyIndex t WHERE a.ID = t.ID_COMPANY)
		END
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
GRANT EXECUTE ON [Client].[COMPANY_REINDEX] TO rl_company_reindex;
GO