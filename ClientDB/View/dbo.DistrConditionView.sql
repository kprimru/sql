USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DistrConditionView]
AS
	SELECT DISTINCT
		SystemID, DistrNumber, CompNumber, InfoBankID, InfoBankOrder, SystemOrder,
		InfoBankShortName, InfoBankStart, InfoBankName
	FROM dbo.DistrRequiredDofView a WITH(NOEXPAND)
	WHERE InfoBankActive = 1 AND SystemActive = 1
		AND EXISTS
		(
			SELECT *
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			WHERE DS_REG = 0 AND a.Complect = b.Complect AND b.SystemBaseName IN ('QSA', 'CMT', 'FIN', 'KOR', 'BORG')
		)

	UNION ALL

	SELECT DISTINCT
		SystemID, DistrNumber, CompNumber, InfoBankID, InfoBankOrder, SystemOrder,
		InfoBankShortName, InfoBankStart, InfoBankName
	FROM dbo.DistrRequiredQsovView a WITH(NOEXPAND)
	WHERE InfoBankActive = 1 AND SystemActive = 1
		AND NOT EXISTS
		(
			SELECT *
			FROM Reg.RegNodeSearchView b WITH(NOEXPAND)
			WHERE DS_REG = 0 AND a.Complect = b.Complect
				AND b.SystemBaseName IN ('FIN', 'QSA')
		 )
