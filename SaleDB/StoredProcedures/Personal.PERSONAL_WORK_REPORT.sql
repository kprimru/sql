USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Personal].[PERSONAL_WORK_REPORT]
	@PERSONAL	UNIQUEIDENTIFIER,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@RC			INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SET @END = DATEADD(DAY, 1, @END)		

		SELECT 
			ID, SHORT,
			(
				SELECT COUNT(DISTINCT ID_COMPANY)
				FROM Client.CompanyProcess b
				WHERE b.ID_PERSONAL = a.ID
					AND EDATE IS NULL
			) AS COMPANY_COUNT,
			(
				SELECT COUNT(DISTINCT ID_COMPANY)
				FROM Client.CompanyProcess b
				WHERE b.ID_PERSONAL = a.ID
					AND BDATE BETWEEN @BEGIN AND @END
			) AS COMPANY_PROCESS,
			(
				SELECT COUNT(DISTINCT ID_COMPANY)
				FROM Client.CompanyProcess b
				WHERE b.ID_PERSONAL = a.ID
					AND EDATE BETWEEN @BEGIN AND @END
			) AS COMPANY_RETURN,
			(
				SELECT COUNT(DISTINCT ID_COMPANY)
				FROM Client.Call b
				WHERE b.ID_PERSONAL = a.ID
					AND b.STATUS = 1
					AND DATE_S BETWEEN @BEGIN AND @END
			) AS CALL_COMPANY,
			(
				SELECT COUNT(*)
				FROM Client.Call b
				WHERE b.ID_PERSONAL = a.ID
					AND b.STATUS = 1
					AND DATE_S BETWEEN @BEGIN AND @END
			) AS CALL_COUNT,
			(
				SELECT COUNT(*)
				FROM Meeting.AssignedMeeting b
				WHERE b.STATUS = 1
					AND b.ID_ASSIGNER = a.ID
					AND EXPECTED_DATE >= @BEGIN AND EXPECTED_DATE < @END
			) AS MEETING_ASSIGN,
			(
				SELECT COUNT(*)
				FROM 
					Meeting.AssignedMeeting b
					INNER JOIN Meeting.AssignedMeetingPersonal c ON b.ID = c.ID_MEETING
				WHERE b.STATUS = 1
					AND c.ID_PERSONAL = a.ID
					AND EXPECTED_DATE >= @BEGIN AND EXPECTED_DATE < @END
			) AS MEETING_COUNT,
			(
				SELECT COUNT(*)
				FROM Sale.SaleCompany b
				WHERE b.STATUS = 1
					--AND CONFIRMED = 1
					AND DATE BETWEEN @BEGIN AND @END
					AND EXISTS
						(
							SELECT *
							FROM Sale.SalePersonal c
							WHERE c.ID_SALE = b.ID
								AND c.ID_PERSONAL = a.ID
						)
			) AS SALE_COUNT,
			ISNULL((
				SELECT SUM(e.VALUE * c.CNT * d.WEIGHT * g.VALUE / g.TOTAL_VALUE)
				FROM 
					Sale.SaleCompany b
					INNER JOIN Sale.SaleDistr c ON b.ID = c.ID_SALE					
					INNER JOIN System.Net d ON d.ID = c.ID_NET
					INNER JOIN
						(
							SELECT ID_SYSTEM, DATE, DATEADD(MONTH, 1, DATE) AS END_DATE, VALUE
							FROM 
								System.Weight e 
								INNER JOIN Common.Month f ON f.ID = e.ID_MONTH
							WHERE DATE >= DATEADD(MONTH, -1, @BEGIN) AND DATE < @END
						) AS e ON b.DATE > e.DATE AND b.DATE < e.END_DATE AND e.ID_SYSTEM = c.ID_SYSTEM 
					INNER JOIN 
						(
							SELECT ID_SALE, VALUE, 
								(
									SELECT SUM(VALUE)
									FROM Sale.SalePersonal y
									WHERE y.ID_SALE = z.ID_SALE
								) AS TOTAL_VALUE
							FROM 
								Sale.SalePersonal z
							WHERE ID_PERSONAL = a.ID
						) g ON g.ID_SALE = b.ID
				WHERE b.STATUS = 1
					--AND b.CONFIRMED = 1
					AND b.DATE BETWEEN @BEGIN AND @END
					--AND f.DATE BETWEEN @BEGIN AND @END
					AND TOTAL_VALUE <> 0
			), 0) AS WEIGHT
		FROM Personal.OfficePersonal a
		WHERE END_DATE IS NULL
			AND (ID = @PERSONAL OR @PERSONAL IS NULL)
		ORDER BY SHORT

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