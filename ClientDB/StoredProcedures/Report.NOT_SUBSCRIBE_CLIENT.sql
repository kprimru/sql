USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Report].[NOT_SUBSCRIBE_CLIENT]
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
			[Название]          = C.ClientFullName,
			[СИ]                = C.ServiceName,
			[Рук-ль]            = C.ManagerName,
			[Сеть]              = D.DistrTypeName,
			[Тип]               = D.SystemTypeName,
			[Дистрибутив]       = D.DistrStr,
			[Дата регистрации]  = CC.ConnectDate
		FROM dbo.ClientView C WITH(NOEXPAND)
		INNER JOIN [dbo].[ServiceStatusConnected]() s ON C.ServiceStatusId = s.ServiceStatusId
		OUTER APPLY
		(
			SELECT TOP 1 DistrTypeName, SystemTypeName, DistrStr
			FROM dbo.ClientDistrView D WITH(NOEXPAND)
			WHERE C.ClientID = D.ID_CLIENT
				AND D.DS_REG = 0
			ORDER BY D.SystemOrder
		) D
		OUTER APPLY
		(
			SELECT TOP 1 ConnectDate
			FROM dbo.ClientConnectView CC WITH(NOEXPAND)
			WHERE CC.ClientID = C.ClientID
			ORDER BY ConnectDate
		) CC
		WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.ClientDelivery CD
						WHERE CD.ID_CLIENT = C.ClientID
						   AND FINISH IS NULL
					)
		ORDER BY ManagerName, ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
