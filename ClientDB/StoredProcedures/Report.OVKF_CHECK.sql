USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[OVKF_CHECK]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		[���-��/�������]	=	ISNULL(ManagerName, SubhostName),
		[��]				=	ServiceName,
		[������]			=	ISNULL(ClientFullName, Comment),
		[�����������]		=	r.DistrStr,
		[�����. ��]			=	REVERSE(STUFF(REVERSE(
			(
				SELECT InfoBankShortName + ','
				FROM
					(
						SELECT DISTINCT InfoBankShortName
						FROM USR.USRComplectNumberView c WITH(NOEXPAND)
						INNER JOIN dbo.SystemTable s ON s.SystemNumber = c.UD_SYS
						INNER JOIN USR.USRActiveView u ON c.UD_ID = u.UD_ID
						INNER JOIN USR.USRIB i ON UF_ID = UI_ID_USR
						INNER JOIN dbo.InfoBankTable ON InfoBankId = i.UI_ID_BASE
						WHERE c.UD_DISTR = r.DistrNumber AND c.UD_COMP = r.CompNumber AND s.HostId = r.HostId
							AND InfoBankName IN ('ARB', 'BRB', 'PBI', 'CJI', 'CMB')
					) AS o_O
				FOR XML PATH('')
			)), 1, 1, ''))
	FROM Reg.RegNodeSearchView r WITH(NOEXPAND)
	LEFT OUTER JOIN dbo.ClientDistrView cd WITH(NOEXPAND) ON r.HostID = cd.HostId AND r.DistrNumber = cd.DISTR AND r.CompNumber = cd.COMP
	LEFT OUTER JOIN dbo.CLientView WITH(NOEXPAND) ON ClientId = ID_CLIENT
	WHERE NT_SHORT = '���-�'
		AND EXISTS
			(
				SELECT *
				FROM USR.USRComplectNumberView c WITH(NOEXPAND)
				INNER JOIN dbo.SystemTable s ON s.SystemNumber = c.UD_SYS
				INNER JOIN USR.USRActiveView u ON c.UD_ID = u.UD_ID
				INNER JOIN USR.USRIB i ON UF_ID = UI_ID_USR
				WHERE c.UD_DISTR = r.DistrNumber AND c.UD_COMP = r.CompNumber AND s.HostId = r.HostId
					AND i.UI_ID_BASE IN (SELECT InfoBankId FROM dbo.InfoBankTable WHERE InfoBankName IN ('ARB', 'BRB', 'PBI', 'CJI', 'CMB'))
			)
	ORDER BY SubhostName, ManagerName, ServiceName, ClientFullName, r.SystemOrder, DistrNumber
END
