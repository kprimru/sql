USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [USR].[COMPLECT_INFO_BANK_CACHE_RESET]
AS
BEGIN
	SET NOCOUNT ON;
	
	TRUNCATE TABLE dbo.ComplectInfoBankCache
	
	INSERT INTO dbo.ComplectInfoBankCache(Complect, InfoBankID, InfoBankName)
	SELECT DISTINCT rns.Complect, cgl.InfoBankID, cgl.InfoBankName
	FROM Reg.RegNodeSearchView rns WITH(NOEXPAND)
	CROSS APPLY dbo.ComplectGetBanks(rns.Complect, NULL) cgl
	WHERE DS_REG = 0 AND SubhostName NOT IN ('Ó1', 'Í1', 'Ì', 'Ë1') AND 
			NOT EXISTS
				(
					SELECT *
					FROM Reg.RegNodeSearchView rns2
					WHERE	rns2.Complect = rns.Complect AND
							SubhostName IN ('Ó1', 'Í1', 'Ì', 'Ë1')
				)
END
