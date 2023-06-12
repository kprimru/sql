﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[CLAIM_MASTER_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[CLAIM_MASTER_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[CLAIM_MASTER_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CLM_ID, CLM_DATE, CLM_NUM, US_NAME, US_ID_MASTER
	FROM
		Claim.Claims INNER JOIN
		Security.UserActive ON US_ID_MASTER = CLM_ID_USER
	WHERE CLM_ID = @ID
END
GO
GRANT EXECUTE ON [Claim].[CLAIM_MASTER_SELECT] TO rl_claim_w;
GO
