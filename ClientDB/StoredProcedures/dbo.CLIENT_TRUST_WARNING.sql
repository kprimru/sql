USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_TRUST_WARNING]
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
			b.ClientID, ClientFullName, ManagerName, CC_DATE, CT_CORRECT, ServiceName
		FROM 
			dbo.ClientView b WITH(NOEXPAND) 
			INNER JOIN [dbo].[ClientList@Get?Write]() ON WCL_ID = b.ClientID
			INNER JOIN dbo.ClientTrustView WITH(NOEXPAND) ON CC_ID_CLIENT = b.ClientID 
		WHERE CT_TRUST = 0 AND CT_MAKE IS NULL
		ORDER BY ClientFullName
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END