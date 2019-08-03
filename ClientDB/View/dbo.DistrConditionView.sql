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
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
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
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			WHERE DS_REG = 0 AND a.Complect = b.Complect
				AND b.SystemID IN 
					(
						SELECT DISTINCT [ID_NOT_SYSTEM] 
						FROM [dbo].[SystemBankRequired] 
						WHERE [ID_SB] IN 
							(
								SELECT [ID]
								FROM [dbo].[SystemBankTable] sb
								WHERE  sb.InfoBankID =  InfoBankID
									AND sb.SystemID = SystemID
									AND sb.Required=[Required]
							)
					)
		 )

		