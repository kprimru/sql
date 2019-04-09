USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTROL_DOCUMENT_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
		a.DATE, a.RIC, 
		ISNULL((
			SELECT TOP 1 e.InfoBankShortName
			FROM dbo.InfoBankTable e 
			WHERE e.InfoBankName = a.IB
		), a.IB) AS InfoBankShortName, IB_NUM, DOC_NAME
	FROM 
		dbo.ControlDocument a
		INNER JOIN dbo.SystemTable b ON a.SYS_NUM = b.SystemNumber
		INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.HostID = b.HostID AND a.DISTR = c.DISTR AND a.COMP = c.COMP
		
	WHERE ID_CLIENT = @CLIENT
	ORDER BY a.DATE DESC
END
