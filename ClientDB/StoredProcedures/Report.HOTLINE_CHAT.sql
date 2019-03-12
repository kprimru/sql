USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Report].[HOTLINE_CHAT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SET language russian

	SELECT
		ClientFullName AS [������], /*ManagerName AS [���-��], */ServiceName AS [��], DistrStr AS [�����������], 
		FIRST_DATE AS [���� �������], /*FINISH AS [��������� ������], */
		/*EMAIL AS [Email], PHONE AS [�������], */CHAT AS [���], 
		RIC_PERSONAL AS [��������� ���], FIRST_ANS AS [����� ������ �������],
		DATEDIFF(SECOND, FIRST_DATE, FIRST_ANS) AS [�������� ������ �������],
		DATEDIFF(SECOND, START, FIRST_ANS) AS [����� ����� ��������� � �������],
		START AS [������ ������], FIO AS [���], PROFILE AS [�������]
	FROM 
		dbo.HotlineChatView a
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DISTR = b.DISTR AND a.COMP = b.COMP
		INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
	WHERE a.DISTR NOT IN (20, 509880)
		AND FIRST_DATE >= '20170206'
	ORDER BY FIRST_DATE DESC
END
