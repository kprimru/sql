USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Claim].[CLAIM_MASTER_INSERT]
	@CLM_ID	UNIQUEIDENTIFIER = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @USER UNIQUEIDENTIFIER

	SELECT @USER = US_ID_MASTER
	FROM Security.UserActive
	WHERE US_LOGIN = ORIGINAL_LOGIN()

	DECLARE @NUM INT

	SELECT @NUM = MAX(CLM_NUM) + 1
	FROM Claim.Claims
	WHERE CONVERT(VARCHAR(8), CLM_DATE, 112) = CONVERT(VARCHAR(8), GETDATE(), 112)

	IF @NUM IS NULL
		SET @NUM = 1

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO Claim.Claims(CLM_ID_USER, CLM_NUM)
	OUTPUT INSERTED.CLM_ID INTO @TBL
	VALUES(@USER, @NUM)

	SELECT @CLM_ID = ID
	FROM @TBL
END
GO
GRANT EXECUTE ON [Claim].[CLAIM_MASTER_INSERT] TO rl_claim_w;
GO