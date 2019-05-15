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
SET NOCOUNT ON;

DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'SELECT DISTINCT
			Net AS [����]
			'


SELECT @SQL =  @SQL + N'
			,
			(
			SELECT [ComplCount]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|���-�� ����������],
			(
			SELECT [ComplNoEnt]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|���������� ��� ������],
			(
			SELECT [ComplWithEnt]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|���������� �� �������],
			(
			SELECT [EntCount]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|����� ������],
			(
			SELECT [UserCount]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� �� ���� ����������],
			(
			SELECT [0Enter]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 0 ������],
			(
			SELECT [1Enter]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 1 ������],
			(
			SELECT [2Enter]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 2 ���������],
			(
			SELECT [3Enter]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������������� � 3 � ����� ���������],
			(
			SELECT [AVGUserCount]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ������������� � ���������],
			(
			SELECT [AVGWorkUserCount]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ���������� ������������� � ���������],
			(
			SELECT [AVGNWorkUserCount]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ������������ ������������� � ���������],
			(
			SELECT [AVGEntCount]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ������ � ��������],
			(
			SELECT [AVGWorkUserEntCount]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net
			) AS ['+CONVERT(NVARCHAR(128), NAME)+'|������� ���-�� ������ ����������� ������������],

			(LEFT((
			SELECT [AVGSessionTime]
			FROM IP.ClientStatDetailAVG q
			WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
			AND q.Net=a.Net), CHARINDEX(''.'',(	SELECT [AVGSessionTime]
												FROM IP.ClientStatDetailAVG q
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
		IP.ClientStatDetailAVG a
	'
--PRINT len(@SQL)

--select (@SQL)
EXEC (@SQL)