USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_PRINT_DISTR_SELECT]
	@LIST	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CLIENT	TABLE(CL_ID INT PRIMARY KEY)	

	INSERT INTO @CLIENT
		SELECT ID
		FROM dbo.TableIDFromXML(@LIST)

	SELECT 
		CL_ID,
		SystemShortName, DistrStr, DISTR,
		DistrTypeName, SystemTypeName, DS_NAME, DS_INDEX, SystemOrder
	FROM 
		@CLIENT a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.CL_ID = b.ClientID
		CROSS APPLY
			(
				SELECT 
					SystemShortName, DISTR,
					dbo.DistrString(NULL, DISTR, COMP) AS DistrStr, 
					DistrTypeName, SystemTypeName, DS_NAME, DS_INDEX, SystemOrder
				FROM dbo.ClientDistrView 
				WHERE ID_CLIENT = CL_ID
					AND
						(
							DS_REG = CASE b.ServiceStatusID WHEN 2 THEN 0 ELSE 1 END
							OR
							DS_REG = CASE b.ServiceStatusID WHEN 2 THEN 0 ELSE 0 END
						)
			) AS o_O
	WHERE EXISTS
		(
			SELECT *
			FROM dbo.ClientDistrView 
			WHERE ID_CLIENT = CL_ID
				AND
					(
						DS_REG = CASE b.ServiceStatusID WHEN 2 THEN 0 ELSE 1 END
						OR
						DS_REG = CASE b.ServiceStatusID WHEN 2 THEN 0 ELSE 0 END
					)
		)
		
	UNION ALL
	
	SELECT 
		CL_ID,
		'', '', 0,
		'', '', '', 0, 0
	FROM 
		@CLIENT a
		INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.CL_ID = b.ClientID
	WHERE NOT EXISTS
		(
			SELECT *
			FROM dbo.ClientDistrView 
			WHERE ID_CLIENT = CL_ID
				AND
					(
						DS_REG = CASE b.ServiceStatusID WHEN 2 THEN 0 ELSE 1 END
						OR
						DS_REG = CASE b.ServiceStatusID WHEN 2 THEN 0 ELSE 0 END
					)
		)
		
	ORDER BY CL_ID, SystemOrder, DISTR
END
