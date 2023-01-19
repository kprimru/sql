﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Claim].[CLAIM_FULL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Claim].[CLAIM_FULL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Claim].[CLAIM_FULL_SELECT]
	@CLM_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		DENSE_RANK() OVER(ORDER BY CL_NAME) AS CLM_NUM,
		CLM_ID, CLM_DATE, US_NAME, CL_NAME, VD_NAME,
		SYS_SHORT, DT_SHORT, NT_SHORT, TT_SHORT,
		CLD_COUNT, CLD_COMMENT
	FROM Claim.ClaimFullView
	WHERE CLM_ID = @CLM_ID
	ORDER BY CL_NAME, SYS_ORDER
END
GO
GRANT EXECUTE ON [Claim].[CLAIM_FULL_SELECT] TO rl_claim_r;
GO
