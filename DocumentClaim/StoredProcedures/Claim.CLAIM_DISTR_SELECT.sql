﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Claim].[CLAIM_DISTR_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		EXEC Maintenance.START_PROC @@PROCID

		SELECT 
			a.ID_SYSTEM, a.ID_NET,
			b.SHORT AS SYS_STR,
			c.SHORT AS NET_STR,
			DISTR, COMP,
			CONVERT(NVARCHAR(64), DISTR) + CASE COMP WHEN 1 THEN '' ELSE '/' + CONVERT(NVARCHAR(32), COMP) END AS DIS_STR,
			CONVERT(NVARCHAR(MAX), '') AS WARN
		FROM
			Claim.DocumentDistr a
			INNER JOIN Distr.System b ON a.ID_SYSTEM = b.ID
			INNER JOIN Distr.Net c ON a.ID_NET = c.ID
		WHERE ID_DOCUMENT = @ID
		ORDER BY b.ORD, c.COEF, c.TECH, c.NET_COUNT

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
GRANT EXECUTE ON [Claim].[CLAIM_DISTR_SELECT] TO rl_claim_r;
GO