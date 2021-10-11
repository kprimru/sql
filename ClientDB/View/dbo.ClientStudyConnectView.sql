USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[ClientStudyConnectView]
AS
	SELECT
		ClientID, DATE, HostID, DISTR, COMP,
		(
			SELECT TOP 1 RPR_TEXT
			FROM
				(
					SELECT TOP 1 0 AS TP, RPR_TEXT
					FROM dbo.RegProtocol
					WHERE RPR_DISTR = DISTR AND RPR_COMP = COMP AND RPR_ID_HOST = HostID
						AND RPR_DATE = DATE
						AND RPR_OPER IN ('Включение', 'НОВАЯ', 'Изм. парам.', 'Сопровождение подключено')
					ORDER BY RPR_DATE DESC

					UNION ALL

					SELECT TOP 1 1 AS TP, COMMENT
					FROM Reg.ProtocolText z
					WHERE z.DISTR = a.DISTR AND z.COMP = a.COMP AND ID_HOST = HostID
						AND z.DATE = a.DATE
						AND (COMMENT LIKE '%Включение%' OR COMMENT LIKE '%НОВАЯ%' OR COMMENT LIKE '%Изм. парам.%')
					ORDER BY DATE DESC
				) AS o_O
			ORDER BY TP
		) AS RPR_TEXT
	FROM
		(
			SELECT
				ClientID,
				dbo.DateOf(
					(
						SELECT TOP 1 RPR_DATE
						FROM
							(
								SELECT TOP 1 0 AS TP, RPR_DATE
								FROM dbo.RegProtocol
								WHERE RPR_DISTR = DISTR AND RPR_COMP = COMP AND RPR_ID_HOST = HostID
									AND RPR_OPER IN ('Включение', 'НОВАЯ', 'Изм. парам.', 'Сопровождение подключено')
								ORDER BY RPR_DATE DESC

								UNION ALL

								SELECT TOP 1 1 AS TP, DATE
								FROM Reg.ProtocolText z
								WHERE z.DISTR = b.DISTR AND z.COMP = b.COMP AND ID_HOST = HostID
									AND COMMENT IN ('Включение', 'НОВАЯ', 'Изм. парам.')
								ORDER BY DATE DESC

							) AS o_O
						ORDER BY TP
					)
				) AS DATE,
				HostID, DISTR, COMP
			FROM
				(
					SELECT
						ClientID,
						(
							SELECT TOP 1 ID
							FROM
								dbo.ClientDistrView WITH(NOEXPAND)
							WHERE ID_CLIENT = ClientID AND DS_REG = 0
							ORDER BY SystemOrder
						) AS ID
					FROM dbo.ClientTable
					WHERE STATUS = 1
				) AS a
				INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ID = b.ID
		) AS a
GO
