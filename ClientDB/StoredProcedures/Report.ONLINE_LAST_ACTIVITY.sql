USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ONLINE_LAST_ACTIVITY]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT 
			ISNULL(ManagerName, SubhostName) AS [���-��/�������],
			ServiceName AS [��], ISNULL(ClientFullName, Comment) AS [������], b.DistrStr AS [�����������], 
			b.RegisterDate AS [���� �����������], SST_SHORT AS [��� �������], NT_SHORT AS [����],		
			LAST_ACTIVITY AS [��������� ������ ����������], 
			e.LOGIN_CNT AS [���-�� ������ �� ��������� ������],
			e.SESSION_TIME AS [����� ������ �� ��������� ������],
			DATEDIFF(WEEK, 
						CASE 
							WHEN LAST_ACTIVITY IS NULL OR LAST_ACTIVITY < CONVERT(SMALLDATETIME, b.RegisterDate, 104) THEN CONVERT(SMALLDATETIME, b.RegisterDate, 104)
							ELSE LAST_ACTIVITY
						END, GETDATE()) AS [���-�� ������ ��� ����������],
			DATEDIFF(MONTH, 
						CASE 
							WHEN LAST_ACTIVITY IS NULL OR LAST_ACTIVITY < CONVERT(SMALLDATETIME, b.RegisterDate, 104) THEN CONVERT(SMALLDATETIME, b.RegisterDate, 104)
							ELSE LAST_ACTIVITY
						END, GETDATE()) AS [���-�� ������� ��� ����������]
		FROM
			(
				SELECT ID_HOST, DISTR, COMP, MAX(FINISH) AS LAST_ACTIVITY
				FROM 
					dbo.OnlineActivity a
					INNER JOIN Common.Period b ON a.ID_WEEK = b.ID
				WHERE ACTIVITY = 1
				GROUP BY ID_HOST, DISTR, COMP

				UNION ALL

				SELECT ID_HOST, DISTR, COMP, NULL
				FROM 
					dbo.OnlineActivity a
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.OnlineActivity z
						WHERE a.ID_HOST = z.ID_HOST
							AND a.DISTR = z.DISTR
							AND a.COMP = z.COMP
							AND z.ACTIVITY = 1
					)
				GROUP BY ID_HOST, DISTR, COMP
			) AS a
			INNER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.ID_HOST = b.HostID
																AND a.DISTR = b.DistrNumber
																AND a.COMP = b.CompNumber		
			LEFT OUTER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON b.HostID = c.HostID AND b.DistrNumber = c.DISTR AND b.CompNumber = c.COMP
			LEFT OUTER JOIN dbo.ClientView d WITH(NOEXPAND) ON c.ID_CLIENT = d.ClientID
			OUTER APPLY
			(
				SELECT LOGIN_CNT, dbo.TimeMinToStr(SESSION_TIME) AS SESSION_TIME
				FROM dbo.OnlineActivity z
				INNER JOIN Common.Period y ON z.ID_WEEK = y.ID
				WHERE z.ID_HOST = a.ID_HOST AND z.DISTR = a.DISTR AND z.COMP = a.COMP
					AND a.LAST_ACTIVITY = y.FINISH
					AND y.TYPE = 1
			) AS e
		WHERE b.DS_REG = 0 AND SST_SHORT NOT IN ('���', '���') AND NT_SHORT IN ('���', '����', '���', '���1', '���2', '���-�', '���-� (0;1)', '���-� (1;0)', '���-� (1;2)')
		ORDER BY CASE SubhostName WHEN '' THEN 1 ELSE 2 END, SubhostName, ManagerName, ServiceName, ClientFullName, b.DistrStr
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
