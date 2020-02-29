USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CHAT_INFILTRATION]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT 
			ManagerName AS [Руководитель], ServiceName AS [СИ], CL_CNT AS [Кол-во клиентов], COMPLECT_CNT AS [Комплектов подключено к чату], CHAT_CNT AS [Кол-во комплектов, имевших сеансы чата],
			ROUND(CASE
				WHEN COMPLECT_CNT = 0 THEN 0
				ELSE CONVERT(DECIMAL(8, 2), CHAT_CNT) / COMPLECT_CNT
			END * 100, 2) AS [Внедрение чата (%)]
		FROM
			(
				SELECT
					ManagerName, ServiceName,
					(
						SELECT COUNT(*)
						FROM dbo.ClientTable z
						INNER JOIN [dbo].[ServiceStatusConnected]() s ON z.StatusId = s.ServiceStatusId
						WHERE ClientServiceID = ServiceID
							AND STATUS = 1
					) AS CL_CNT,
					(
						SELECT COUNT(*)
						FROM 
							dbo.HotlineDistr y
							INNER JOIN dbo.ClientDistrView x WITH(NOEXPAND) ON y.ID_HOST = x.HostID AND y.DISTR = x.DISTR AND y.COMP = x.COMP
							INNER JOIN dbo.ClientTable w ON x.ID_CLIENT = w.ClientID
							INNER JOIN [dbo].[ServiceStatusConnected]() s ON w.StatusId = s.ServiceStatusId
							--INNER JOIN dbo.DistrTypeTable q ON q.DistrTypeID = x.DistrTypeID
							INNER JOIN Din.NetType q ON q.NT_ID_MASTER = x.DIstrTypeId
							INNER JOIN dbo.RegNodeComplectClientView z ON z.HOstiD = x.HostID AND z.DistrNumber = x.dISTR AND z.CompnUmber = x.COMP  
						WHERE ClientServiceID = a.ServiceID
							AND ClientServiceID = z.ServiceID
							AND w.STATUS = 1
							AND y.STATUS = 1
							AND q.NT_TECH IN (0, 1)
							AND y.UNSET_DATE IS NULL	
							AND x.DS_REG = 0					
					) AS COMPLECT_CNT,
					(
						SELECT COUNT(*)
						FROM
							(
								SELECT DISTINCT y.HostID, z.DISTR, z.COMP
								FROM 
									dbo.HotlineChat z
									INNER JOIN dbo.SystemTable y ON z.SYS = y.SystemNumber AND SystemRic = 20
									INNER JOIN dbo.HotlineDistr t ON t.ID_HOST = y.HostID AND t.DISTR = z.DISTR AND t.COMP = z.COMP
									INNER JOIN dbo.ClientDistrView x WITH(NOEXPAND) ON y.HostID = x.HostID AND z.DISTR = x.DISTR AND z.COMP = x.COMP
									INNER JOIN dbo.ClientTable w ON x.ID_CLIENT = w.ClientID
									
									--INNER JOIN dbo.DistrTypeTable q ON q.DistrTypeID = x.DistrTypeID
									INNER JOIN Din.NetType q ON q.NT_ID_MASTER = x.DIstrTypeId
								WHERE ClientServiceID = ServiceID
									AND w.STATUS = 1
									AND q.NT_TECH IN (0, 1)
							) AS o_O
					) AS CHAT_CNT
				FROM  
					dbo.ServiceTable a
					INNER JOIN dbo.ManagerTable b ON a.ManagerID = b.ManagerID
				WHERE EXISTS
					(
						SELECT *
						FROM dbo.ClientTable z
						INNER JOIN [dbo].[ServiceStatusConnected]() s ON z.StatusId = s.ServiceStatusId
						WHERE ClientServiceID = ServiceID
							AND STATUS = 1
					)
			) AS o_O
		ORDER BY ManagerName, ServiceName
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
