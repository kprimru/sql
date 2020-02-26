USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CONTROL_DOCUMENT_FILTER]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@MANAGER	INT = NULL
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

		IF @END IS NOT NULL
			SET @END = DATEADD(DAY, 1, @END)

		SELECT 
			ServiceStatusIndex, ClientID, ClientFullName, ManagerName, ServiceName, 
			DistrStr, DS_INDEX, a.DATE, a.RIC, a.DATE_S,
			ISNULL((
				SELECT TOP 1 e.InfoBankShortName
				FROM dbo.InfoBankTable e 
				WHERE e.InfoBankName = a.IB
			), a.IB) AS InfoBankShortName, IB_NUM, DOC_NAME
		FROM 
			dbo.ControlDocument a
			INNER JOIN dbo.SystemTable b ON a.SYS_NUM = b.SystemNumber
			INNER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.HostID = b.HostID AND a.DISTR = c.DISTR AND a.COMP = c.COMP
			INNER JOIN dbo.ClientView d WITH(NOEXPAND) ON d.ClientID = c.ID_CLIENT
		WHERE (a.DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (a.DATE < @END OR @END IS NULL)
			AND (d.ManagerID = @MANAGER OR @MANAGER IS NULL)
		
		UNION ALL
		
		SELECT 
			NULL, NULL, Comment, NULL, NULL, 
			DistrStr, DS_INDEX, a.DATE, a.RIC, a.DATE_S,
			ISNULL((
				SELECT TOP 1 e.InfoBankShortName
				FROM dbo.InfoBankTable e 
				WHERE e.InfoBankName = a.IB
			), a.IB) AS InfoBankShortName, IB_NUM, DOC_NAME
		FROM 
			dbo.ControlDocument a
			INNER JOIN dbo.SystemTable b ON a.SYS_NUM = b.SystemNumber
			INNER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON c.HostID = b.HostID AND a.DISTR = c.DistrNumber AND a.COMP = c.CompNumber
			--LEFT OUTER JOIN dbo.InfoBankTable e ON e.InfoBankName = a.IB
		WHERE (a.DATE >= @BEGIN OR @BEGIN IS NULL)
			AND (a.DATE < @END OR @END IS NULL)
			AND @MANAGER IS NULL
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.ClientDistrView z
					WHERE z.HostID = b.HostID 
						AND a.DISTR = z.DISTR 
						AND a.COMP = z.COMP
				)
		ORDER BY a.DATE_S DESC, ClientFullName, ClientID
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
