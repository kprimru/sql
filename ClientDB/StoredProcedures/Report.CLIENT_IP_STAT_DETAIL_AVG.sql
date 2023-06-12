USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Report].[CLIENT_IP_STAT_DETAIL_AVG]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Report].[CLIENT_IP_STAT_DETAIL_AVG]  AS SELECT 1')
GO
ALTER PROCEDURE [Report].[CLIENT_IP_STAT_DETAIL_AVG]
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
					Net AS [Сеть]
					'


		SELECT @SQL =  @SQL + N'
					,
					(
					SELECT [ComplCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Кол-во комплектов],
					(
					SELECT [ComplNoEnt]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Комплектов без входов],
					(
					SELECT [ComplWithEnt]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Комплектов со входами],
					(
					SELECT [EntCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Всего входов],
					(
					SELECT [UserCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Пользователей во всех комплектах],
					(
					SELECT [0Enter]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Пользователей с 0 входов],
					(
					SELECT [1Enter]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Пользователей с 1 входом],
					(
					SELECT [2Enter]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Пользователей с 2 входомами],
					(
					SELECT [3Enter]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Пользователей с 3 и более входомами],
					(
					SELECT [AVGUserCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Среднее кол-во пользователей в комплекте],
					(
					SELECT [AVGWorkUserCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Среднее кол-во работавших пользователей в комплекте],
					(
					SELECT [AVGNWorkUserCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Среднее кол-во НЕработавших пользователей в комплекте],
					(
					SELECT [AVGEntCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Среднее кол-во входов в комплект],
					(
					SELECT [AVGWorkUserEntCount]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Среднее кол-во входов работающего пользователя],

					(LEFT((
					SELECT [AVGSessionTime]
					FROM dbo.ClientStatDetailAVG q
					WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
					AND q.Net=a.Net), CHARINDEX(''.'',(	SELECT [AVGSessionTime]
														FROM dbo.ClientStatDetailAVG q
														WHERE WeekId='''+CONVERT(NVARCHAR(64), ID)+'''
														AND q.Net=a.Net))+1)--количество знаков после запятой
					) AS ['+CONVERT(NVARCHAR(128), NAME)+'|Среднее время одной сессии (мин)]


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
GO
