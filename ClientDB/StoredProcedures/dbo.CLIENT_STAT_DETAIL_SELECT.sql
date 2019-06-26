USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_STAT_DETAIL_SELECT]
	@HOST	INT,
	@DISTR	INT,
	@COMP	TINYINT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		P.NAME,
		[UpDate],
		Net,
		UserCount,
		EnterSum,
		[0Enter],
		[1Enter],
		[2Enter],
		[3Enter],
		SessionTimeSum = dbo.TimeMinToStr(SessionTimeSum),
		SessionTimeAVG = dbo.TimeSecToStr(Floor(SessionTimeAVG * 60))
	FROM dbo.ClientStatDetail D
	INNER JOIN Common.Period P ON D.WeekId = P.Id
	WHERE	HostId = @HOST
		AND Distr = @DISTR
		AND Comp = @COMP
	ORDER BY P.START DESC
END