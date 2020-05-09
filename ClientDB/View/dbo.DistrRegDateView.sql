USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DistrRegDateView]
AS
	SELECT RPR_ID_HOST AS HostID, RPR_DISTR AS Distr, RPR_COMP AS Comp, RPR_DATE AS Date
	FROM dbo.RegProtocol
	WHERE RPR_DISTR IS NOT NULL

	UNION ALL

	SELECT ID_HOST, DISTR, COMP, DATE
	FROM Reg.ProtocolText
	WHERE DISTR IS NOT NULL

	UNION ALL

	SELECT a.ID_HOST, a.DISTR, a.COMP, b.REG_DATE
	FROM
		Reg.RegDistr a
		INNER JOIN Reg.RegHistory b ON a.ID = b.ID_DISTRGO
