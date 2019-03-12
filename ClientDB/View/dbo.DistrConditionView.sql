USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[DistrConditionView]
AS
	SELECT DISTINCT
		SystemID, DistrNumber, CompNumber, InfoBankID, InfoBankOrder, SystemOrder, 
		InfoBankShortName, InfoBankStart, InfoBankName
	FROM dbo.DistrRequiredView a WITH(NOEXPAND)
	WHERE InfoBankActive = 1 AND SystemActive = 1
		AND [Required] = 2
		AND EXISTS
		(
			SELECT *
			FROM dbo.RegNodeCurrentView b WITH(NOEXPAND)
			WHERE DS_REG = 0 AND a.Complect = b.Complect AND b.SystemID = a.ID_SYSTEM
		)
		
	UNION ALL
	
	SELECT DISTINCT
		SystemID, DistrNumber, CompNumber, InfoBankID, InfoBankOrder, SystemOrder, 
		InfoBankShortName, InfoBankStart, InfoBankName
	FROM dbo.DistrRequiredView a WITH(NOEXPAND)
	WHERE InfoBankActive = 1 AND SystemActive = 1 
		--AND a.ID_SYSTEM IS NULL
		AND [Required] = 3
		AND NOT EXISTS
		(
			SELECT *
			FROM dbo.RegNodeCurrentView b WITH(NOEXPAND)
			WHERE DS_REG = 0 AND a.Complect = b.Complect AND 
            b.SystemID in (SELECT DISTINCT [ID_NOT_SYSTEM] from [dbo].[SystemBankRequired] 
            WHERE ([ID_SB]in (SELECT [ID] from [dbo].[SystemBankTable] sb WHERE 
             sb.InfoBankID =  InfoBankID AND sb.SystemID = SystemID AND sb.Required=[Required])))
		 )

		