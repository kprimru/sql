USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_CONTROL_WARNING]
	@RC	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @CURDATE SMALLDATETIME

		IF IS_MEMBER('rl_control_notify_all') = 1
			SELECT b.ID, b.NAME, Common.DateOf(c.DATE) AS DATE, c.NOTE, e.SHORT, f.SHORT AS PHONE_SHORT, g.SHORT AS MAN_SHORT, c.NOTIFY_DATE, b.NUMBER
			FROM
				Client.CompanyControlView a WITH(NOEXPAND)
				INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
				INNER JOIN Client.CompanyControl c ON c.ID = a.ID
				LEFT OUTER JOIN Client.CompanyProcessSaleView e WITH(NOEXPAND) ON e.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessPhoneView f WITH(NOEXPAND) ON f.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessManagerView g WITH(NOEXPAND) ON g.ID = b.ID
			WHERE b.STATUS = 1
				AND (c.NOTIFY_DATE <= DATEADD(DAY, 2, GETDATE()) OR c.NOTIFY_DATE IS NULL)
			ORDER BY b.NAME, c.DATE
		ELSE
			SELECT b.ID, b.NAME, Common.DateOf(c.DATE) AS DATE, c.NOTE, e.SHORT, f.SHORT AS PHONE_SHORT, g.SHORT AS MAN_SHORT, c.NOTIFY_DATE, b.NUMBER
			FROM
				Client.CompanyControlView a WITH(NOEXPAND)
				INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
				INNER JOIN Client.CompanyControl c ON c.ID = a.ID
				INNER JOIN Client.CompanyWriteList() d ON d.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessSaleView e WITH(NOEXPAND) ON e.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessPhoneView f WITH(NOEXPAND) ON f.ID = b.ID
				LEFT OUTER JOIN Client.CompanyProcessManagerView g WITH(NOEXPAND) ON g.ID = b.ID
			WHERE b.STATUS = 1
				AND (c.NOTIFY_DATE <= DATEADD(DAY, 2, GETDATE()) OR c.NOTIFY_DATE IS NULL)
			ORDER BY b.NAME, c.DATE

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
GRANT EXECUTE ON [Client].[COMPANY_CONTROL_WARNING] TO rl_control_notify_all;
GRANT EXECUTE ON [Client].[COMPANY_CONTROL_WARNING] TO rl_control_notify_self;
GO