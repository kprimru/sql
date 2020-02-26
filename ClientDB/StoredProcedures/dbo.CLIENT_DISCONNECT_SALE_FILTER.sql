USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DISCONNECT_SALE_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME
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

		SET @END = DATEADD(DAY, 1, @END)

		/*
		найти дистрибутиыы, которые были отключены в данный промежуток времени
		*/

		DECLARE @distr Table
			(
				DATE	SMALLDATETIME,
				ID_HOST	SMALLINT,
				DISTR	INT,
				COMP	TINYINT
			);

		INSERT INTO @distr(ID_HOST, DISTR, COMP, DATE)
			SELECT RPR_ID_HOST, RPR_DISTR, RPR_COMP, dbo.DateOf(RPR_DATE)
			FROM 
				dbo.RegProtocol
				INNER JOIN dbo.Hosts ON RPR_ID_HOST = HostID
			WHERE (RPR_DATE >= @BEGIN OR @BEGIN IS NULL)
				AND (RPR_DATE < @END OR @END IS NULL)
				AND RPR_OPER IN ('Отключение', 'Сопровождение отключено')
				AND HostReg = 'LAW';
			 
		DELETE
		FROM @distr
		WHERE EXISTS
			(
				SELECT *
				FROM 
					dbo.RegNodeTable a
					INNER JOIN dbo.SystemTable b ON a.SystemName = b.SystemBaseName
					INNER JOIN Din.SystemType c ON c.SST_REG = a.DistrType
				WHERE DistrNumber = DISTR AND CompNumber = COMP AND HostID = ID_HOST AND SST_WEIGHT = 0
			);
			 	
		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result	
			 	 
		SELECT 
			ManagerName, ServiceName, ClientID, ClientFullName, DistrStr, DistrTypeName,
			DATE AS CD_DATE, DR_NAME, CD_NOTE,
			DIR_FIO = DIR.CP_FIO, DIR_PHONE = DIR.CP_PHONE,
			BUH_FIO = BUH.CP_FIO, BUH_PHONE = BUH.CP_PHONE
		INTO #result
		FROM 
			@distr a
			INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.DISTR = b.DISTR AND a.COMP = b.COMP AND a.ID_HOST = b.HostID
			INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
			OUTER APPLY
			(
				SELECT TOP 1 CD_DATE, DR_NAME, CD_NOTE, DR_ID
				FROM 
					dbo.ClientDisconnect
					LEFT OUTER JOIN dbo.DisconnectReason ON CD_ID_REASON = DR_ID
				WHERE CD_TYPE = 1 AND CD_ID_CLIENT = ClientID
				ORDER BY CD_DATE DESC, CD_DATETIME DESC
			) d
			OUTER APPLY
			(
				SELECT TOP 1 CP_FIO, CP_PHONE
				FROM dbo.ClientPersonalDirView cd WITH(NOEXPAND)
				WHERE cd.CP_ID_CLIENT = c.ClientID
			) DIR
			OUTER APPLY
			(
				SELECT TOP 1 CP_FIO, CP_PHONE
				FROM dbo.ClientPersonalBuhView cd WITH(NOEXPAND)
				WHERE cd.CP_ID_CLIENT = c.ClientID
			) BUH
		ORDER BY CD_DATE DESC, ManagerName, ServiceName, SystemOrder
		
		SELECT 
			ManagerName, ServiceName, ClientID, ClientFullName, DistrStr, DistrTypeName,
			CD_DATE, DR_NAME, CD_NOTE, DIR_FIO, DIR_PHONE, BUH_FIO, BUH_PHONE
		FROM #result
		ORDER BY CD_DATE DESC, ManagerName, ServiceName
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
