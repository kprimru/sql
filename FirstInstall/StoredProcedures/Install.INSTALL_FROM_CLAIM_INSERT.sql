USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Install].[INSTALL_FROM_CLAIM_INSERT]
	@ID_LIST	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE CLAIM CURSOR LOCAL FOR
		SELECT ID
		FROM Common.TableFromList(@ID_LIST, ',')

	DECLARE @CLD_ID		UNIQUEIDENTIFIER

	DECLARE @INS_ID		UNIQUEIDENTIFIER
	DECLARE @CL_ID		UNIQUEIDENTIFIER
	DECLARE @VD_ID		UNIQUEIDENTIFIER
	DECLARE @INS_DATE	SMALLDATETIME


	DECLARE @IND_ID		UNIQUEIDENTIFIER
	DECLARE	@SYS_ID		UNIQUEIDENTIFIER
	DECLARE @DT_ID		UNIQUEIDENTIFIER
	DECLARE @NT_ID		UNIQUEIDENTIFIER
	DECLARE @TT_ID		UNIQUEIDENTIFIER

	DECLARE @COUNT		TINYINT

	OPEN CLAIM

	FETCH NEXT FROM CLAIM INTO @CLD_ID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @INS_ID = NULL
		-- ����� 1. ������� ������ � Install (Master), ���� �����
		SELECT @INS_ID = INS_ID
		FROM
			Install.Install INNER JOIN
			Claim.ClaimDetail ON CLD_ID_CLIENT = INS_ID_CLIENT
						AND CLD_ID_VENDOR = INS_ID_VENDOR
		WHERE CLD_ID = @CLD_ID

		IF @INS_ID IS NULL
		BEGIN
			SELECT
				@INS_DATE	=	CONVERT(DATETIME, CONVERT(VARCHAR, GETDATE(), 112)),
				@CL_ID		=	CLD_ID_CLIENT,
				@VD_ID		=	CLD_ID_VENDOR
			FROM
				Claim.ClaimDetail
			WHERE CLD_ID = @CLD_ID

			EXEC Install.INSTALL_INSERT @CL_ID, @VD_ID, @INS_DATE, @INS_ID OUTPUT
		END

		-- ����� 2. ������� ������ � InstallDetail

		IF @IND_ID IS NULL
		BEGIN
			SELECT
				@SYS_ID =	CLD_ID_SYSTEM,
				@DT_ID	=	CLD_ID_TYPE,
				@NT_ID	=	CLD_ID_NET,
				@TT_ID	=	CLD_ID_TECH,
				@COUNT	=	CLD_COUNT
			FROM Claim.ClaimDetail
			WHERE CLD_ID = @CLD_ID

			EXEC Install.INSTALL_DETAIL_INSERT @INS_ID, NULL, @SYS_ID, @DT_ID, @NT_ID, @TT_ID, @COUNT, 0
		END

		FETCH NEXT FROM CLAIM INTO @CLD_ID
	END

	CLOSE CLAIM
	DEALLOCATE CLAIM
END
GO
GRANT EXECUTE ON [Install].[INSTALL_FROM_CLAIM_INSERT] TO rl_claim_w;
GO
