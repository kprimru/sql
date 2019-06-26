USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_STAT_DETAIL_COMPLECT_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DistrStr + ' (' + DistrTypeName + ')' AS DIS_STR, HostID, DISTR, COMP
	FROM 
		dbo.ClientDistrView a WITH(NOEXPAND)
	WHERE ID_CLIENT = @CLIENT 
		AND EXISTS
			(
				SELECT *
				FROM dbo.ClientStatDetail z
				WHERE a.HostID = z.HostID
					AND a.DISTR = z.DISTR
					AND a.COMP = z.COMP
			)
	ORDER BY SystemOrder, DISTR, COMP
END
