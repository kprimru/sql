USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [Reg].[RegProtocolConnectView]
WITH SCHEMABINDING
AS
	SELECT RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE) AS DATE, COUNT_BIG(*) AS CNT
	FROM dbo.RegProtocol a		
	WHERE RPR_OPER IN ('���������', '�����', '������������� ����������')
	GROUP BY RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE)