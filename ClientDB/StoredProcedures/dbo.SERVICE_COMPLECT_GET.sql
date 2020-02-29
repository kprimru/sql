USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_COMPLECT_GET]	
	@ID_SERVICE INT
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

		--ToDo почему не используются View???
		SELECT DISTINCT
			R.COMPLECT,
			(
				SELECT SystemName + ','
				FROM RegNodeTable
				WHERE (COMPLECT = R.COMPLECT)
					AND (Service = 0)
				FOR XML PATH('')
			) as SystemsList,
			C.ClientFullName AS ClientShortName, C.ClientFullName, R.TechNolType
		FROM RegNodeTable R
		LEFT JOIN SystemTable SY ON SY.SystemBaseName = R.SystemName
		LEFT JOIN ClientDistr CD ON (CD.DISTR = R.DistrNumber)
								AND (CD.COMP = R.CompNumber)
								AND (CD.ID_SYSTEM = Sy.SystemID)
								AND (CD.Status = 1)
		LEFT JOIN ClientTable C ON (C.ClientID = CD.ID_Client)AND(C.STATUS=1)
		WHERE (R.Service = 0)
			AND R.COMPLECT IS NOT NULL
			AND C.ClientID IS NOT NULL
			AND C.ClientServiceID = @ID_SERVICE
		ORDER BY R.COMPLECT
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
