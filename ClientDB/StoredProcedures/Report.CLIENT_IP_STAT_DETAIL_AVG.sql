USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CLIENT_IP_STAT_DETAIL_AVG]
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
					Net AS [����]
					'


		SELECT @SQL =  @SQL + N'
					,
					(
					SELECT [ComplCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|���-�� ����������],
					(
					SELECT [ComplNoEnt]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|���������� ��� ������],
					(
					SELECT [ComplWithEnt]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|���������� �� �������],
					(
					SELECT [EntCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|����� ������],
					(
					SELECT [UserCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� �� ���� ����������],
					(
					SELECT [0Enter]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 0 ������],
					(
					SELECT [1Enter]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 1 ������],
					(
					SELECT [2Enter]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 2 ���������],
					(
					SELECT [3Enter]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 3 � ����� ���������],
					(
					SELECT [AVGUserCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ������������� � ���������],
					(
					SELECT [AVGWorkUserCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ���������� ������������� � ���������],
					(
					SELECT [AVGNWorkUserCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ������������ ������������� � ���������],
					(
					SELECT [AVGEntCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ������ � ��������],
					(
					SELECT [AVGWorkUserEntCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ������ ����������� ������������],

					(LEFT((
					SELECT [AVGSessionTime]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net), CHARINDEX(''.'',(	SELECT [AVGSessionTime]
														FROM dbo.ClientStatDetailAVG q
														WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
														AND q.Net=a.Net))+1)--���������� ������ ����� �������
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ����� ����� ������ (���)]
			

			'
		FROM Common.Period
		WHERE TYPE = 1
				AND START >= DATEADD(MONTH, -3, GETDATE())
				AND START <= DATEADD(WEEK, -1, GETDATE())

		SET @SQL = @SQL +
			N'
			FROM 	
				dbo.ClientStatDetailAVG a
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
