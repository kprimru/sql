USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_INNOVATION_REPORT]
	@INNOVATION	UNIQUEIDENTIFIER,
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@MANAGER	NVARCHAR(MAX) = NULL
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

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		CREATE TABLE #client
			(
				ServiceName			VARCHAR(150),
				ManagerName			VARCHAR(150),
				ClientID			INT,
				InnovationPersonal	INT,
				InnovationControl	TINYINT
			)

		INSERT INTO #client(ServiceName, ManagerName, ClientID, InnovationPersonal, InnovationControl)
			SELECT
				ServiceName, ManagerName, ClientID,
				(
					SELECT COUNT(*)
					FROM dbo.ClientInnovationPersonal c
					WHERE c.ID_INNOVATION = b.ID
				),
				(
					SELECT MIN(d.RESULT)
					FROM
						dbo.ClientInnovationPersonal c
						LEFT OUTER JOIN dbo.ClientInnovationControl d ON d.ID_PERSONAL = c.ID
					WHERE c.ID_INNOVATION = b.ID
				)
			FROM
				dbo.ClientView a WITH(NOEXPAND)
				INNER JOIN dbo.ClientInnovation b ON a.ClientID = b.ID_CLIENT
			WHERE b.ID_INNOVATION = @INNOVATION
				AND (a.ManagerID IN (SELECT ID FROM dbo.TableIDFromXML(@MANAGER)) OR @MANAGER IS NULL)
			ORDER BY ManagerName, ServiceName

		SELECT
			ManagerName, ServiceName,
			CL_COUNT, CL_PERSONAL, CL_OK, CL_FAIL, ROUND(100 * CONVERT(FLOAT, CL_PERSONAL) / CL_COUNT, 2) AS CL_PERCENT,
			MAN_COUNT, MAN_PERSONAL, MAN_OK, MAN_FAIL, ROUND(100 * CONVERT(FLOAT, MAN_PERSONAL) / MAN_COUNT, 2) AS MAN_PERCENT,
			TOTAL_COUNT, TOTAL_PERSONAL, TOTAL_OK, TOTAL_FAIL, ROUND(100 * CONVERT(FLOAT, TOTAL_PERSONAL) / TOTAL_COUNT, 2) AS TOTAL_PERCENT
		FROM
			(
				SELECT DISTINCT
					ManagerName, ServiceName,
					(
						SELECT COUNT(DISTINCT ClientID)
						FROM #client b
						WHERE a.ServiceName = b.ServiceName
					) AS CL_COUNT,
					(
						SELECT COUNT(*)
						FROM #client b
						WHERE a.ServiceName = b.ServiceName
							AND b.InnovationPersonal <> 0
					) AS CL_PERSONAL,
					(
						SELECT COUNT(*)
						FROM #client b
						WHERE a.ServiceName = b.ServiceName
							AND b.InnovationControl = 1
					) AS CL_OK,
					(
						SELECT COUNT(*)
						FROM #client b
						WHERE a.ServiceName = b.ServiceName
							AND b.InnovationControl = 0
					) AS CL_FAIL,
					(
						SELECT COUNT(DISTINCT ClientID)
						FROM #client b
						WHERE a.ManagerName = b.ManagerName
					) AS MAN_COUNT,
					(
						SELECT COUNT(*)
						FROM #client b
						WHERE a.ManagerName = b.ManagerName
							AND b.InnovationPersonal <> 0
					) AS MAN_PERSONAL,
					(
						SELECT COUNT(*)
						FROM #client b
						WHERE a.ManagerName = b.ManagerName
							AND b.InnovationControl = 1
					) AS MAN_OK,
					(
						SELECT COUNT(*)
						FROM #client b
						WHERE a.ManagerName = b.ManagerName
							AND b.InnovationControl = 0
					) AS MAN_FAIL,
					(
						SELECT COUNT(DISTINCT ClientID)
						FROM #client b 
					) AS TOTAL_COUNT,
					(
						SELECT COUNT(*)
						FROM #client b
						WHERE b.InnovationPersonal <> 0
					) AS TOTAL_PERSONAL,
					(
						SELECT COUNT(*)
						FROM #client b
						WHERE b.InnovationControl = 1
					) AS TOTAL_OK,
					(
						SELECT COUNT(*)
						FROM #client b
						WHERE b.InnovationControl = 0
					) AS TOTAL_FAIL
				FROM #client a
			) AS o_O
		ORDER BY ManagerName, ServiceName

		IF OBJECT_ID('tempdb..#client') IS NOT NULL
			DROP TABLE #client

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_INNOVATION_REPORT] TO rl_innovation_report;
GO