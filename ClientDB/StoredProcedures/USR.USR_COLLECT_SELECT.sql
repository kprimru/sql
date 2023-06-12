USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USR_COLLECT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[USR_COLLECT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[USR_COLLECT_SELECT]
	@BEGIN		SMALLDATETIME,
	@END		SMALLDATETIME,
	@SERVICE	VARCHAR(MAX)
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

		SELECT
			ServiceName, ClientFullName, ServiceTypeShortName AS ServiceTypeName,
			NULL AS UD_NAME, UF_ID, UF_DATE, USRFileKindShortName, UF_CREATE
		FROM
			dbo.ClientView a WITH(NOEXPAND)
			INNER JOIN dbo.TableIDFromXML(@SERVICE) ON ID = ServiceID
			INNER JOIN dbo.ServiceTypeTable d ON d.ServiceTypeID = a.ServiceTypeID
			INNER JOIN USR.USRData e ON e.UD_ID_CLIENT = a.ClientID AND e.UD_ACTIVE = 1
			LEFT OUTER JOIN
				(
					SELECT
						ROW_NUMBER() OVER(PARTITION BY UD_ID ORDER BY UD_ID, CASE UF_PATH WHEN 0 THEN 0 WHEN 3 THEN 0 ELSE 1 END, UF_CREATE DESC) AS RN,
						UD_ID, UF_ID, UF_DATE, USRFileKindShortName, UF_CREATE
					FROM
						USR.USRData
						INNER JOIN USR.USRFile ON UD_ID = UF_ID_COMPLECT
						INNER JOIN dbo.USRFileKindTable ON USRFileKindID = UF_ID_KIND
					WHERE UF_DATE BETWEEN @BEGIN AND @END
						/*AND
							(
								UF_PATH = 0
								OR
								UF_PATH = 3
							)*/
				) c ON c.UD_ID = e.UD_ID AND RN = 1
		WHERE ServiceStatusID = 2
		ORDER BY ServiceName, ClientFullName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[USR_COLLECT_SELECT] TO rl_usr_collect;
GO
