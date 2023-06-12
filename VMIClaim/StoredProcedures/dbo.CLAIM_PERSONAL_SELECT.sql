USE [VMIClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLAIM_PERSONAL_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT PERSONAL
	FROM dbo.Claim
	WHERE PERSONAL IS NOT NULL
		AND PERSONAL <> ''
END
GO
GRANT EXECUTE ON [dbo].[CLAIM_PERSONAL_SELECT] TO rl_read;
GO