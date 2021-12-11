USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_RIVAL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_RIVAL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CLIENT_RIVAL_SELECT]
	@CL_ID	INT,
	@DATE	SMALLDATETIME = NULL OUTPUT
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

		SELECT @DATE = MAX(CR_DATE)
		FROM dbo.ClientRival
		WHERE CL_ID = @CL_ID AND CR_ACTIVE = 1

		SELECT
			CR_ID, CR_ID_MASTER, CR_DATE, RivalTypeName, CR_COMPLETE,
			CR_CONTROL, CR_CONDITION, CR_CONTROL_DATE, RS_NAME AS ServiceStatusName,
			CASE CR_COMPLETE
				WHEN 1 THEN 'Отработана'
				ELSE 'Не отработана'
			END AS CR_COMPLETE_S,
			CASE CR_CONTROL
				WHEN 1 THEN 'На контроле ' + CONVERT(VARCHAR(20), CR_CONTROL_DATE, 104)
				ELSE ''
			END AS CR_CONTROL_S,
			REVERSE(
				STUFF(
					REVERSE(
						(
							SELECT PositionTypeName + ','
							FROM
								dbo.ClientRivalPersonal a
								INNER JOIN dbo.PositionTypeTable b ON a.CRP_ID_PERSONAL = b.PositionTypeID
							WHERE a.CRP_ID_RIVAL = CR_ID
							ORDER BY PositionTypeName FOR XML PATH('')
						)
					), 1, 1, ''
				)
			) AS CR_PERSONAL,
			ISNULL(CR_SURNAME + ' ', '') + ISNULL(CR_NAME + ' ', '') + ISNULL(CR_PATRON + ' ', '') + ISNULL(' тел. ' + CR_PHONE, '') As CR_FIO,
			CR_CREATE_USER + ' ' +
				CONVERT(VARCHAR(20), CR_CREATE_DATE, 104) + ' ' +
				CONVERT(VARCHAR(20), CR_CREATE_DATE, 108) AS CR_CREATE,
			CR_UPDATE_USER + ' ' +
				CONVERT(VARCHAR(20), CR_UPDATE_DATE, 104) + ' ' +
				CONVERT(VARCHAR(20), CR_UPDATE_DATE, 108) AS CR_UPDATE
		FROM
			dbo.ClientRival
			LEFT OUTER JOIN dbo.RivalTypeTable ON RivalTypeID = CR_ID_TYPE
			LEFT OUTER JOIN dbo.RivalStatus ON RS_ID = CR_ID_STATUS
		WHERE CL_ID = @CL_ID AND CR_ACTIVE = 1
		ORDER BY CR_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_RIVAL_SELECT] TO rl_client_rival_r;
GO
