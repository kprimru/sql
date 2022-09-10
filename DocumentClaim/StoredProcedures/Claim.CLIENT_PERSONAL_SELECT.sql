﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Claim].[CLIENT_PERSONAL_SELECT]
	@ID		NVARCHAR(64),
	@TYPE	NVARCHAR(64)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	IF @TYPE = N'OIS'
		SELECT NULL AS PERSONAL
		/*
		SELECT ServiceName AS PERSONAL
		FROM [PC275-SQL\ALPHA].ClientDB.dbo.ClientView WITH(NOEXPAND)
		WHERE ClientID = @ID
		*/
	ELSE IF @TYPE = N'SALE'
		SELECT TOP 1 PERSONAL
		FROM
			(
				SELECT 1 AS TP, SHORT AS PERSONAL
				FROM SaleDB.Client.CompanyProcessSaleView WITH(NOEXPAND)
				WHERE ID = @ID

				UNION ALL

				SELECT 2 AS TP, SHORT AS PERSONAL
				FROM SaleDB.Client.CompanyProcessManagerView WITH(NOEXPAND)
				WHERE ID = @ID
			) AS o_O
		ORDER BY TP
END
GO
GRANT EXECUTE ON [Claim].[CLIENT_PERSONAL_SELECT] TO rl_claim_r;
GO