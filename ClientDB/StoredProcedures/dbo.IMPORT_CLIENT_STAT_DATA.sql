USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IMPORT_CLIENT_STAT_DATA]
	@DATA		NVARCHAR(MAX),
	@OUT_DATA	NVARCHAR(512) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML

	SET @XML = CAST(@DATA AS XML)
	
	DECLARE @REFRESH	INT
	
	SET @REFRESH = 0
	
	INSERT INTO dbo.ClientStatDetail(WeekId, HostId, Distr, Comp, Net, UserCount, EnterSum, [0Enter], [1Enter], [2Enter], [3Enter], SessionTimeSum, SessionTimeAVG)
		SELECT
			WeekId, HostId, Distr, Comp, Net, UserCount, EnterSum, [Enter0], [Enter1], [Enter2], [Enter3], SessionTimeSum, SessionTimeAVG
		FROM
			(
				SELECT
					WeekId = P.[Id],
					HostId = H.HostId,
					F.[Distr],
					F.[Comp],
					F.[Net],
					F.[UserCount],
					F.[EnterSum],
					F.[Enter0],
					F.[Enter1],
					F.[Enter2],
					F.[Enter3],
					F.[SessionTimeSum],
					F.[SessionTimeAVG]
				FROM
				(
					SELECT
						[WeekStart] 		= c.value('@WeekStart[1]', 'SmallDateTime'),
						[HostReg]			= c.value('@HostReg[1]', 'VarChar(50)'),
						[Distr]				= c.value('@Distr[1]', 'Int'),
						[Comp]				= c.value('@Comp[1]', 'Int'),
						[Net]				= c.value('@Net[1]', 'VarChar(50)'),
						[UserCount]			= c.value('@UserCount[1]', 'Int'),
						[EnterSum]			= c.value('@EnterSum[1]', 'Int'),
						[Enter0]			= c.value('@Enter0[1]', 'Int'),
						[Enter1]			= c.value('@Enter1[1]', 'Int'),
						[Enter2]			= c.value('@Enter2[1]', 'Int'),
						[Enter3]			= c.value('@Enter3[1]', 'Int'),
						[SessionTimeSum]	= c.value('@SessionTimeSum[1]', 'Int'),
						[SessionTimeAVG]	= c.value('@SessionTimeAVG[1]', 'Float')
					FROM @XML.nodes('root/client_stat') a(c)
				) F
				INNER JOIN Common.Period P ON P.START = F.[WeekStart] AND P.Type = 1
				INNER JOIN dbo.Hosts H ON F.HostReg = H.HostReg
			) AS a
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.ClientStatDetail z
				WHERE z.HostId = a.HostId
					AND z.DISTR = a.DISTR
					AND z.COMP = a.COMP
					AND z.WeekId = a.WeekId
			)
	
	SET @REFRESH = @REFRESH + @@ROWCOUNT
	
	SET @OUT_DATA = 'Добавлено ' + CONVERT(NVARCHAR(32), @REFRESH) + ' записей'
END
