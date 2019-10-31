USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [USR].[COMPLECT_INFO_BANK_CACHE_RESET]
	@Complect	VarChar(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @Complect IS NULL
		TRUNCATE TABLE dbo.ComplectInfoBankCache
	ELSE
		DELETE FROM dbo.ComplectInfoBankCache WHERE Complect = @Complect;
	
	INSERT INTO dbo.ComplectInfoBankCache(Complect, InfoBankID, InfoBankName)
	SELECT rns.Complect, cgl.InfoBankID, cgl.InfoBankName
	FROM
	(
		SELECT DISTINCT rns.Complect
		FROM Reg.RegNodeSearchView rns WITH(NOEXPAND)
		WHERE	DS_REG = 0
			AND SubhostName NOT IN ('Ó1', 'Í1', 'Ì', 'Ë1')
			AND (rns.Complect = @Complect OR @Complect IS NULL)
	) rns
	CROSS APPLY dbo.ComplectGetBanks(rns.Complect, NULL) cgl
	--/*
	WHERE NOT EXISTS
		(
			SELECT *
			FROM Reg.RegNodeSearchView rns2 WITH(NOEXPAND)
			WHERE	rns2.Complect = rns.Complect
				AND SubhostName IN ('Ó1', 'Í1', 'Ì', 'Ë1')
				AND DS_REG = 0
		)
	--*/
END
