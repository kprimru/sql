USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CHANGE_SALE_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @START_DATE	SMALLDATETIME

		SELECT @START_DATE = Common.DateOf(ASSIGN_DATE)
		FROM Client.CompanyProcess
		WHERE ID_COMPANY = @ID
			AND RETURN_DATE IS NULL
			AND PROCESS_TYPE = N'SALE'

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		CREATE TABLE #result
			(
				TP		NVARCHAR(64),
				OLD		NVARCHAR(512),
				NEW		NVARCHAR(512)
			)

		INSERT INTO #result(TP, OLD, NEW)
			SELECT
				N'ADDRESS' AS TP,
				(
					SELECT TOP 1 AD_STR
					FROM
						Client.Office b
						INNER JOIN Client.OfficeAddressView c ON b.ID = c.ID_OFFICE
					WHERE b.ID_MASTER = a.ID AND Common.DateOf(BDATE) <= @START_DATE
					ORDER BY BDATE DESC
				) AS OLD_ADDR,
				(
					SELECT TOP 1 AD_STR
					FROM
						Client.Office b
						INNER JOIN Client.OfficeAddressView c ON b.ID = c.ID_OFFICE
					WHERE (b.ID_MASTER = a.ID OR b.ID = a.ID) --AND BDATE >= @START_DATE
					ORDER BY BDATE DESC
				) AS NEW_ADDR
			FROM Client.Office a
			WHERE ID_COMPANY = @ID AND STATUS IN (1, 3)	AND (Common.DateOf(BDATE) >= @START_DATE OR Common.DateOf(EDATE) >= @START_DATE)


		INSERT INTO #result(TP, OLD, NEW)
			SELECT
				N'PHONE' AS TP,
				(
					SELECT TOP 1 PHONE
					FROM
						Client.CompanyPhone b
					WHERE b.ID_MASTER = a.ID AND Common.DateOf(BDATE) <= @START_DATE
					ORDER BY BDATE DESC
				) AS OLD_ADDR,
				(
					SELECT TOP 1 PHONE
					FROM
						Client.CompanyPhone b
					WHERE (b.ID_MASTER = a.ID OR b.ID = a.ID)-- AND BDATE >= @START_DATE
					ORDER BY BDATE DESC
				) AS NEW_ADDR
			FROM Client.CompanyPhone a
			WHERE ID_COMPANY = @ID AND STATUS IN (1, 3)	AND (Common.DateOf(BDATE) >= @START_DATE OR Common.DateOf(EDATE) >= @START_DATE)

		INSERT INTO #result(TP, OLD, NEW)
			SELECT
				N'PERSONAL' AS TP,
				(
					SELECT TOP 1
						FIO + ' / ' + ISNULL(d.NAME, '') + ' / ' +
						ISNULL(REVERSE(STUFF(REVERSE(
							(
								SELECT PHONE + ','
								FROM Client.CompanyPersonalPhone c
								WHERE c.ID_PERSONAL = b.ID
								FOR XML PATH('')
							)), 1, 1, '')), '')
					FROM
						Client.CompanyPersonal b
						LEFT OUTER JOIN Client.Position d ON d.ID = b.ID_POSITION
					WHERE b.ID_MASTER = a.ID AND Common.DateOf(BDATE) <= @START_DATE
					ORDER BY BDATE DESC
				) AS OLD_ADDR,
				(
					SELECT TOP 1
						FIO + ' / ' + ISNULL(d.NAME, '') + ' / ' +
						ISNULL(REVERSE(STUFF(REVERSE(
							(
								SELECT PHONE + ','
								FROM Client.CompanyPersonalPhone c
								WHERE c.ID_PERSONAL = b.ID
								FOR XML PATH('')
							)), 1, 1, '')), '')
					FROM
						Client.CompanyPersonal b
						LEFT OUTER JOIN Client.Position d ON d.ID = b.ID_POSITION
					WHERE (b.ID_MASTER = a.ID OR b.ID = a.ID) --AND BDATE >= @START_DATE
					ORDER BY BDATE DESC
				) AS NEW_ADDR
			FROM Client.CompanyPersonal a
			WHERE ID_COMPANY = @ID AND STATUS IN (1, 3)	AND (Common.DateOf(BDATE) >= @START_DATE OR Common.DateOf(EDATE) >= @START_DATE)

		SELECT
			CASE TP
				WHEN 'ADDRESS' THEN 'Адрес'
				WHEN 'PHONE' THEN 'Телефон'
				WHEN 'PERSONAL' THEN 'Сотрудник'
				ELSE TP
			END + ':' + CHAR(10) + TP_DATA
		FROM
			(
				SELECT a.TP,
					REVERSE(STUFF(REVERSE(
						(
							SELECT
								CASE
									WHEN OLD IS NULL AND NEW IS NOT NULL THEN 'Новый: ' + NEW
									WHEN OLD IS NOT NULL AND NEW IS NULL THEN 'Удален: ' + OLD
									WHEN OLD IS NOT NULL AND NEW IS NOT NULL THEN 'Изменен: ' + 'с ' + ISNULL(OLD, '') + ' на ' + ISNULL(NEW, '') + ''
									ELSE 'ээ.... непонятно'
								END + CHAR(10)
							FROM #result b
							WHERE b.TP = a.TP
								AND ISNULL(OLD, '') <> ISNULL(NEW, '')
							FOR XML PATH('')
						)
					), 1, 1, '')) AS TP_DATA
				FROM
					(
						SELECT DISTINCT TP
						FROM #result
						WHERE ISNULL(OLD, '') <> ISNULL(NEW, '')
					) AS a
			) AS o_O

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result
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
