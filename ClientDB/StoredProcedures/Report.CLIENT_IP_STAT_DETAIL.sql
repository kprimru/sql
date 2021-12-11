USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[CLIENT_IP_STAT_DETAIL]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[CLIENT_IP_STAT_DETAIL]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[CLIENT_IP_STAT_DETAIL]
	@PARAM	NVARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
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

		DECLARE @SQL NVARCHAR(MAX);

		SET @SQL = N'SELECT DISTINCT
					ISNULL(ServiceName, SubhostName) AS [��/�������],
					ISNULL(ClientFullName, Comment) AS [������],
					a.DistrStr AS [�����������],
					CONVERT(SMALLDATETIME, a.RegisterDate, 104) AS [���� �����������],
					Net AS [����], UserCount AS [���������� �������������],
					'


		SELECT @SQL =  @SQL + N'
					(
					SELECT  SUM(EnterSum)
					FROM dbo.ClientStatDetail q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
							AND q.HostID = a.HostID
							AND q.Distr = a.DistrNumber
							AND q.Comp = a.CompNumber
					GROUP BY HostID, Distr, Comp
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|����� ������],
					(
					SELECT SUM([0Enter])
					FROM dbo.ClientStatDetail q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
							AND q.HostID = a.HostID
							AND q.Distr = a.DistrNumber
							AND q.Comp = a.CompNumber
					GROUP BY HostID, Distr, Comp
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 0 ������],
					(
					SELECT SUM([1Enter])
					FROM dbo.ClientStatDetail q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
							AND q.HostID = a.HostID
							AND q.Distr = a.DistrNumber
							AND q.Comp = a.CompNumber
					GROUP BY HostID, Distr, Comp
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 1 ������],
					(
					SELECT SUM([2Enter])
					FROM dbo.ClientStatDetail q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
							AND q.HostID = a.HostID
							AND q.Distr = a.DistrNumber
							AND q.Comp = a.CompNumber
					GROUP BY HostID, Distr, Comp
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 2 ���������],
					(
					SELECT SUM([3Enter])
					FROM dbo.ClientStatDetail q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
							AND q.HostID = a.HostID
							AND q.Distr = a.DistrNumber
							AND q.Comp = a.CompNumber
					GROUP BY HostID, Distr, Comp
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 3 � ����� ���������],
					(
					SELECT SUM(SessionTimeSum)
					FROM dbo.ClientStatDetail q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
							AND q.HostID = a.HostID
							AND q.Distr = a.DistrNumber
							AND q.Comp = a.CompNumber
					GROUP BY HostID, Distr, Comp
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|��������� ����� ���� ������ (���)],
					(LEFT((
					SELECT SUM(SessionTimeAVG)
					FROM dbo.ClientStatDetail q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
							AND q.HostID = a.HostID
							AND q.Distr = a.DistrNumber
							AND q.Comp = a.CompNumber
					GROUP BY HostID, Distr, Comp), CHARINDEX(''.'',(
																		SELECT SUM(SessionTimeAVG)
																		FROM dbo.ClientStatDetail q
																		WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
																				AND q.HostID = a.HostID
																				AND q.Distr = a.DistrNumber
																				AND q.Comp = a.CompNumber
																		GROUP BY HostID, Distr, Comp))+1)--���������� ������ ����� �������
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ����� ����� ������ (���)],
			'
		FROM Common.Period
		WHERE TYPE = 1
				AND START >= DATEADD(MONTH, -3, GETDATE())
				AND START <= DATEADD(WEEK, -1, GETDATE())

		SET @SQL = @SQL +
			N'
				(
					SELECT COUNT(*)
					FROM
						(
							SELECT DISTINCT WeekId, HostID, Distr, Comp
							FROM
								dbo.ClientStatDetail z
								INNER JOIN Common.Period y ON z.WeekId = y.ID
							WHERE z.HostID = a.HostID
								AND z.Distr = a.DistrNumber
								AND z.Comp = a.CompNumber
								AND DATEADD(MONTH, 3, START) >= GETDATE()
						) AS o_O
				) AS [���-�� ������ �� �������]
			FROM 
				Reg.RegNodeSearchView a WITH(NOEXPAND)
				INNER JOIN dbo.ClientStatDetail CSD ON CSD.HostID=a.HostID AND CSD.Distr=a.DistrNumber AND CSD.Comp=a.CompNumber
				LEFT OUTER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DistrNumber = b.DISTR AND a.CompNumber = b.COMP
				LEFT OUTER JOIN dbo.ClientView c WITH(NOEXPAND) ON b.ID_CLIENT = c.ClientID
			'
		--PRINT len(@SQL)

		--select (@SQL)
		EXEC (@SQL)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Report].[CLIENT_IP_STAT_DETAIL] TO rl_report;
GO
