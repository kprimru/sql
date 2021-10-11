USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DistrRequiredQsovView]
WITH SCHEMABINDING
AS
	SELECT
		a.ID, b.SystemID, DistrNumber, CompNumber, Complect, d.InfoBankID,
		SystemOrder, InfoBankShortName, InfoBankOrder, InfoBankStart, InfoBankName,
		SystemActive, InfoBankActive, RuleNumber = 2
	FROM
		dbo.RegNodeTable a
		INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
		INNER JOIN dbo.InfoBankTable d ON d.InfoBankName = 'QSOV'
	WHERE	a.Service = 0 AND
			(
					b.SystemBaseName IN ('LAW', 'JUR', 'BUD', 'BUDU', 'JURP')
				OR
					(
							b.SystemBaseName IN ('SKJO', 'SKJP', 'SKJB', 'SBOO', 'SBOB')
						AND
							-- локальная или флэш-версия
							(a.NetCount = 0 AND a.TechnolType = 0 OR a.NetCount = 0 AND a.TechnolType = 1)
					)
				OR
					(
							b.SystemBaseName IN ('SKJP', 'SBOO')
						AND
							-- ОВМ-Ф (1;2), если надо все ОВМ-Ф, то оставить только a.TechnolType = 11
							(a.NetCount = 1 AND a.TechnolType = 11 AND a.ODON = 1 AND a.ODOFF = 2)
					)
			)

GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.DistrRequiredQsovView(DistrNumber,CompNumber,SystemID,InfoBankID)] ON [dbo].[DistrRequiredQsovView] ([DistrNumber] ASC, [CompNumber] ASC, [SystemID] ASC, [InfoBankID] ASC);
GO
