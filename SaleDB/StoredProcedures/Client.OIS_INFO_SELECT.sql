USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[OIS_INFO_SELECT]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
	FROM Client.OISInfo
	WHERE ID_COMPANY = @ID
END
GO
GRANT EXECUTE ON [Client].[OIS_INFO_SELECT] TO rl_client_ois_r;
GO