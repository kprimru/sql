USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Claim].[CLAIM_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@ID_CLIENT	NVARCHAR(128),
	@CL_TYPE	NVARCHAR(16),
	@CL_NAME	NVARCHAR(256),
	@ID_TYPE	UNIQUEIDENTIFIER,
	@ID_VENDOR	UNIQUEIDENTIFIER,
	@NOTE		NVARCHAR(MAX),
	@DOC		NVARCHAR(MAX),
	@DETAIL		NVARCHAR(MAX),
	@DISTR		NVARCHAR(MAX),
	@SERVICE	NVARCHAR(MAX),
	@PERSONAL	NVARCHAR(128) = NULL,
	@VERIFY		BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		BEGIN TRAN

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		DECLARE @OLD_ID	UNIQUEIDENTIFIER

		INSERT INTO Claim.Document(ID_MASTER, DATE, ID_AUTHOR, ID_CLIENT, CL_TYPE, CL_NAME, ID_TYPE, ID_VENDOR, NOTE, STATUS, UPD_DATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT ID, DATE, ID_AUTHOR, ID_CLIENT, CL_TYPE, CL_NAME, ID_TYPE, ID_VENDOR, NOTE, 2, UPD_DATE, UPD_USER
			FROM Claim.Document
			WHERE ID = @ID

		SELECT @OLD_ID = ID
		FROM @TBL

		UPDATE Claim.Document
		SET ID_CLIENT	=	@ID_CLIENT,
			CL_TYPE		=	@CL_TYPE,
			CL_NAME		=	@CL_NAME,
			ID_TYPE		=	@ID_TYPE,
			ID_VENDOR	=	@ID_VENDOR,
			NOTE		=	@NOTE,
			SALE_PERSONAL	=	@PERSONAL,
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID

		UPDATE Claim.DocumentDetail
		SET ID_DOCUMENT = @OLD_ID
		WHERE ID_DOCUMENT = @ID

		UPDATE Claim.DocumentDistr
		SET ID_DOCUMENT = @OLD_ID
		WHERE ID_DOCUMENT = @ID

		UPDATE Claim.DocumentService
		SET ID_DOCUMENT = @OLD_ID
		WHERE ID_DOCUMENT = @ID

		UPDATE Claim.DocumentType
		SET ID_DOCUMENT = @OLD_ID
		WHERE ID_DOCUMENT = @ID

		DECLARE @detail_xml XML

		SET @detail_xml = CAST(@DETAIL AS XML)

		INSERT INTO Claim.DocumentDetail(ID_DOCUMENT, ID_SYSTEM, ID_NEW_SYSTEM, ID_NET, ID_NEW_NET, ID_TYPE, ID_ACTION, ID_MONTH_BONUS, ID_CONDITIONS, CNT, DISCOUNT, INFLATION)
			SELECT
				@ID,
				c.value('@id_system', 'UNIQUEIDENTIFIER'),
				c.value('@id_new_system', 'UNIQUEIDENTIFIER'),
				c.value('@id_net', 'UNIQUEIDENTIFIER'),
				c.value('@id_new_net', 'UNIQUEIDENTIFIER'),
				c.value('@id_type', 'UNIQUEIDENTIFIER'),
				c.value('@id_action', 'UNIQUEIDENTIFIER'),
				c.value('@id_month_bonus', 'UNIQUEIDENTIFIER'),
				c.value('@id_conditions', 'NVARCHAR(MAX)'),
				c.value('@cnt', 'INT'),
				c.value('@discount', 'DECIMAL(8, 4)'),
				c.value('@inflation', 'DECIMAL(8, 4)')
			FROM @detail_xml.nodes('/root/item') AS a(c)

		DECLARE @distr_xml XML

		SET @distr_xml = CAST(@DISTR AS XML)

		INSERT INTO Claim.DocumentDistr(ID_DOCUMENT, ID_SYSTEM, ID_NET, DISTR, COMP)
			SELECT
				@ID,
				c.value('@id_system', 'UNIQUEIDENTIFIER'),
				c.value('@id_net', 'UNIQUEIDENTIFIER'),
				c.value('@distr', 'INT'),
				c.value('@comp', 'TINYINT')
			FROM @distr_xml.nodes('/root/item') AS a(c)

		DECLARE @doc_xml XML

		SET @doc_xml = CAST(@DOC AS XML)

		INSERT INTO Claim.DocumentType(ID_DOCUMENT, ID_TYPE)
			SELECT
				@ID,
				c.value('@id_type', 'UNIQUEIDENTIFIER')
			FROM @doc_xml.nodes('/root/item') AS a(c)

		DECLARE @service_xml XML

		SET @service_xml = CAST(@SERVICE AS XML)

		INSERT INTO Claim.DocumentService(ID_DOCUMENT, ID_SERVICE, CNT)
			SELECT
				@ID,
				c.value('@id_service', 'UNIQUEIDENTIFIER'),
				c.value('@cnt', 'INT')
			FROM @service_xml.nodes('/root/item') AS a(c)

		IF EXISTS
			(
				SELECT *
				FROM Claim.DocumentDetail
				WHERE ID_DOCUMENT = @ID
					AND ISNULL(DISCOUNT, 0) <> 0
			) OR @VERIFY = 1
		BEGIN
			-- необходимо подтверждение начальника
			INSERT INTO Claim.DocumentStatus(ID_DOCUMENT, STATUS, ID_AUTHOR, NOTE)
				SELECT @ID, 7, a.ID, N''
				FROM Security.Users a
				WHERE a.NAME = ORIGINAL_LOGIN()


			INSERT INTO Notify.Message(ID_SENDER, ID_RECEIVER, TXT, MODULE, ID_EVENT)
				SELECT
					z.ID, d.ID,
					N'Подтвердить заказ "' + @CL_NAME + N'" от ' + z.CAPTION,
					N'CLAIM', @ID
				FROM
					Security.UserRoleView a
					INNER JOIN Security.Users d ON d.NAME = a.US_NAME
					INNER JOIN Security.Users z ON z.ID_DEPARTMENT = d.ID_DEPARTMENT AND z.HEAD = 1
				WHERE  a.RL_NAME = 'rl_claim_notify_verify' AND z.NAME = ORIGINAL_LOGIN()
		END

		COMMIT

		EXEC Maintenance.FINISH_PROC @@PROCID
	END TRY
	BEGIN CATCH
		ROLLBACK

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

		EXEC Maintenance.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GO
GRANT EXECUTE ON [Claim].[CLAIM_UPDATE] TO rl_claim_u;
GO
