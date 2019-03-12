USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[EXPERT_DISTR_PRINT]
	@NAME			NVARCHAR(128),
	@DISTR			INT,
	@SERVICE		INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ServiceName, ClientName, DistrStr, NT_SHORT, SET_DATE
	FROM 
		dbo.RegNodeComplectClientView a
		INNER JOIN dbo.ExpDistr b ON a.HostID = b.ID_HOST
								AND a.DistrNumber = b.DISTR
								AND a.CompNumber = b.COMP
								AND STATUS = 1
	WHERE DS_REG = 0 
		AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
		AND (DistrNumber = @DISTR OR @DISTR IS NULL)
		AND (CLientName LIKE @NAME OR @NAME IS NULL)
	ORDER BY ServiceName, ClientName, SystemOrder, DistrNumber	
END
