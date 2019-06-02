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
	
	SELECT *
	FROM dbo.ClientStatDetail D
	INNER JOIN Common.Period P ON D.WeekId = P.Id
	WHERE	HostId = @HOST
		AND Distr = @DISTR
		AND Comp = @COMP
	ORDER BY P.START DESC
END