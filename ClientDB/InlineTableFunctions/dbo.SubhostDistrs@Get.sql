USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SubhostDistrs@Get]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[SubhostDistrs@Get] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
/*
SELECT *
FROM [dbo].[SubhostDistrs@Get](NULL, 'Л1')

SELECT *
FROM [dbo].[SubhostDistrs@Get]('BE1CE068-519A-E111-8DAE-000C2986905F', NULL)
*/
CREATE FUNCTION [dbo].[SubhostDistrs@Get]
(
	@Subhost_Id		UniqueIdentifier	= NULL,
	@SubhostName	VarChar(100)		= NULL
)
RETURNS TABLE
AS
RETURN
(
	SELECT D.HostId, HostReg, DistrNumber, CompNumber
	FROM
	(
		SELECT
			Subhost_Id		= SH_ID,
			SubhostReg		= SH_REG,
			SubhostRegAdd	= SH_REG_ADD
		FROM dbo.Subhost AS S
		WHERE S.SH_ID = @Subhost_Id
			OR S.SH_REG = @SubhostName
	) AS SH
	CROSS APPLY
	(
		SELECT R.HostId, DistrNumber, CompNumber
		FROM Reg.RegNodeSearchView AS R WITH(NOEXPAND)
		WHERE R.SubhostName IN (SH.SubhostReg, SH.SubhostRegAdd)

		UNION

		SELECT R.HostId, DistrNumber, CompNumber
		FROM Reg.RegNodeSearchView AS R WITH(NOEXPAND)
		WHERE R.Complect IN
			(

				SELECT RC.Complect
				FROM dbo.SubhostComplect			AS C
				INNER JOIN Reg.RegNodeSearchView	AS RC WITH(NOEXPAND) ON C.SC_ID_HOST = RC.HostId
																		AND C.SC_DISTR = RC.DistrNumber
																		AND C.SC_COMP = RC.CompNumber
				WHERE C.SC_ID_SUBHOST = SH.Subhost_Id
					AND C.SC_REG = 1
			)
	) AS D
	LEFT JOIN dbo.Hosts AS H ON H.HostID = D.HostID
)
GO
