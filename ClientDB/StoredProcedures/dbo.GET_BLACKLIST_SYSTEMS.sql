USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Выборка всех систем клиента

CREATE PROCEDURE [dbo].[GET_BLACKLIST_SYSTEMS]
@DISTR INT = NULL,
@SYSID INT = NULL,
@P_DEL INT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 
		'
		SELECT BL.*, S.*, R.NetCount, R.TechnolType, R.DistrType,R.Service, 
		R.Comment as Reg_Comment, R.Complect, CL.ClientFullName, 
		M.ManagerName, SI.ServiceName 
		FROM 
			dbo.BLACK_LIST_REG BL
			LEFT JOIN dbo.SystemTable S ON S.SystemID = BL.[ID_SYS]
			LEFT JOIN dbo.RegNodeTable R ON (R.SystemName = S.SystemBaseName)
										AND (R.DistrNumber=BL.DISTR)
										AND (R.CompNumber=BL.COMP)
			LEFT JOIN dbo.ClientDistrView C WITH(NOEXPAND) ON (C.SystemID = S.SystemID) 
														AND (C.DISTR=BL.DISTR)
														AND(C.COMP=BL.COMP)
			LEFT JOIN dbo.ClientTable CL ON (CL.ClientID=C.ID_CLIENT)	 AND CL.STATUS = 1
			LEFT JOIN dbo.ServiceTable SI ON SI.ServiceID = CL.ClientServiceID
			LEFT JOIN dbo.ManagerTable M ON M.ManagerID = SI.ManagerID
		WHERE (P_DELETE = @P_DEL) '
	 
		IF (@SYSID IS NOT NULL) 
			SET @SQL = @SQL + 'AND BL.ID_SYS = @SYSID  '

		IF (@DISTR  IS NOT NULL) 
			SET @SQL = @SQL + 'AND BL.DISTR = @DISTR '


		SET @SQL = @SQL + ' ORDER BY S.SystemOrder '

		EXEC sp_executesql	@SQL,
							N'@DISTR INT, @SYSID INT, @P_DEL INT ', 
							@DISTR = @DISTR, @SYSID = @SYSID, @P_DEL=@P_DEL 

		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END