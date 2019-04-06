USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reg].[RegProtocolTextConnectView]
WITH SCHEMABINDING
AS
	SELECT ID_HOST, DISTR, COMP, DATE, COUNT_BIG(*) AS CNT
	FROM Reg.ProtocolText a
	WHERE COMMENT LIKE '%���������%' OR COMMENT LIKE '%�����%'
	GROUP BY ID_HOST, DISTR, COMP, DATE