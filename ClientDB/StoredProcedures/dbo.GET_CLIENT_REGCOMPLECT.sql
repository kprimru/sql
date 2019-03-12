USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
CREATE PROCEDURE [dbo].[GET_CLIENT_REGCOMPLECT]
@CLIENTID INT
WITH EXECUTE AS OWNER
 AS
BEGIN
SET NOCOUNT ON

		SELECT 
			R.*, S.*
		FROM [dbo].[RegNodeTable] R
		LEFT JOIN [dbo].SystemTable S ON S.[SystemBaseName] = R.[SystemName]
        WHERE R.[Complect] in ( SELECT distinct (r.Complect)
		FROM 
		dbo.ClientDistrView a WITH(NOEXPAND)
		INNER JOIN	dbo.SystemTable b ON a.SystemID = b.SystemID 
		INNER JOIN dbo.RegNodeTAble r ON (r.DistrNumber = a.DISTR)and
(r.CompNumber=a.COMP)and(r.SystemName=b.SystemBaseName)
where (a.ID_CLIENT=@CLIENTID)AND (r.Complect IS NOT NULL) )

UNION ALL

		SELECT 
        R.*, S.*
	FROM
		dbo.ClientDistrView A  WITH(NOEXPAND)
		INNER JOIN dbo.SystemTable S ON S.SystemID = A.SystemID
		INNER JOIN dbo.RegNodeTable R ON R.SystemName = S.SystemBaseName 
						AND R.DistrNumber = A.DISTR
						AND R.CompNumber = A.COMP
		where (A.ID_CLIENT=@CLIENTID)AND (R.Complect IS NULL) 
 
		ORDER BY S.SystemOrder
END