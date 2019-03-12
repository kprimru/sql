USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DISCONNECT_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@TYPE		TINYINT,
	@REASON		UNIQUEIDENTIFIER,
	@CLIENT		VARCHAR(250),
	@MANAGER	INT,
	@CL_TYPE	NVARCHAR(MAX),
	@RC			INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		CD_ID,
		b.ClientID, b.ClientFullName, CD_DATE,
		CASE CD_TYPE
			WHEN 1 THEN 'Откл.'
			WHEN 2 THEN 'Подкл.'
			ELSE 'Неизв.'
		END AS CD_TYPE_STR,
		DR_ID, DR_NAME, CD_NOTE,
		CASE CD_TYPE WHEN 1 THEN
			dbo.DateOf(
				(
					SELECT MAX(DT)
					FROM
						(
							SELECT RPR_DATE AS DT
							FROM 
								dbo.RegProtocol
								INNER JOIN dbo.ClientDistrView WITH(NOEXPAND) ON RPR_ID_HOST = HostID
																			AND RPR_DISTR = DISTR
																			AND RPR_COMP = COMP
							WHERE  ID_CLIENT = b.ClientID AND RPR_OPER IN ('Отключение', 'Сопровождение отключено')
				
							UNION ALL
				
							SELECT DATE
							FROM 
								Reg.ProtocolText x
								INNER JOIN dbo.ClientDistrView z WITH(NOEXPAND) ON x.ID_HOST = z.HostID
																			AND x.DISTR = z.DISTR
																			AND x.COMP = z.COMP
							WHERE ID_CLIENT = b.ClientID
								AND COMMENT = 'Отключение'
						) AS o_O
				)
			)
			ELSE NULL END AS REG_DISCONNECT
	FROM 
		dbo.ClientDisconnect a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.CD_ID_CLIENT = b.ClientID
		INNER JOIN dbo.ClientTable d ON d.ClientID = b.ClientID AND d.STATUS = 1
		INNER JOIN dbo.TableIDFromXML(@CL_TYPE) e ON e.ID = d.ClientContractTypeID
		LEFT OUTER JOIN dbo.DisconnectReason c ON DR_ID = CD_ID_REASON		
	WHERE (CD_DATE >= @BEGIN OR @BEGIN IS NULL)
		AND (CD_DATE <= @END OR @END IS NULL)
		AND (@TYPE = 0 OR @TYPE = 1 AND CD_TYPE = 1 OR @TYPE = 2 AND CD_TYPE = 2)
		AND (CD_ID_REASON = @REASON /*OR @TYPE = 2 OR @TYPE = 0*/ OR @REASON IS NULL)
		AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		AND (b.ClientFullName LIKE @CLIENT OR @CLIENT IS NULL)
	ORDER BY CD_DATE DESC, ClientFullName
	
	SELECT @RC = @@ROWCOUNT
END