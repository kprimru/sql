USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Subhost].[USER_SELECT]
	@SH_ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME, PASS
	FROM Subhost.Users
	WHERE ID_SUBHOST = @SH_ID
		AND NAME NOT IN
			(
				'Ussuriisk', 
				'Artem',
				'Slavyanka',
				'Nakhodka'
			)
END