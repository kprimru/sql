USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[SOJ_OLD_RES]
@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SELECT 
		ClientFullName AS [������], DistrStr AS [�����������], DistrTypeName AS [����], UF_DATE AS [���� USR], ResVersionShort AS [������ ���. ������],
		ISNULL(OS_NAME, '') + ISNULL(' (' + OS_CAPACITY + ')', '') AS [������������ �������], USRFileKindShortName AS [������ ��������� USR],
		ServiceName AS [��], ManagerName AS [������������]
	FROM 
		dbo.ClientDistrView cdv WITH(NOEXPAND)
		--INNER JOIN USR.USRActiveView uav ON cdv.ID_CLIENT = uav.UD_ID_CLIENT
		CROSS APPLY (SELECT TOP 1 * 
					FROM USR.USRActiveView 
					WHERE UD_ID_CLIENT = cdv.ID_CLIENT
					ORDER BY UF_DATE DESC) uav
		INNER JOIN USR.USRFileTech uft ON uav.UF_ID = uft.UF_ID
		LEFT OUTER JOIN dbo.ResVersionTable rvt ON rvt.ResVersionID = UF_ID_RES
		INNER JOIN dbo.ClientView cv ON cv.ClientID = uav.UD_ID_CLIENT
		LEFT OUTER JOIN USR.Os os ON os.OS_ID = uft.UF_ID_OS 
	WHERE	DS_INDEX = 0 
		AND SystemBaseName = 'SOJ'
		AND (	DistrTypeId BETWEEN 1 AND 4 
				OR DistrTypeId = 8
				OR DistrTypeId = 17
				OR DistrTypeID = 24)
		AND ResVersionID < 146
	ORDER BY ClientFullName, DistrStr
END
