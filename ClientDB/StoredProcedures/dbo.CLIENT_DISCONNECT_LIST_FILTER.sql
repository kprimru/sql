USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DISCONNECT_LIST_FILTER]
	@MANAGER	INT,
	@SERVICE	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DT	SMALLDATETIME
	
	SET @DT = dbo.DateOf(GETDATE())
			 
	SELECT 
		ManagerName, ServiceName, ClientID, ClientFullName, DistrStr, DistrTypeName,		
		dbo.DistrWeight(SystemID, DistrTypeID, SystemTypeName, @DT) AS WEIGHT, a.NOTE,
		(
			SELECT MAX(PR_DATE)
			FROM dbo.DBFIncomeView d
			WHERE SYS_REG_NAME = SystemBaseName AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
				AND ID_PRICE >=
					ISNULL((
						SELECT BD_TOTAL_PRICE
						FROM dbo.DBFBillView e 
						WHERE SYS_REG_NAME = SystemBaseName AND DIS_NUM = DISTR AND DIS_COMP_NUM = COMP
							AND d.PR_DATE = e.PR_DATE
					), ID_PRICE + 1)
		) AS LAST_MON,
		dbo.DateOf((
			SELECT MAX(UIU_DATE)
			FROM USR.USRIBDateView WITH(NOEXPAND)
			WHERE UD_ID_CLIENT = ClientID
		)) AS LAST_UPDATE
	FROM 
		dbo.DistrDisconnect a
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ID_DISTR = b.ID
		INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
	WHERE a.STATUS = 1 AND b.DS_REG = 0
		AND (ManagerID = @MANAGER OR @MANAGER IS NULL)
		AND (ServiceID = @SERVICE OR @SERVICE IS NULL)
	ORDER BY ManagerName, ServiceName, SystemOrder
END
