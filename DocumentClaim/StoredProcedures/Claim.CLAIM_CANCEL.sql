USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[CLAIM_CANCEL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[CLAIM_CANCEL]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[CLAIM_CANCEL]
	@ID		UNIQUEIDENTIFIER,
	@NOTE	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		IF (SELECT TOP 1 STATUS FROM Claim.DocumentStatus WHERE ID_DOCUMENT = @ID ORDER BY DATE DESC) NOT IN (1, 7)
		BEGIN
			RAISERROR('Ошибка! Статус заказа не подразумевает отмену!', 16, 1)
		END
		ELSE
		BEGIN
			INSERT INTO Claim.DocumentStatus(ID_DOCUMENT, STATUS, ID_AUTHOR, NOTE)
				SELECT @ID,	6, a.ID, @NOTE
				FROM Security.Users a
				WHERE a.NAME = ORIGINAL_LOGIN()

			INSERT INTO Notify.Message(ID_SENDER, ID_RECEIVER, TXT, MODULE, ID_EVENT)
				SELECT
					z.ID, p.ID,
					N'Заказ "' + CL_NAME + N'" отменен.',
					N'CLAIM', @ID
				FROM
					Claim.Document a
					CROSS JOIN
						(
							SELECT ID, CAPTION
							FROM Security.Users
							WHERE NAME = ORIGINAL_LOGIN()
						) AS z
					CROSS JOIN
						(
							SELECT d.ID
							FROM
								Security.UserRoleView a
								INNER JOIN Security.Users d ON d.NAME = a.US_NAME
							WHERE a.RL_NAME = 'rl_claim_notify_cancel'

							UNION

							SELECT t.ID_AUTHOR
							FROM Claim.Document t
							WHERE t.ID = @ID
						) AS p
				WHERE a.ID = @ID AND p.ID <> z.ID
		END

		EXEC Maintenance.FINISH_PROC @@PROCID
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

		EXEC Maintenance.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GO
GRANT EXECUTE ON [Claim].[CLAIM_CANCEL] TO rl_claim_cancel;
GO
