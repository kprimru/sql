USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[SOJ_CHECK]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LastUSR Table
	(
		UF_ID		Int,
		UF_DATE		DateTime,
		Primary Key Clustered (UF_ID)
	);
	
	INSERT INTO @LastUSR
	SELECT UF_ID, UF_DATE
	FROM USR.USRActiveView
	WHERE UF_DATE >= '20200101';

	SELECT 
		[���-��/�������]	= ISNULL(ManagerName, SubhostName),
		[��]				= ServiceName,
		[������]			= ISNULL(ClientFullName, Comment),
		[�����������]		= D.DistrStr, 
		[����]				= NT_SHORT,
		[���]				= SST_SHORT,
		[����.����������]	= UF_DATE
	FROM Reg.RegNodeSearchView R WITH(NOEXPAND)
	INNER JOIN Din.NetTypeOffline() N ON R.NT_ID = N.NT_ID
	LEFT JOIN dbo.ClientDistrView D WITH(NOEXPAND) ON R.DistrNumber = D.DISTR AND R.CompNumber = D.COMP AND R.HostID = D.HostID
	LEFT JOIN dbo.ClientView C WITH(NOEXPAND) ON C.ClientID = D.ID_CLIENT
	OUTER APPLY
	(
		SELECT TOP (1) U.UF_DATE
		FROM @LastUSR				U
		INNER JOIN USR.USRPackage	P ON U.UF_ID = P.UP_ID_USR
		WHERE P.UP_ID_SYSTEM = R.SystemID
			AND P.UP_DISTR = R.DistrNumber
			AND P.UP_COMP = R.CompNumber
		ORDER BY U.UF_DATE DESC
	) U
	WHERE R.SystemBaseName = 'SOJ'
		AND R.DS_REG = 0
	ORDER BY CASE WHEN ManagerName IS NULL THEN 1 ELSE 0 END, SubhostName, ManagerName, ServiceName, ClientFullName, Comment, R.SystemOrder, DistrNumber
	OPTION (RECOMPILE)
END
