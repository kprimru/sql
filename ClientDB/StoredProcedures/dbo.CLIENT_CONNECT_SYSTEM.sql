USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONNECT_SYSTEM]
	@CLIENT	NVARCHAR(MAX)
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

		DECLARE @DS_ON UNIQUEIDENTIFIER
		
		SELECT @DS_ON = DS_ID
		FROM dbo.DistrStatus
		WHERE DS_REG = 0
		
		SELECT 
			a.ID, 
			ClientFullName,
			DistrStr,
			CONVERT(BIT, CASE
				WHEN EXISTS
					(
						SELECT *
						FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
						WHERE z.DistrNumber = a.DISTR
							AND z.CompNumber = a.COMP
							AND z.HostID = a.HostID
							AND z.DS_REG = 0
					) THEN 1
				ELSE 0
			END) AS CONNECT,
			(
				SELECT TOP 1 COMPLECT 
				FROM Reg.RegNodeSearchView z WITH(NOEXPAND)
				WHERE a.DISTR = z.DistrNumber 
					AND a.COMP = z.CompNumber 
					AND a.HostId = z.HostId
			) AS COMPLECT
		FROM 
			dbo.ClientDistrView a WITH(NOEXPAND)
			INNER JOIN dbo.TableIDFromXML(@CLIENT) b ON a.ID_CLIENT = b.ID
			INNER JOIN dbo.ClientTable d ON d.ClientID = a.ID_CLIENT
		ORDER BY ClientFullName, SystemOrder, DISTR, COMP
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
