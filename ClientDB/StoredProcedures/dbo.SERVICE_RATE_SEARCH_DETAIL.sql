USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_RATE_SEARCH_DETAIL]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	INT,
	@TYPE		VARCHAR(MAX),
	@ERROR		BIT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ClientID, ClientFullName, SearchGet, 
		CASE
			WHEN SearchGet BETWEEN @BEGIN AND @END THEN 1
			ELSE 0
		END AS SearchMatch,		
			(
				SELECT TOP 1 CM_TEXT
				FROM 
					dbo.ClientSearchComments z CROSS APPLY
					(
						SELECT 
							x.value('@TEXT[1]', 'VARCHAR(500)') AS CM_TEXT,
							x.value('@DATE[1]', 'VARCHAR(50)') AS CM_DATE
						FROM z.CSC_COMMENTS.nodes('/ROOT/COMMENT') t(x)
					) AS o_O
				WHERE z.CSC_ID_CLIENT = t.ClientID
				ORDER BY CM_DATE DESC
		) AS Comment,
		REVERSE(STUFF(REVERSE(
			(
				SELECT SystemTypeName + ', '
				FROM
					(
						SELECT DISTINCT SystemTypeName
						FROM dbo.ClientDistrView z WITH(NOEXPAND)
						WHERE z.ID_CLIENT = t.ClientID AND DS_REG = 0
					) AS o_O
				ORDER BY SystemTypeName FOR XML PATH('')
			)), 1, 2, '')) AS SystemType
	FROM 
		(
			SELECT a.ClientID, ClientFullName, MAX(SearchGetDay) AS SearchGet
			FROM
				dbo.ClientTable a
				INNER JOIN dbo.TableIDFromXML(@TYPE) ON ID = ClientContractTypeID
				LEFT OUTER JOIN dbo.ClientSearchTable b ON a.ClientID = b.ClientID 
			WHERE ClientServiceID = @SERVICE 
				AND StatusID = 2 
				AND STATUS = 1
				AND EXISTS
					(
						SELECT *
						FROM dbo.ClientDistrView z WITH(NOEXPAND)
						WHERE a.ClientID = z.ID_CLIENT AND DistrTypeBaseCheck = 1 AND DS_REG = 0
					)
			GROUP BY a.ClientID, ClientFullName
		) AS t	
	WHERE (@ERROR = 0 OR (NOT (SearchGet BETWEEN @BEGIN AND @END) OR SearchGet IS NULL))
	ORDER BY ClientFullName
END